import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/locale_provider.dart';
import 'app_theme.dart';

/// Locale-aware light/dark themes (Tajawal for AR, Inter for EN).
abstract final class LocaleTheme {
  static ThemeData themed({
    required Brightness brightness,
    required Locale locale,
  }) {
    final base = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
    final isArabic = locale.languageCode == 'ar';
    final textTheme = isArabic
        ? GoogleFonts.tajawalTextTheme(base.textTheme)
        : GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: base.appBarTheme.titleTextStyle?.color,
        ),
      ),
    );
  }
}
