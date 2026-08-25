import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Brain Clean Pro — semantic color tokens (§6.2 design tokens).
///
/// Static consts remain the **dark** defaults for const/default contexts.
/// Prefer [AppColors.of] in widgets so Dark / Light / AMOLED / Pure White /
/// Warm Beige apply live.
abstract final class AppColors {
  // --- Dark (deeper focus black — §6.2) ---
  static const background = Color(0xFF0A0A0A);
  static const navBar = Color(0xFF0A0A0A);

  /// Alias: surface
  static const surface = Color(0xFF141414);
  static const card = surface;

  /// Alias: surfaceElevated
  static const surfaceElevated = Color(0xFF1E1E1E);
  static const cardSecondary = surfaceElevated;
  static const cardElevated = surfaceElevated;

  /// Frosted glass overlay (15% white).
  static const surfaceGlass = Color(0x26FFFFFF);

  static const border = Color(0xFF2A2A2A);

  /// Mint primary — interactive / neon accents.
  static const primary = Color(0xFF2DD4A8);
  static const primaryDark = Color(0xFF25B892);
  static const primaryDim = Color(0xFF14352C);
  static const onPrimary = Color(0xFF06231A);

  /// Soft mint glow wash (20% opacity).
  static const primaryGlowColor = Color(0x332DD4A8);

  static const gold = Color(0xFFD4A853);
  static const goldDim = Color(0xFF3A2E15);
  static const goldText = Color(0xFFF4D08A);
  static const goldGradient = <Color>[
    Color(0xFFD4A853),
    Color(0xFFB8941F),
  ];

  /// Category accents.
  static const accentPurple = Color(0xFFA78BFA);
  static const accentOrange = Color(0xFFEAB308);
  static const accentPink = Color(0xFFF472B6);
  static const accentBlue = Color(0xFF60A5FA);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB4B4B4);

  /// Alias: textMuted
  static const textMuted = Color(0xFF808080);
  static const textTertiary = textMuted;

  static const ringTrack = Color(0xFF1E1E1E);
  static const success = Color(0xFF22C55E);
  static const positive = success;
  static const danger = Color(0xFFEF4444);
  static const dangerDim = Color(0xFF3A1C22);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF60A5FA);
  static const infoDim = Color(0xFF132433);

  static const heroGradientTop = Color(0xFF141414);
  static const heroGradientBottom = Color(0xFF0A0A0A);

  // --- Light ---
  static const backgroundLight = Color(0xFFF5F0E8);
  static const navBarLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardSecondaryLight = Color(0xFFEEF3F1);
  static const cardElevatedLight = Color(0xFFF7FAF9);
  static const borderLight = Color(0xFFD5E4DF);
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF5B6B78);
  static const textTertiaryLight = Color(0xFF8A9AA5);
  static const ringTrackLight = Color(0xFFDDE8E3);
  static const primaryDimLight = Color(0xFFD7F3E6);
  static const heroGradientTopLight = Color(0xFFF8F3EB);
  static const heroGradientBottomLight = Color(0xFFF5F0E8);

  // --- AMOLED ---
  static const backgroundAmoled = Color(0xFF000000);
  static const cardAmoled = Color(0xFF0A0A0A);
  static const borderAmoled = Color(0xFF1A1A1A);

  // --- Pure White ---
  static const backgroundPureWhite = Color(0xFFFFFFFF);
  static const navBarPureWhite = Color(0xFFFFFFFF);
  static const cardPureWhite = Color(0xFFF7F9F8);
  static const cardSecondaryPureWhite = Color(0xFFEEF3F1);
  static const cardElevatedPureWhite = Color(0xFFFFFFFF);
  static const borderPureWhite = Color(0xFFE2E8E5);
  static const textPrimaryPureWhite = Color(0xFF0F172A);
  static const textSecondaryPureWhite = Color(0xFF5B6B78);
  static const textTertiaryPureWhite = Color(0xFF8A9AA5);
  static const ringTrackPureWhite = Color(0xFFE8EEEA);
  static const primaryDimPureWhite = Color(0xFFD7F3E6);
  static const heroGradientTopPureWhite = Color(0xFFFFFFFF);
  static const heroGradientBottomPureWhite = Color(0xFFF5F7F6);

  // --- Warm Beige ---
  static const backgroundWarmBeige = Color(0xFFF5F0E8);
  static const navBarWarmBeige = Color(0xFFF5F0E8);
  static const cardWarmBeige = Color(0xFFFAF6F0);
  static const cardSecondaryWarmBeige = Color(0xFFEDE6DA);
  static const cardElevatedWarmBeige = Color(0xFFFFFBF5);
  static const borderWarmBeige = Color(0xFFE0D6C8);
  static const textPrimaryWarmBeige = Color(0xFF3D2914);
  static const textSecondaryWarmBeige = Color(0xFF6B5344);
  static const textTertiaryWarmBeige = Color(0xFF8F7A68);
  static const ringTrackWarmBeige = Color(0xFFE8DFD2);
  static const primaryDimWarmBeige = Color(0xFFD7F3E6);
  static const heroGradientTopWarmBeige = Color(0xFFF8F3EB);
  static const heroGradientBottomWarmBeige = Color(0xFFF5F0E8);

  /// Soft mint glow for primary cards (§6.2 shadowGlow).
  static List<BoxShadow> get primaryGlow => const [
        AppDesignShadow.glow,
      ];

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ?? AppPalette.dark;
  }

  static AppPalette fromTheme(ThemeData theme) {
    return theme.extension<AppPalette>() ?? AppPalette.dark;
  }
}

/// Shared glow shadow (kept here to avoid circular imports with design constants).
abstract final class AppDesignShadow {
  static const glow = BoxShadow(
    color: Color(0x1A2DD4A8),
    blurRadius: 24,
    spreadRadius: 4,
  );
}
