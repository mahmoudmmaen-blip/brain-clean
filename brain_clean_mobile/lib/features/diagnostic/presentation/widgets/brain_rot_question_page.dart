import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';

/// Single Brain Rot question — نعم / لا with directional slide transitions.
class BrainRotQuestionPage extends StatefulWidget {
  const BrainRotQuestionPage({
    super.key,
    required this.questionIndex,
    required this.questionText,
    required this.onAnswer,
    this.slideDirection = 1,
    this.onBack,
  });

  final int questionIndex;
  final String questionText;

  /// +1 next question, −1 previous (used for slide axis).
  final int slideDirection;
  final void Function(bool yes) onAnswer;
  final VoidCallback? onBack;

  @override
  State<BrainRotQuestionPage> createState() => _BrainRotQuestionPageState();
}

class _BrainRotQuestionPageState extends State<BrainRotQuestionPage>
    with SingleTickerProviderStateMixin {
  late double _displayedProgress;
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _displayedProgress = _targetProgress;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void didUpdateWidget(BrainRotQuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionIndex != widget.questionIndex) {
      _displayedProgress =
          (oldWidget.questionIndex + 1) / BrainRotTest.questionCount;
      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  double get _targetProgress =>
      (widget.questionIndex + 1) / BrainRotTest.questionCount;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final slideSign = widget.slideDirection >= 0 ? 1.0 : -1.0;
    final horizontalSign = isRtl ? -slideSign : slideSign;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.diagnosticBrainRotProgress(
            widget.questionIndex + 1,
            BrainRotTest.questionCount,
          ),
          textAlign: TextAlign.center,
          style: context.arabicLabelStyle,
        ),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, _) {
            final value = _displayedProgress +
                (_targetProgress - _displayedProgress) * _progressAnimation.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: context.diagnosticProgressTrack,
                color: context.brandPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                ...previous,
                if (current != null) current,
              ],
            ),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: Offset(horizontalSign * 0.22, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(
                position: offset,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: SingleChildScrollView(
              key: ValueKey<int>(widget.questionIndex),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: context.diagnosticQuestionCardDecoration,
                child: Text(
                  widget.questionText,
                  textAlign: TextAlign.center,
                  style: context.arabicQuestionStyle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                label: loc.diagnosticYes,
                icon: Icons.check_rounded,
                filled: true,
                accent: theme.colorScheme.error,
                onPressed: () => _handleAnswer(true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _AnswerButton(
                label: loc.diagnosticNo,
                icon: Icons.close_rounded,
                filled: false,
                accent: context.brandPrimary,
                onPressed: () => _handleAnswer(false),
              ),
            ),
          ],
        ),
        if (widget.onBack != null && widget.questionIndex > 0) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: widget.onBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: context.brandPrimary,
            ),
            label: Text(loc.diagnosticPreviousQuestion),
          ),
        ],
      ],
    );
  }

  void _handleAnswer(bool yes) {
    HapticFeedback.lightImpact();
    widget.onAnswer(yes);
  }
}

class _AnswerButton extends StatefulWidget {
  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final VoidCallback onPressed;

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.94,
      upperBound: 1,
    );
    _pulse = _pulseController.drive(Tween<double>(begin: 1, end: 0.94));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    HapticFeedback.selectionClick();
    setState(() => _pressed = true);
    await _pulseController.reverse(from: 1);
    widget.onPressed();
    if (mounted) setState(() => _pressed = false);
    _pulseController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icon, size: 22),
        const SizedBox(width: 8),
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );

    return ScaleTransition(
      scale: _pulse,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 80),
        child: widget.filled
            ? FilledButton(
                onPressed: _onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  minimumSize: const Size.fromHeight(
                    AppDesignConstants.minTouchTarget + 8,
                  ),
                  elevation: _pressed ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignConstants.radiusButton,
                    ),
                  ),
                ),
                child: child,
              )
            : OutlinedButton(
                onPressed: _onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.accent,
                  side: BorderSide(
                    color: widget.accent.withValues(alpha: 0.7),
                    width: 2,
                  ),
                  minimumSize: const Size.fromHeight(
                    AppDesignConstants.minTouchTarget + 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignConstants.radiusButton,
                    ),
                  ),
                ),
                child: child,
              ),
      ),
    );
  }
}
