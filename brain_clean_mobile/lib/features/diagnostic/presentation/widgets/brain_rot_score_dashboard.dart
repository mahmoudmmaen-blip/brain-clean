import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';
import 'brain_rot_colors.dart';

/// Brain Rot results — score, [BrainRotTest.interpretScore], and band color.
class BrainRotScoreDashboard extends StatelessWidget {
  const BrainRotScoreDashboard({
    super.key,
    required this.interpretation,
    required this.onContinue,
    this.onReviewAnswers,
  });

  final BrainRotInterpretation interpretation;
  final VoidCallback onContinue;
  final VoidCallback? onReviewAnswers;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bandColor = BrainRotColors.forBand(interpretation.band);
    final range = interpretation.band.scoreRange;
    final clinicalText =
        BrainRotTest.interpretScore(interpretation.score);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bandColor.withValues(alpha: 0.55)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bandColor.withValues(alpha: 0.2),
                  bandColor.withValues(alpha: 0.04),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                Icon(Icons.psychology_alt_outlined, color: bandColor, size: 36),
                const SizedBox(height: 12),
                Text(
                  loc.diagnosticBrainRotScoreTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: context.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${interpretation.score}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: bandColor,
                    height: 1,
                  ),
                ),
                Text(
                  loc.diagnosticBrainRotScoreOutOf(BrainRotTest.questionCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSubtle,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bandColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loc.diagnosticBrainRotBandRange(range.$1, range.$2),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: bandColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.diagnosticBrainRotInterpretationTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: bandColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  clinicalText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: onContinue,
          child: Text(loc.diagnosticContinueToBhi),
        ),
        if (onReviewAnswers != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: onReviewAnswers,
            child: Text(loc.diagnosticReviewAnswers),
          ),
        ],
      ],
    );
  }
}
