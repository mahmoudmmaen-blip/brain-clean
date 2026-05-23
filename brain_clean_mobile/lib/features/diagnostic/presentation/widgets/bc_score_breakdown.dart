import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/bc_score_result.dart';

class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({super.key, required this.result});

  final BcScoreResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'معادلة BC_score (لحظي)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),
            _Row(
              label: 'الذراع الإيجابي (S+A)×1.5',
              value: '+${result.positiveArm.toStringAsFixed(1)}',
              color: AppTheme.success,
            ),
            _Row(
              label: 'الذراع السلبي (F+D+T+B)×0.8',
              value: '−${result.negativeArm.toStringAsFixed(1)}',
              color: const Color(0xFFEF4444),
            ),
            _Row(
              label: 'Raw score',
              value: result.rawScore.toStringAsFixed(2),
              color: AppTheme.gold,
            ),
            const Divider(height: 20, color: AppTheme.border),
            _Row(
              label: 'BC_score',
              value: '${result.bcScoreRounded}%',
              color: _colorFor(result.bcScore),
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
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
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
