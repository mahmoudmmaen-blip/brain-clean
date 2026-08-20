import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Brain Clean — aligned with Pro HTML mock.
abstract final class AppDesignConstants {
  /// Signature mint — primary brand accent (#3FD08C).
  static const Color brandGreen = Color(0xFF3FD08C);

  static const Color brandGreenLight = Color(0xFF3FD08C);
  static const Color brandGreenDark = Color(0xFF173627);
  static const Color brandGreenContainer = Color(0xFF173627);

  // Dark theme surfaces — Pro mock canvas.
  static const Color darkBackground = Color(0xFF0B0F0D);
  static const Color darkNavBar = Color(0xFF080C0A);
  static const Color darkSurface = Color(0xFF141B17);
  static const Color darkSurfaceSecondary = Color(0xFF1B241F);
  static const Color darkBorder = Color(0xFF233029);
  static const Color darkOnSurface = Color(0xFFEDEFEA);
  static const Color darkOnSurfaceMuted = Color(0xFF8FA098);
  static const Color darkOnSurfaceDim = Color(0xFF526059);

  // Light theme surfaces (high contrast)
  static const Color lightBackground = Color(0xFFF8FAF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD1E7DD);
  static const Color lightOnSurface = Color(0xFF0F172A);

  static const Color accentGold = Color(0xFFE3B155);
  static const Color accentGoldDim = Color(0xFF3A2E15);
  static const Color accentGoldText = Color(0xFFF4D08A);
  static const Color accentSuccess = Color(0xFF3FD08C);
  static const Color accentError = Color(0xFFE2637A);

  static const double radiusCard = 18;
  static const double radiusHeroCard = 22;
  static const double radiusButton = 14;
  static const double radiusChip = 12;
  static const double minTouchTarget = 48;

  // Premium metric typography (Health/Fitness-inspired hierarchy).
  static const double v2MetricValueSize = 44;
  static const double v2MetricHeroSize = 44;
  static const double v2MetricValueHeight = 1.08;
  static const double v2PageTitleSize = 28;
  static const double v2HeroPad = 22;
  static const double v2InfoPad = 18;

  // V2 shell visual rhythm — shared across Today / Program / Progress / Profile.
  static const double v2PadH = 24;
  static const double v2PadTop = 16;
  static const double v2PadBottom = 40;
  static const double v2GapInline = 6;
  static const double v2GapTight = 8;
  static const double v2GapControl = 12;
  static const double v2GapSection = 20;
  static const double v2GapMajor = 28;
  static const double v2GapSectionLabel = 8;
  static const double v2NavHeight = 64;

  // Typography — Arabic-safe line heights prevent overlap/clipping.
  static const double arabicQuestionFontSize = 22;
  static const double arabicQuestionLineHeight = 1.6;
  static const double arabicBodyLineHeight = 1.55;
  static const double arabicLabelLetterSpacing = 0.3;

  static TextStyle tajawal({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = arabicBodyLineHeight,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.tajawal(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Legacy alias — prefer [tajawal] for Arabic UI.
  static TextStyle cairo({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = arabicBodyLineHeight,
    double letterSpacing = 0,
  }) =>
      tajawal(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}
