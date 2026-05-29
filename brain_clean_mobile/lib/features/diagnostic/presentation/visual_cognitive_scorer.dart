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

  static Color resultColor(int totalScore) {
    if (totalScore >= 13) return const Color(0xFF1D9E75);
    if (totalScore >= 9) return const Color(0xFF3B82F6);
    if (totalScore >= 5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  static double cognitiveBonus(int totalScore) =>
      (totalScore / 15 * 10).roundToDouble();
}
