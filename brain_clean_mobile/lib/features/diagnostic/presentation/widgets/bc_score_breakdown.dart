import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_session.dart';
import '../../domain/pillar_bound_evaluation.dart';
import 'bc_score_colors.dart';

/// Four-pillar BC_score breakdown — bound to [PillarBoundEvaluation] snapshot.
class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({
    super.key,
    required this.evaluation,
  });

  /// Reads frozen pillars and bound score from [session] snapshot only.
  factory BcScoreBreakdown.fromSession({
    Key? key,
    required DiagnosticSession session,
  }) =>
      BcScoreBreakdown(
        key: key,
        evaluation: session.pillarEvaluation,
      );

  final PillarBoundEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final labels = <String, String>{
      'brain_performance': loc.bcScorePillarBrainPerformance,
      'digital_discipline': loc.bcScorePillarDigitalDiscipline,
      'healthy_habits': loc.bcScorePillarHealthyHabits,
      'consistency': loc.bcScorePillarConsistency,
    };

    return Card(
      elevation: context.isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        side: BorderSide(color: context.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.bcScoreBreakdownTitle,
              textAlign: TextAlign.center,
              style: AppDesignConstants.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textMuted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in evaluation.pillarRows)
              _PillarRow(
                label:
                    '${labels[row.key]!} (${(row.weight * 100).round()}%)',
                pillarScore: row.score,
                weight: row.weight,
              ),
            Divider(height: 20, color: context.borderMuted),
            _SummaryRow(
              label: loc.bcScoreLabel,
              value: '${evaluation.bcScore.round()}%',
              color: BcScoreColors.forScore(evaluation.bcScore),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillarRow extends StatelessWidget {
  const _PillarRow({
    required this.label,
    required this.pillarScore,
    required this.weight,
  });

  final String label;
  final double pillarScore;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final contribution = pillarScore * weight;
    final gold = context.diagnosticAccentGold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppDesignConstants.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
              Text(
                '${pillarScore.round()}% → +${contribution.toStringAsFixed(1)}',
                style: AppDesignConstants.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: gold,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pillarScore / 100,
              minHeight: 4,
              backgroundColor: context.diagnosticProgressTrack,
              color: gold.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppDesignConstants.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textMuted,
                height: 1.35,
              ),
            ),
          ),
          Text(
            value,
            style: AppDesignConstants.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
