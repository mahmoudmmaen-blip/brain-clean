import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';

/// Single Brain Rot question with animated نعم / لا actions and tap feedback.
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
          style: theme.textTheme.labelMedium?.copyWith(
            color: context.textMuted,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: context.surfaceMuted,
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
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
                  begin: const Offset(0.14, 0),
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
              child: Padding(
                key: ValueKey<int>(questionIndex),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  questionText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                label: loc.diagnosticYes,
                icon: Icons.check_rounded,
                filled: true,
                accent: theme.colorScheme.error,
                onPressed: () => _handleAnswer(context, true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _AnswerButton(
                label: loc.diagnosticNo,
                icon: Icons.close_rounded,
                filled: false,
                accent: theme.colorScheme.primary,
                onPressed: () => _handleAnswer(context, false),
              ),
            ),
          ],
        ),
        if (onBack != null && questionIndex > 0) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded, size: 18, color: theme.colorScheme.primary),
            label: Text(loc.diagnosticPreviousQuestion),
          ),
        ],
      ],
    );
  }

  void _handleAnswer(BuildContext context, bool yes) {
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

class _AnswerButtonState extends State<_AnswerButton> {
  bool _pressed = false;

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

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.88 : 1,
          duration: const Duration(milliseconds: 100),
          child: widget.filled
              ? FilledButton(
                  onPressed: widget.onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.white,
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
                  onPressed: widget.onPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.accent,
                    side: BorderSide(
                      color: widget.accent.withValues(alpha: 0.65),
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
      ),
    );
  }
}
