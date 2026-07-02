import 'package:flutter/material.dart';

import '../../domain/diagnostic_model.dart';

/// Severity colors for Dr. Moneam Brain Rot bands (0–10 scale).
abstract final class BrainRotColors {
  static Color forBand(InterpretationBand band, ColorScheme colorScheme) =>
      switch (band) {
        InterpretationBand.mild => colorScheme.primary,
        InterpretationBand.moderate =>
          Color.lerp(colorScheme.primary, colorScheme.onSurface, 0.35)!,
        InterpretationBand.severe =>
          Color.lerp(colorScheme.primary, colorScheme.error, 0.5)!,
        InterpretationBand.critical => colorScheme.error,
      };

  static Color forScore(int score, ColorScheme colorScheme) =>
      forBand(DiagnosticModel.getBrainRotBand(score), colorScheme);
}
