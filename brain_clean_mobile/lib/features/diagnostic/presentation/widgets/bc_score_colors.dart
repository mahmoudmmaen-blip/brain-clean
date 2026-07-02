import 'package:flutter/material.dart';

/// Score-tier colors shared across diagnostic and dashboard UI.
abstract final class BcScoreColors {
  static Color forScore(double score, ColorScheme colorScheme) {
    if (score <= 30) return colorScheme.error;
    if (score <= 60) return colorScheme.primary;
    if (score <= 85) return colorScheme.primary;
    return Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
  }
}
