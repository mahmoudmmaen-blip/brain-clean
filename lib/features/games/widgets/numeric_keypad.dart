import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Calculator-style numeric keypad for digit-span recall.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.clearLabel,
    required this.backspaceLabel,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final String clearLabel;
  final String backspaceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(['7', '8', '9']),
        const SizedBox(height: 8),
        _row(['4', '5', '6']),
        const SizedBox(height: 8),
        _row(['1', '2', '3']),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _actionKey(clearLabel, onClear)),
            const SizedBox(width: 8),
            Expanded(child: _digitKey('0')),
            const SizedBox(width: 8),
            Expanded(
              child: _actionKey(
                backspaceLabel,
                onBackspace,
                icon: Icons.backspace_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      children: [
        for (var i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _digitKey(digits[i])),
        ],
      ],
    );
  }

  Widget _digitKey(String digit) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onDigit(digit),
        child: SizedBox(
          height: 56,
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionKey(
    String label,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.textSecondary)
                : Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
