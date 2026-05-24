import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/diagnostic_model.dart';

class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({super.key, required this.model});

  final DiagnosticModel model;

  static const _weights = <String, double>{
    'brainPerformance': 0.35,
    'digitalDiscipline': 0.30,
    'healthyHabits': 0.25,
    'consistency': 0.10,
  };

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
            _PillarRow(
              label: 'Brain performance (35%)',
              pillarScore: model.brainPerformance,
              weight: _weights['brainPerformance']!,
            ),
            _PillarRow(
              label: 'Digital discipline (30%)',
              pillarScore: model.digitalDiscipline,
              weight: _weights['digitalDiscipline']!,
            ),
            _PillarRow(
              label: 'Healthy habits (25%)',
              pillarScore: model.healthyHabits,
              weight: _weights['healthyHabits']!,
            ),
            _PillarRow(
              label: 'Consistency (10%)',
              pillarScore: model.consistency,
              weight: _weights['consistency']!,
            ),
            const Divider(height: 20, color: AppTheme.border),
            _Row(
              label: 'BC_score',
              value: '${bcScore.round()}%',
              color: _colorFor(bcScore),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorFor(double score) {
    if (score <= 30) return const Color(0xFFEF4444);
    if (score <= 60) return AppTheme.gold;
    if (score <= 85) return AppTheme.success;
    return const Color(0xFF0F6E56);
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
            '${pillarScore.round()}% → +${contribution.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

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
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
