import 'package:flutter/material.dart';

/// Bundled offline font families (see [pubspec.yaml] assets/fonts).
abstract final class AppFonts {
  static const inter = 'Inter';
  static const tajawal = 'Tajawal';

  static TextTheme interTextTheme(TextTheme base) =>
      base.apply(fontFamily: inter);

  static TextTheme tajawalTextTheme(TextTheme base) =>
      base.apply(fontFamily: tajawal);

  static TextTheme forLocale(TextTheme base, Locale locale) =>
      locale.languageCode == 'ar' ? tajawalTextTheme(base) : interTextTheme(base);
}
