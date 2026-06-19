import 'package:flutter/material.dart';

import '../../domain/diagnostic_model.dart';

/// Severity colors for Dr. Moneam Brain Rot bands (0–10 scale).
abstract final class BrainRotColors {
  static Color forBand(InterpretationBand band) => switch (band) {
        InterpretationBand.mild => const Color(0xFF10B981),
        InterpretationBand.moderate => const Color(0xFFF59E0B),
        InterpretationBand.severe => const Color(0xFFF97316),
        InterpretationBand.critical => const Color(0xFFEF4444),
      };

  static Color forScore(int score) =>
      forBand(DiagnosticModel.getBrainRotBand(score));
}
