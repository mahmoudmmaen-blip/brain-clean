import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Central design tokens for Brain Clean — §6.2 (+ legacy aliases).
///
/// Spec name in docs: `AppDesign` → use [AppDesign] typedef below.
abstract final class AppDesignConstants {
  /// Signature mint — primary brand accent (§6.2 primary).
  static const Color brandGreen = Color(0xFF2DD4A8);

  static const Color brandGreenLight = Color(0xFF2DD4A8);
  static const Color brandGreenDark = Color(0xFF14352C);
  static const Color brandGreenContainer = Color(0xFF14352C);

  // Dark theme surfaces (§6.2)
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkNavBar = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceSecondary = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceMuted = Color(0xFFB4B4B4);
  static const Color darkOnSurfaceDim = Color(0xFF808080);

  // Light theme surfaces (high contrast)
  static const Color lightBackground = Color(0xFFF5F0E8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD1E7DD);
  static const Color lightOnSurface = Color(0xFF0F172A);

  static const Color accentGold = Color(0xFFD4A853);
  static const Color accentGoldDim = Color(0xFF3A2E15);
  static const Color accentGoldText = Color(0xFFF4D08A);
  static const Color accentSuccess = Color(0xFF22C55E);
  static const Color accentError = Color(0xFFEF4444);

  // §6.2 radii / padding
  static const double radiusCard = 24;
  static const double radiusHeroCard = 24;
  static const double radiusButton = 16;
  static const double radiusPill = 999;
  static const double radiusChip = radiusPill;
  static const double paddingScreen = 20;
  static const double paddingCard = 24;
  static const double minTouchTarget = 48;

  static const BoxShadow shadowGlow = AppDesignShadow.glow;

  // Premium metric typography
  static const double v2MetricValueSize = 44;
  static const double v2MetricHeroSize = 44;
  static const double v2MetricValueHeight = 1.08;
  static const double v2PageTitleSize = 32;
  static const double v2HeroPad = paddingCard;
  static const double v2InfoPad = paddingCard;

  // V2 shell visual rhythm
  static const double v2PadH = paddingScreen;
  static const double v2PadTop = 16;
  static const double v2PadBottom = 40;
  static const double v2GapInline = 6;
  static const double v2GapTight = 8;
  static const double v2GapControl = 12;
  static const double v2GapSection = 20;
  static const double v2GapMajor = 28;
  static const double v2GapSectionLabel = 8;
  static const double v2NavHeight = 64;

  // Typography scale
  static const double typeH1 = 32;
  static const double typeH2 = 24;
  static const double typeH3 = 18;
  static const double typeBody = 16;
  static const double typeCaption = 14;

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

/// Spec alias for [AppDesignConstants] (§6.2 `AppDesign`).
typedef AppDesign = AppDesignConstants;
