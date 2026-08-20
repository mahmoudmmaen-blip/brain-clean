import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_theme.dart';
import 'app_colors.dart';
import 'app_palette.dart';

class LocaleTheme {
  static ThemeData themed({
    required Locale locale,
    required AppColorTheme theme,
  }) {
    final brightness = theme.brightness;
    final isLight = theme == AppColorTheme.light;
    final palette = AppPalette.forTheme(theme);
    final primary = AppColors.primary;
    final baseTextTheme =
        isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme;

    final colorScheme = isLight
        ? ColorScheme.light(
            background: palette.background,
            surface: palette.card,
            primary: primary,
            onPrimary: AppColors.onPrimary,
            primaryContainer: palette.primaryDim,
            secondary: AppColors.gold,
            onSecondary: AppColors.goldText,
            outline: palette.border,
            onSurface: palette.textPrimary,
            onBackground: palette.textPrimary,
          )
        : ColorScheme.dark(
            background: palette.background,
            surface: palette.card,
            primary: primary,
            onPrimary: AppColors.onPrimary,
            primaryContainer: palette.primaryDim,
            secondary: AppColors.gold,
            onSecondary: AppColors.goldText,
            outline: palette.border,
            onSurface: palette.textPrimary,
            onBackground: palette.textPrimary,
          );

    final typedText = locale.languageCode == 'ar'
        ? GoogleFonts.tajawalTextTheme(baseTextTheme)
        : GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[palette],
      textTheme: typedText.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      cardColor: palette.card,
      dividerColor: palette.border,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.navBar,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? primary : palette.textTertiary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: selected ? 22 : 20,
            color: selected ? primary : palette.textTertiary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: palette.border, width: 1),
        ),
        color: palette.card,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.border),
        ),
      ),
    );
  }

  static BoxShadow get premiumShadow => BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
}
