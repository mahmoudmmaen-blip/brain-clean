import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular arc gauge for anxiety score (0–100%).
class AnxietyScoreRing extends StatefulWidget {
  const AnxietyScoreRing({
    super.key,
    required this.scorePercent,
    this.size = 180,
    this.strokeWidth = 14,
    this.duration = const Duration(milliseconds: 1000),
  });

  final double scorePercent;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<AnxietyScoreRing> createState() => _AnxietyScoreRingState();
}

class _AnxietyScoreRingState extends State<AnxietyScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = Tween<double>(
      begin: 0,
      end: (widget.scorePercent / 100).clamp(0, 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ringColor = colorScheme.primary;
    final displayScore = widget.scorePercent.round();

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _AnxietyRingPainter(
              progress: _progress.value,
              color: ringColor,
              strokeWidth: widget.strokeWidth,
              trackColor: ringColor.withValues(alpha: 0.18),
            ),
            child: Center(child: child),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$displayScore%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  height: 1,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnxietyRingPainter extends CustomPainter {
  _AnxietyRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1),
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_AnxietyRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
