import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Apple Fitness–style ring with rounded caps and a soft mint glow.
class GlowProgressRing extends StatelessWidget {
  const GlowProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 11,
    this.color,
    this.trackColor,
    this.child,
  });

  /// 0.0–1.0.
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    final clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18 + 0.16 * clamped),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _GlowRingPainter(
            progress: clamped,
            strokeWidth: strokeWidth,
            color: accent,
            trackColor: trackColor ?? AppColors.ringTrack,
          ),
          child: child == null
              ? null
              : Padding(
                  padding: EdgeInsets.all(strokeWidth + 6),
                  child: Center(child: child),
                ),
        ),
      ),
    );
  }
}

class _GlowRingPainter extends CustomPainter {
  const _GlowRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (progress <= 0) return;

    final sweep = math.max(0.04, math.pi * 2 * progress);

    final glow = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, start, sweep, false, glow);

    final shader = SweepGradient(
      startAngle: start,
      endAngle: start + math.pi * 2,
      colors: [
        color.withValues(alpha: 0.72),
        color,
        AppColors.positive,
        color.withValues(alpha: 0.85),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
      transform: const GradientRotation(start),
    ).createShader(rect);

    final fill = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, fill);
  }

  @override
  bool shouldRepaint(covariant _GlowRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Rounded linear bar with a mint gradient fill and a soft glow.
class GlowProgressBar extends StatelessWidget {
  const GlowProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.color,
    this.trackColor,
  });

  /// 0.0–1.0.
  final double progress;
  final double height;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    final clamped = progress.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final fillW = maxW * clamped;
        final minCap = height;
        final shown = fillW <= 0
            ? 0.0
            : fillW.clamp(minCap, maxW);

        return SizedBox(
          height: height + 8,
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              Container(
                width: maxW,
                height: height,
                decoration: BoxDecoration(
                  color: trackColor ?? AppColors.ringTrack,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              if (shown > 0)
                Container(
                  width: shown,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryDark,
                        accent,
                        AppColors.positive,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.42),
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
