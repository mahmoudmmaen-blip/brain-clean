import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';

/// English (LTR) and Arabic (RTL) — matches [AppLocalizations] ARB files.
const List<Locale> supportedLocales = <Locale>[
  Locale('en'),
  Locale('ar'),
];

/// Material, widgets, Cupertino, and app-specific string delegates.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  AppLocalizations.delegate,
];

/// Resolves device locale to a supported locale (falls back to English).
Locale? resolveAppLocale(Locale? locale, Iterable<Locale> supported) {
  if (locale == null) {
    return const Locale('en');
  }
  for (final supportedLocale in supported) {
    if (supportedLocale.languageCode == locale.languageCode) {
      return supportedLocale;
    }
  }
  return const Locale('en');
}
