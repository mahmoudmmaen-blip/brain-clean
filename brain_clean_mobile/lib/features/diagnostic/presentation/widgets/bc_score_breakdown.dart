import 'package:flutter/material.dart';

import '../../../../core/constants/bc_score_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/diagnostic_model.dart';
import 'bc_score_colors.dart';

class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({super.key, required this.model});

  final DiagnosticModel model;

  static const _pillars = <({String label, double Function(DiagnosticModel m) value, double weight})>[
    (
      label: 'Brain performance',
      value: _brainPerformance,
      weight: BcScoreConstants.brainPerformanceWeight,
    ),
    (
      label: 'Digital discipline',
      value: _digitalDiscipline,
      weight: BcScoreConstants.digitalDisciplineWeight,
    ),
    (
      label: 'Healthy habits',
      value: _healthyHabits,
      weight: BcScoreConstants.healthyHabitsWeight,
    ),
    (
      label: 'Consistency',
      value: _consistency,
      weight: BcScoreConstants.consistencyWeight,
    ),
  ];

  static double _brainPerformance(DiagnosticModel m) => m.brainPerformance;
  static double _digitalDiscipline(DiagnosticModel m) => m.digitalDiscipline;
  static double _healthyHabits(DiagnosticModel m) => m.healthyHabits;
  static double _consistency(DiagnosticModel m) => m.consistency;

  @override
  Widget build(BuildContext context) {
    final bcScore = model.bcScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'BHI · BC_score breakdown',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),
            for (final pillar in _pillars)
              _PillarRow(
                label: '${pillar.label} (${(pillar.weight * 100).round()}%)',
                pillarScore: pillar.value(model),
                weight: pillar.weight,
              ),
            const Divider(height: 20, color: AppTheme.border),
            _SummaryRow(
              label: 'BC_score',
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
