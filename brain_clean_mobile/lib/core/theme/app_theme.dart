import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_design_constants.dart';

abstract final class AppTheme {
  static const Color gold = AppDesignConstants.accentGold;
  static const Color success = AppDesignConstants.accentSuccess;

  /// Legacy aliases used across diagnostic widgets.
  static const Color background = AppDesignConstants.darkBackground;
  static const Color surface = AppDesignConstants.darkSurface;
  static const Color border = AppDesignConstants.darkBorder;

  static ThemeData get light {
    const primary = AppDesignConstants.brandGreen;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppDesignConstants.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD1E7DD),
        onPrimaryContainer: AppDesignConstants.brandGreenDark,
        secondary: AppDesignConstants.brandGreenLight,
        onSecondary: Colors.white,
        surface: AppDesignConstants.lightSurface,
        onSurface: AppDesignConstants.lightOnSurface,
        error: AppDesignConstants.accentError,
        onError: Colors.white,
      ),
    );
    return _applyShared(
      base,
      surface: AppDesignConstants.lightSurface,
      border: AppDesignConstants.lightBorder,
      primaryButton: primary,
      appBarBackground: primary,
      appBarForeground: Colors.white,
      sliderActive: primary,
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppDesignConstants.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        onPrimary: AppDesignConstants.darkBackground,
        secondary: success,
        onSecondary: Colors.white,
        surface: AppDesignConstants.darkSurface,
        onSurface: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
    );
    return _applyShared(
      base,
      surface: AppDesignConstants.darkSurface,
      border: AppDesignConstants.darkBorder,
      primaryButton: success,
      appBarBackground: AppDesignConstants.darkBackground,
      appBarForeground: Colors.white,
      sliderActive: gold,
    );
  }

  static ThemeData _applyShared(
    ThemeData base, {
    required Color surface,
    required Color border,
    required Color primaryButton,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color sliderActive,
  }) {
    final isDark = base.brightness == Brightness.dark;
    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: base.colorScheme.onSurface,
      displayColor: base.colorScheme.onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: isDark ? 0 : 0.5,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0 : 0.12),
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarForeground),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: appBarForeground,
          fontWeight: FontWeight.w700,
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
        color: base.colorScheme.primary,
        linearTrackColor: base.colorScheme.onSurface.withValues(alpha: 0.12),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: sliderActive,
        thumbColor: sliderActive,
        inactiveTrackColor: border,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryButton,
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
          foregroundColor: base.colorScheme.onSurface,
          side: BorderSide(color: border, width: 1.5),
          minimumSize: const Size.fromHeight(AppDesignConstants.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDesignConstants.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
        ),
      ),
    );
  }
}
