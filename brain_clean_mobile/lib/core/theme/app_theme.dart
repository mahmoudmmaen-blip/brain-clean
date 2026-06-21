import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_design_constants.dart';

abstract final class AppTheme {
  static const Color gold = AppDesignConstants.accentGold;
  static const Color success = AppDesignConstants.accentSuccess;
  static const Color brandGreen = AppDesignConstants.brandGreen;

  /// Legacy aliases used across diagnostic widgets.
  static const Color background = AppDesignConstants.darkBackground;
  static const Color surface = AppDesignConstants.darkSurface;
  static const Color border = AppDesignConstants.darkBorder;

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        scaffold: AppDesignConstants.lightBackground,
        surface: AppDesignConstants.lightSurface,
        border: AppDesignConstants.lightBorder,
        onSurface: AppDesignConstants.lightOnSurface,
        primary: AppDesignConstants.brandGreen,
        onPrimary: Colors.white,
        primaryContainer: AppDesignConstants.brandGreenContainer,
        onPrimaryContainer: AppDesignConstants.brandGreenDark,
        secondary: AppDesignConstants.brandGreenLight,
        appBarBg: AppDesignConstants.brandGreen,
        appBarFg: Colors.white,
        sliderActive: AppDesignConstants.brandGreen,
        filledButton: AppDesignConstants.brandGreen,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        scaffold: AppDesignConstants.darkBackground,
        surface: AppDesignConstants.darkSurface,
        border: AppDesignConstants.darkBorder,
        onSurface: AppDesignConstants.darkOnSurface,
        primary: AppDesignConstants.brandGreenLight,
        onPrimary: AppDesignConstants.darkBackground,
        primaryContainer: AppDesignConstants.brandGreenDark,
        onPrimaryContainer: Colors.white,
        secondary: AppDesignConstants.accentSuccess,
        appBarBg: AppDesignConstants.brandGreenDark,
        appBarFg: Colors.white,
        sliderActive: AppDesignConstants.brandGreenLight,
        filledButton: AppDesignConstants.brandGreen,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color border,
    required Color onSurface,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color appBarBg,
    required Color appBarFg,
    required Color sliderActive,
    required Color filledButton,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = (isDark ? const ColorScheme.dark() : const ColorScheme.light())
        .copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: Colors.white,
      error: AppDesignConstants.accentError,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
    );

    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: isDark ? 0 : 0.5,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0 : 0.12),
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarFg),
        titleTextStyle: AppDesignConstants.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: appBarFg,
          height: 1.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1.5,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          side: BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: onSurface.withValues(alpha: 0.12),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: sliderActive,
        thumbColor: sliderActive,
        inactiveTrackColor: border,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: filledButton,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppDesignConstants.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDesignConstants.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.55), width: 1.5),
          minimumSize: const Size.fromHeight(AppDesignConstants.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDesignConstants.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
    );
  }
}
