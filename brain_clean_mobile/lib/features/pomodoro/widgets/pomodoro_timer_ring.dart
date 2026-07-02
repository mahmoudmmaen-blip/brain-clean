import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular countdown ring with centered MM:SS label.
class PomodoroTimerRing extends StatelessWidget {
  const PomodoroTimerRing({
    super.key,
    required this.progress,
    required this.ringColor,
    required this.timeLabel,
  });

  final double progress;
  final Color ringColor;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _PomodoroRingPainter(
          progress: progress,
          ringColor: ringColor,
          trackColor: dividerColor,
        ),
        child: Center(
          child: Text(
            timeLabel,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _PomodoroRingPainter extends CustomPainter {
  _PomodoroRingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  final double progress;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const stroke = 10.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _PomodoroRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.trackColor != trackColor;
}
