import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';

/// Single Brain Rot question with styled نعم / لا actions.
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
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.surfaceMuted,
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.12, 0),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  questionText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.5,
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
                onPressed: () => onAnswer(true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _AnswerButton(
                label: loc.diagnosticNo,
                icon: Icons.close_rounded,
                filled: false,
                accent: theme.colorScheme.onSurface,
                onPressed: () => onAnswer(false),
              ),
            ),
          ],
        ),
        if (onBack != null && questionIndex > 0) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(loc.diagnosticPreviousQuestion),
          ),
        ],
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: context.borderMuted, width: 1.5),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: child,
    );
  }
}
