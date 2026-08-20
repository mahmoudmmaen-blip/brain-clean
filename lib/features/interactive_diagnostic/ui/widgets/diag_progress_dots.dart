import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DiagProgressDots extends StatelessWidget {
  const DiagProgressDots({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: i == currentIndex ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= currentIndex
                  ? AppColors.primary
                  : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: i <= currentIndex
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
