import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';

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
    final gold = context.diagnosticAccentGold;

    return Card(
      elevation: context.isLightTheme ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        side: BorderSide(color: context.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$code · $label',
                    style: AppDesignConstants.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
                Text(
                  '$displayValue',
                  style: AppDesignConstants.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: gold,
                    height: 1.2,
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
              activeColor: context.brandPrimary,
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}
