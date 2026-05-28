import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';

/// Single Brain Rot question with styled نعم / لا actions and tap feedback.
class BrainRotQuestionPage extends StatelessWidget {
  const BrainRotQuestionPage({
    super.key,
    required this.questionIndex,
    required this.questionText,
    required this.onAnswer,
    this.onBack,
  });

  final int questionIndex;
  final String questionText;
  final void Function(bool yes) onAnswer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = (questionIndex + 1) / BrainRotTest.questionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.diagnosticBrainRotProgress(
            questionIndex + 1,
            BrainRotTest.questionCount,
          ),
          textAlign: TextAlign.center,
          style: context.arabicLabelStyle,
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            key: ValueKey<double>(progress),
            value: progress,
            minHeight: 8,
            backgroundColor: context.diagnosticProgressTrack,
            color: context.brandPrimary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0.14, 0.02),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: SingleChildScrollView(
              key: ValueKey<int>(questionIndex),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: context.diagnosticQuestionCardDecoration,
                child: Text(
                  questionText,
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
        if (onBack != null && questionIndex > 0) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded, size: 18, color: context.brandPrimary),
            label: Text(loc.diagnosticPreviousQuestion),
          ),
        ],
      ],
    );
  }

  void _handleAnswer(bool yes) {
    HapticFeedback.lightImpact();
    onAnswer(yes);
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
        opacity: _pressed ? 0.9 : 1,
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
