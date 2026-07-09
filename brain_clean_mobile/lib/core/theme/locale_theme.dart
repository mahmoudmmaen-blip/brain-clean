import 'package:flutter/material.dart';

import 'app_color_theme.dart';

class LocaleTheme {
  static ThemeData themed({
    required Locale locale,
    required AppColorTheme theme,
  }) {
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    final primary = theme.accent;
    final onSurface =
        isDark ? const Color(0xFFE6EDF3) : const Color(0xFF0F172A);
    final onSurfaceVariant =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final border =
        isDark ? const Color(0xFF232D38) : const Color(0xFFE2E8F0);
    final fontFamily =
        locale.languageCode == 'ar' ? 'IBM Plex Sans Arabic' : 'Roboto';

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: theme.background,
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        onSecondary: Colors.white,
        surface: theme.surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: border,
      ),
    );

    final textTheme = base.textTheme.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
      fontFamily: fontFamily,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: theme.background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onSurfaceVariant),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
          height: 1.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.surface,
      ),
      dividerColor: border,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: onSurface.withValues(alpha: 0.12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.55), width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static BoxShadow get premiumShadow => BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
}
