import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/diagnostic_model.dart';
import 'brain_rot_colors.dart';

/// Final Brain Rot score dashboard with clinical interpretation and severity color.
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
    final bandColor = BrainRotColors.forBand(interpretation.band);
    final range = interpretation.band.scoreRange;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bandColor.withValues(alpha: 0.55)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bandColor.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                Text(
                  loc.diagnosticBrainRotScoreTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white54,
                        letterSpacing: 0.6,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${interpretation.score}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: bandColor,
                        height: 1,
                      ),
                ),
                Text(
                  loc.diagnosticBrainRotScoreOutOf(BrainRotTest.questionCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.diagnosticBrainRotBandRange(range.$1, range.$2),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: bandColor.withValues(alpha: 0.9),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: bandColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  interpretation.interpretationAr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onContinue,
          child: Text(loc.diagnosticContinueToBhi),
        ),
        if (onReviewAnswers != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onReviewAnswers,
            child: Text(loc.diagnosticReviewAnswers),
          ),
        ],
      ],
    );
  }
}
