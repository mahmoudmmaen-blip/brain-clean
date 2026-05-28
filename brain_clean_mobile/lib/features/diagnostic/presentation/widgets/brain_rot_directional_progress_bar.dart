import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

/// Upper questionnaire progress — fill animates toward [value] from the slide axis.
class BrainRotDirectionalProgressBar extends StatelessWidget {
  const BrainRotDirectionalProgressBar({
    super.key,
    required this.value,
    required this.horizontalSign,
    required this.animation,
  });

  final double value;
  final double horizontalSign;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final growFromStart = isRtl ? horizontalSign < 0 : horizontalSign >= 0;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final fill = value.clamp(0.0, 1.0);

        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: context.diagnosticProgressTrack),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth * fill;
                    return Align(
                      alignment: growFromStart
                          ? AlignmentDirectional.centerStart
                          : AlignmentDirectional.centerEnd,
                      child: AnimatedContainer(
                        duration: Duration.zero,
                        width: barWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            left: growFromStart
                                ? const Radius.circular(6)
                                : Radius.zero,
                            right: growFromStart
                                ? Radius.zero
                                : const Radius.circular(6),
                          ),
                          gradient: LinearGradient(
                            begin: growFromStart
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            end: growFromStart
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            colors: [
                              context.brandPrimary.withValues(alpha: 0.55),
                              context.brandPrimary,
                            ],
                            stops: [0.0, 0.35 + 0.65 * t],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
