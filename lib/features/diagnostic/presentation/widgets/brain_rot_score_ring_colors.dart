import 'package:flutter/material.dart';

/// Brain Rot score ring colors (0–10 scale).
abstract final class BrainRotScoreRingColors {
  static const green = Color(0xFF1D9E75);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);

  static Color forScore(int score) {
    if (score <= 3) return green;
    if (score <= 6) return amber;
    return red;
  }
}
