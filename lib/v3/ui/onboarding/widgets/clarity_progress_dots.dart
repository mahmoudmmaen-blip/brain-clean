import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_constants.dart';

class ClarityProgressDots extends StatelessWidget {
  const ClarityProgressDots({
    super.key,
    required this.total,
    required this.current,
  });

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final active = index == current;
        return Container(
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppDesignConstants.brandGreen
                : AppDesignConstants.darkBorder,
          ),
        );
      }),
    );
  }
}
