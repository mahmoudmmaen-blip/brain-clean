import 'package:flutter/material.dart';

import '../../../../core/constants/bc_score_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/diagnostic_model.dart';
import 'bc_score_colors.dart';

class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({super.key, required this.model});

  final DiagnosticModel model;

  static double _brainPerformance(DiagnosticModel m) => m.brainPerformance;
  static double _digitalDiscipline(DiagnosticModel m) => m.digitalDiscipline;
  static double _healthyHabits(DiagnosticModel m) => m.healthyHabits;
  static double _consistency(DiagnosticModel m) => m.consistency;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bcScore = model.bcScore;
    final pillars = <({String label, double Function(DiagnosticModel m) value, double weight})>[
      (
        label: loc.bcScorePillarBrainPerformance,
        value: _brainPerformance,
        weight: BcScoreConstants.brainPerformanceWeight,
      ),
      (
        label: loc.bcScorePillarDigitalDiscipline,
        value: _digitalDiscipline,
        weight: BcScoreConstants.digitalDisciplineWeight,
      ),
      (
        label: loc.bcScorePillarHealthyHabits,
        value: _healthyHabits,
        weight: BcScoreConstants.healthyHabitsWeight,
      ),
      (
        label: loc.bcScorePillarConsistency,
        value: _consistency,
        weight: BcScoreConstants.consistencyWeight,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.bcScoreBreakdownTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),
            for (final pillar in pillars)
              _PillarRow(
                label: '${pillar.label} (${(pillar.weight * 100).round()}%)',
                pillarScore: pillar.value(model),
                weight: pillar.weight,
              ),
            const Divider(height: 20, color: AppTheme.border),
            _SummaryRow(
              label: loc.bcScoreLabel,
              value: '${bcScore.round()}%',
              color: BcScoreColors.forScore(bcScore),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ),
              Text(
                '${pillarScore.round()}% → +${contribution.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gold,
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
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: AppTheme.gold.withValues(alpha: 0.85),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
