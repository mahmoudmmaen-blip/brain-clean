import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Brain Clean (light + dark).
abstract final class AppDesignConstants {
  /// Professional dark green — primary brand.
  static const Color brandGreen = Color(0xFF0F5132);

  static const Color brandGreenLight = Color(0xFF198754);
  static const Color brandGreenDark = Color(0xFF0A3D26);
  static const Color brandGreenContainer = Color(0xFFD1E7DD);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF1E2A3A);
  static const Color darkOnSurface = Color(0xFFF8FAFC);

  // Light theme surfaces (high contrast)
  static const Color lightBackground = Color(0xFFF8FAF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD1E7DD);
  static const Color lightOnSurface = Color(0xFF0F172A);

  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentSuccess = Color(0xFF10B981);
  static const Color accentError = Color(0xFFDC2626);

  static const double radiusCard = 14;
  static const double radiusButton = 14;
  static const double minTouchTarget = 48;

  // Typography — Arabic-safe line heights prevent overlap/clipping.
  static const double arabicQuestionFontSize = 22;
  static const double arabicQuestionLineHeight = 1.6;
  static const double arabicBodyLineHeight = 1.55;
  static const double arabicLabelLetterSpacing = 0.3;

  static TextStyle cairo({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = arabicBodyLineHeight,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
