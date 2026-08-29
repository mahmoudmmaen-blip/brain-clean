import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_design_constants.dart';

/// Custom spider / radar chart (0–100 health scores). No fl_chart dependency.
class BriRadarChart extends StatelessWidget {
  const BriRadarChart({
    super.key,
    required this.values,
    required this.labels,
    this.maxValue = 100,
  });

  /// Same length as [labels]; values clamped 0–[maxValue] (higher = healthier).
  final List<double> values;
  final List<String> labels;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    assert(values.length == labels.length && values.length >= 3);
    final palette = AppColors.of(context);
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: CustomPaint(
        painter: _RadarPainter(
          values: values
              .map((v) => v.clamp(0, maxValue).toDouble())
              .toList(growable: false),
          labels: labels,
          maxValue: maxValue,
          primary: AppColors.primary,
          labelColor: palette.textSecondary,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.primary,
    required this.labelColor,
    required this.textDirection,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color primary;
  final Color labelColor;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    final sides = values.length;
    final angleStep = (2 * math.pi) / sides;

    final gridPaint = Paint()
      ..color = primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (var j = 0; j < sides; j++) {
        final angle = j * angleStep - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = primary.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (var i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);

      final labelX = center.dx + (radius + 25) * math.cos(angle);
      final labelY = center.dy + (radius + 25) * math.sin(angle);
      _drawLabel(canvas, labels[i], Offset(labelX, labelY));
    }

    final valuePath = Path();
    for (var i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final r = radius * (values[i] / maxValue);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        valuePath.moveTo(x, y);
      } else {
        valuePath.lineTo(x, y);
      }
    }
    valuePath.close();

    canvas.drawPath(
      valuePath,
      Paint()
        ..color = primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      valuePath,
      Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final dotPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;

    for (var i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final r = radius * (values[i] / maxValue);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: textDirection,
      textAlign: TextAlign.center,
      maxLines: 2,
    )..layout(maxWidth: 88);

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.primary != primary ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.textDirection != textDirection;
  }
}

/// Convenience: BRI axis rot scores → health values for the radar.
List<double> briAxesToHealthValues(List<int> rotScores) {
  return rotScores
      .map((s) => (100 - s).clamp(0, 100).toDouble())
      .toList(growable: false);
}

/// Color for BRI severity (higher BRI = worse).
Color briSeverityColor(int bri) {
  if (bri <= 30) return AppColors.success;
  if (bri <= 60) return AppColors.warning;
  if (bri <= 85) return AppColors.accentOrange;
  return AppColors.danger;
}

/// Soft danger glow when BRI is severe.
class BriSevereGlow extends StatelessWidget {
  const BriSevereGlow({super.key, required this.child, required this.severe});

  final Widget child;
  final bool severe;

  @override
  Widget build(BuildContext context) {
    if (!severe) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
