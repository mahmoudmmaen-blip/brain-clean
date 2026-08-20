import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Brain Clean Pro — semantic color tokens.
///
/// Static consts remain the **dark** defaults for const/default contexts.
/// Prefer [AppColors.of] in widgets so Dark / Light / AMOLED apply live.
abstract final class AppColors {
  // --- Dark (default product mock) ---
  static const background = Color(0xFF0B0F0D);
  static const navBar = Color(0xFF080C0A);
  static const card = Color(0xFF141B17);
  static const cardSecondary = Color(0xFF1B241F);
  static const cardElevated = Color(0xFF1A2620);
  static const border = Color(0xFF233029);

  static const primary = Color(0xFF3FD08C);
  static const primaryDark = Color(0xFF2BB876);
  static const primaryDim = Color(0xFF173627);
  static const onPrimary = Color(0xFF06231A);

  static const gold = Color(0xFFE3B155);
  static const goldDim = Color(0xFF3A2E15);
  static const goldText = Color(0xFFF4D08A);

  static const textPrimary = Color(0xFFEDEFEA);
  static const textSecondary = Color(0xFF8FA098);
  static const textTertiary = Color(0xFF526059);

  static const ringTrack = Color(0xFF1B241F);
  static const positive = Color(0xFF3FD08C);
  static const danger = Color(0xFFE2637A);
  static const dangerDim = Color(0xFF3A1C22);
  static const warning = Color(0xFFE3B155);
  static const info = Color(0xFF5B9FE0);
  static const infoDim = Color(0xFF132433);

  static const heroGradientTop = Color(0xFF17251E);
  static const heroGradientBottom = Color(0xFF101A15);

  // --- Light ---
  static const backgroundLight = Color(0xFFF4F7F6);
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
  static const heroGradientTopLight = Color(0xFFE8F5EF);
  static const heroGradientBottomLight = Color(0xFFF4F7F6);

  // --- AMOLED (pure black surfaces; accents/text match dark) ---
  static const backgroundAmoled = Color(0xFF000000);
  static const cardAmoled = Color(0xFF0A0A0A);
  /// Secondary card / "card2" on AMOLED.
  static const cardSecondaryAmoled = Color(0xFF111111);
  // Remaining AMOLED surface aliases reuse dark tokens via [AppPalette.amoled].

  /// Active palette from [ThemeData.extensions], falling back to dark.
  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ?? AppPalette.dark;
  }

  /// Same as [of] when a [ThemeData] is already available.
  static AppPalette fromTheme(ThemeData theme) {
    return theme.extension<AppPalette>() ?? AppPalette.dark;
  }
}
