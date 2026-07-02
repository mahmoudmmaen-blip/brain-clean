import 'package:flutter/material.dart';

/// Scoring rules for the visual cognitive odd-one-out test.
abstract final class VisualCognitiveScorer {
  static int scoreCorrectTap({required double tapTimeSeconds}) {
    if (tapTimeSeconds <= 1.0) return 3;
    return 1;
  }

  static int scoreWrongTap() => 0;

  static int scoreTimeout() => 0;

  static String resultMessage(int totalScore) {
    if (totalScore >= 13) return 'تركيزك حاد جداً 🧠';
    if (totalScore >= 9) return 'تركيزك جيد ✅';
    if (totalScore >= 5) return 'تركيزك متوسط ⚠️';
    return 'تركيزك يحتاج تحسيناً 🔴';
  }

  static Color resultColor(int totalScore, ColorScheme colorScheme) {
    if (totalScore >= 13) return colorScheme.primary;
    if (totalScore >= 9) {
      return Color.lerp(colorScheme.primary, colorScheme.onSurface, 0.35)!;
    }
    if (totalScore >= 5) {
      return Color.lerp(colorScheme.primary, colorScheme.error, 0.5)!;
    }
    return colorScheme.error;
  }

  static double cognitiveBonus(int totalScore) =>
      (totalScore / 15 * 10).roundToDouble();
}
