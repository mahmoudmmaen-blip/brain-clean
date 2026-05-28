import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/diagnostic_model.dart';

/// Single Brain Rot question with yes/no actions and progress.
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
    final progress = (questionIndex + 1) / BrainRotTest.questionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.diagnosticBrainRotProgress(questionIndex + 1, BrainRotTest.questionCount),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white54,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: Text(
                questionText,
                key: ValueKey<int>(questionIndex),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => onAnswer(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.diagnosticYes),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onAnswer(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.diagnosticNo),
              ),
            ),
          ],
        ),
        if (onBack != null && questionIndex > 0) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBack,
            child: Text(loc.diagnosticPreviousQuestion),
          ),
        ],
      ],
    );
  }
}
