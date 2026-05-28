import 'package:flutter/material.dart';

import '../../../../core/constants/bc_score_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_session.dart';
import 'bc_score_colors.dart';

/// Four-pillar BC_score breakdown — pillar values and total from session snapshot.
class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({
    super.key,
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
    required this.boundBcScore,
  });

  /// Reads frozen pillars and bound score directly from [session].
  factory BcScoreBreakdown.fromSession({
    Key? key,
    required DiagnosticSession session,
  }) =>
      BcScoreBreakdown(
        key: key,
        brainPerformance: session.frozenBrainPerformance,
        digitalDiscipline: session.frozenDigitalDiscipline,
        healthyHabits: session.frozenHealthyHabits,
        consistency: session.frozenConsistency,
        boundBcScore: session.bcScore,
      );

  final double brainPerformance;
  final double digitalDiscipline;
  final double healthyHabits;
  final double consistency;
  final double boundBcScore;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final pillars = <({
      String label,
      double score,
      double weight,
    })>[
      (
        label: loc.bcScorePillarBrainPerformance,
        score: brainPerformance,
        weight: BcScoreConstants.brainPerformanceWeight,
      ),
      (
        label: loc.bcScorePillarDigitalDiscipline,
        score: digitalDiscipline,
        weight: BcScoreConstants.digitalDisciplineWeight,
      ),
      (
        label: loc.bcScorePillarHealthyHabits,
        score: healthyHabits,
        weight: BcScoreConstants.healthyHabitsWeight,
      ),
      (
        label: loc.bcScorePillarConsistency,
        score: consistency,
        weight: BcScoreConstants.consistencyWeight,
      ),
    ];

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
            for (final pillar in pillars)
              _PillarRow(
                label: '${pillar.label} (${(pillar.weight * 100).round()}%)',
                pillarScore: pillar.score,
                weight: pillar.weight,
              ),
            Divider(height: 20, color: context.borderMuted),
            _SummaryRow(
              label: loc.bcScoreLabel,
              value: '${boundBcScore.round()}%',
              color: BcScoreColors.forScore(boundBcScore),
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
