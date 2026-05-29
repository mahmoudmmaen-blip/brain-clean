import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'brain_rot_score_ring_colors.dart';

/// Animated circular score ring (0 → [score] over [duration] on entry).
class BrainRotAnimatedScoreRing extends StatefulWidget {
  const BrainRotAnimatedScoreRing({
    super.key,
    required this.score,
    required this.maxScore,
    this.size = 168,
    this.strokeWidth = 12,
    this.duration = const Duration(milliseconds: 1200),
  });

  final int score;
  final int maxScore;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<BrainRotAnimatedScoreRing> createState() =>
      _BrainRotAnimatedScoreRingState();
}

class _BrainRotAnimatedScoreRingState extends State<BrainRotAnimatedScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = Tween<double>(
      begin: 0,
      end: widget.score / widget.maxScore,
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
    final ringColor = BrainRotScoreRingColors.forScore(widget.score);

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ScoreRingPainter(
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
            '${widget.score}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ringColor,
                  height: 1,
                ),
          ),
          Text(
            '/ ${widget.maxScore}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ringColor.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
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
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.55), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
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
  bool shouldRepaint(_ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
