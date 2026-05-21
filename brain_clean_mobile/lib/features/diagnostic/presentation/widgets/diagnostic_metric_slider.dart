import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DiagnosticMetricSlider extends StatelessWidget {
  const DiagnosticMetricSlider({
    super.key,
    required this.code,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String code;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = value < 1 ? 1 : value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$code · $label',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$displayValue',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Slider(
              value: displayValue.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$displayValue',
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}
