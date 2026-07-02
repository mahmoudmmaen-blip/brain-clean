import 'package:flutter/material.dart';

/// Brain Rot score ring colors (0–10 scale).
abstract final class BrainRotScoreRingColors {
  static Color forScore(int score, ColorScheme colorScheme) {
    if (score <= 3) return colorScheme.primary;
    if (score <= 6) {
      return Color.lerp(colorScheme.primary, colorScheme.onSurface, 0.35)!;
    }
    return colorScheme.error;
  }
}
