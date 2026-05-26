import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps [child] in a [MaterialApp] with the same localization setup as production.
Widget localizedTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: child,
  );
}

/// Wraps [child] in [ProviderScope] + localized [MaterialApp].
Widget localizedProviderTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: localizedTestApp(child: child, locale: locale),
  );
}
