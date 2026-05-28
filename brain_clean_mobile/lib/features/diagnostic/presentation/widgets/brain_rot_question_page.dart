import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';
import 'brain_rot_directional_progress_bar.dart';
import 'slide_lock_mechanism.dart';

/// Duration of the question-card [AnimatedSwitcher] — must match [SlideLockMechanism].
const Duration kBrainRotQuestionSlideDuration = Duration(milliseconds: 400);

/// Single Brain Rot question — نعم / لا with directional slide transitions.
class BrainRotQuestionPage extends StatefulWidget {
  const BrainRotQuestionPage({
    super.key,
    required this.questionIndex,
    required this.questionText,
    required this.onAnswer,
    this.slideDirection = 1,
    this.answersEnabled = true,
    this.onBack,
  });

  final int questionIndex;
  final String questionText;
  final int slideDirection;
  final bool answersEnabled;
  final void Function(bool yes) onAnswer;
  final VoidCallback? onBack;

  @override
  State<BrainRotQuestionPage> createState() => _BrainRotQuestionPageState();
}

class _BrainRotQuestionPageState extends State<BrainRotQuestionPage>
    with TickerProviderStateMixin {
  late final SlideLockMechanism _slideLockMechanism;
  late final AnimationController _slideMotionController;
  late final AnimationController _progressMotionController;
  late Animation<double> _progressMotion;

  double _progressFrom = 0;
  double _progressTo = 0;
  bool _localAnswerLocked = false;

  bool get _canInteract =>
      widget.answersEnabled &&
      !_slideLockMechanism.isLocked &&
      !_localAnswerLocked;

  @override
  void initState() {
    super.initState();
    _slideLockMechanism = SlideLockMechanism(
      slideDuration: kBrainRotQuestionSlideDuration,
    );
    _progressTo = _targetProgress;
    _progressFrom = _progressTo;

    _slideMotionController = AnimationController(
      vsync: this,
      duration: kBrainRotQuestionSlideDuration,
    );
    _progressMotionController = AnimationController(
      vsync: this,
      duration: kBrainRotQuestionSlideDuration,
    );
    _progressMotion = CurvedAnimation(
      parent: _progressMotionController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _progressMotionController.forward();
    });
  }

  @override
  void didUpdateWidget(BrainRotQuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionIndex != widget.questionIndex) {
      _localAnswerLocked = false;
      _progressFrom = (oldWidget.questionIndex + 1) / BrainRotTest.questionCount;
      _progressTo = _targetProgress;
      _progressMotionController
        ..reset()
        ..forward();
      _slideMotionController
        ..reset()
        ..forward();
      _slideLockMechanism.acquireForAnimation(
        _slideMotionController,
        () => setState(() {}),
      );
    }
    if (!oldWidget.answersEnabled && widget.answersEnabled) {
      _localAnswerLocked = false;
    }
    if (oldWidget.answersEnabled && !widget.answersEnabled) {
      _localAnswerLocked = true;
    }
  }

  @override
  void dispose() {
    _slideLockMechanism.dispose();
    _slideMotionController.dispose();
    _progressMotionController.dispose();
    super.dispose();
  }

  double get _targetProgress =>
      (widget.questionIndex + 1) / BrainRotTest.questionCount;

  double get _animatedProgress =>
      _progressFrom + (_progressTo - _progressFrom) * _progressMotion.value;

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
        _buildProgressHeader(loc),
        const SizedBox(height: 14),
        BrainRotDirectionalProgressBar(
          value: _animatedProgress,
          horizontalSign: horizontalSign,
          animation: _progressMotion,
        ),
        const SizedBox(height: 32),
        Expanded(child: _buildQuestionSlideSwitcher(horizontalSign)),
        const SizedBox(height: 24),
        _buildAnswerActions(loc, theme),
        if (widget.onBack != null && widget.questionIndex > 0)
          _buildBackButton(loc),
      ],
    );
  }

  Widget _buildProgressHeader(AppLocalizations loc) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      child: Text(
        loc.diagnosticBrainRotProgress(
          widget.questionIndex + 1,
          BrainRotTest.questionCount,
        ),
        key: ValueKey<int>(widget.questionIndex),
        textAlign: TextAlign.center,
        style: context.arabicLabelStyle,
      ),
    );
  }

  Widget _buildQuestionSlideSwitcher(double horizontalSign) {
    return AnimatedSwitcher(
      duration: kBrainRotQuestionSlideDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => _slideLockMechanism.layoutBuilder(
        currentChild: current,
        previousChildren: previous,
        forceShield: _slideLockMechanism.isLocked,
      ),
      transitionBuilder: (child, animation) =>
          _slideLockMechanism.transitionBuilder(
        child: child,
        animation: animation,
        build: (transitionChild, transitionAnimation) =>
            buildBrainRotSlideTransition(
          child: transitionChild,
          animation: transitionAnimation,
          horizontalSign: horizontalSign,
        ),
      ),
      child: _buildQuestionCard(),
    );
  }

  Widget _buildQuestionCard() {
    return SingleChildScrollView(
      key: ValueKey<int>(widget.questionIndex),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: context.diagnosticQuestionCardDecoration,
        child: Text(
          widget.questionText,
          textAlign: TextAlign.center,
          style: context.arabicQuestionStyle,
        ),
      ),
    );
  }

  Widget _buildAnswerActions(AppLocalizations loc, ThemeData theme) {
    return _slideLockMechanism.shieldInteractions(
      extraLocked: !widget.answersEnabled || _localAnswerLocked,
      child: Row(
        children: [
          Expanded(
            child: _AnswerButton(
              label: loc.diagnosticYes,
              icon: Icons.check_rounded,
              filled: true,
              accent: theme.colorScheme.error,
              enabled: _canInteract,
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
              enabled: _canInteract,
              onPressed: () => _handleAnswer(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: _slideLockMechanism.shieldInteractions(
        extraLocked: !widget.answersEnabled || _localAnswerLocked,
        child: TextButton.icon(
          onPressed: _canInteract ? widget.onBack : null,
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: context.brandPrimary,
          ),
          label: Text(loc.diagnosticPreviousQuestion),
        ),
      ),
    );
  }

  void _handleAnswer(bool yes) {
    if (!_canInteract || _slideLockMechanism.isLocked) return;
    setState(() => _localAnswerLocked = true);
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
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final bool enabled;
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
    if (!widget.enabled) return;
    HapticFeedback.selectionClick();
    setState(() => _pressed = true);
    await _pulseController.reverse(from: 1);
    if (!widget.enabled) return;
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
                onPressed: widget.enabled ? _onTap : null,
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
                onPressed: widget.enabled ? _onTap : null,
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
