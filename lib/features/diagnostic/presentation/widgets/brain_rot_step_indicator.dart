import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';

/// Visual step progress for the 10-question Brain Rot flow.
class BrainRotStepIndicator extends StatelessWidget {
  const BrainRotStepIndicator({
    super.key,
    required this.currentIndex,
    required this.answers,
  });

  final int currentIndex;
  final List<bool?> answers;

  @override
  Widget build(BuildContext context) {
    final primary = context.brandPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(BrainRotTest.questionCount, (i) {
        final answered = answers[i] != null;
        final isCurrent = i == currentIndex;
        final isYes = answers[i] == true;

        Color fill;
        double size;
        if (isCurrent) {
          fill = primary;
          size = 10;
        } else if (answered) {
          fill = isYes
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.85)
              : primary.withValues(alpha: 0.45);
          size = 8;
        } else {
          fill = context.surfaceMuted;
          size = 7;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: primary.withValues(alpha: 0.4), width: 2)
                : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
