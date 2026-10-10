import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wraps [child] in a [MaterialApp] using the same localization setup as production.
Widget createLocalizedTestWidget(
  Widget child, {
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    title: 'Brain Clean',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    locale: locale,
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: child,
  );
}

/// [ProviderScope] + [createLocalizedTestWidget] for Riverpod widget tests.
Widget createLocalizedProviderTestWidget(
  Widget child, {
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: createLocalizedTestWidget(child, locale: locale),
  );
}

/// Localized [MaterialApp.router] for navigation / GoRouter widget tests.
Widget createLocalizedRouterTestWidget({
  required GoRouter router,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: supportedLocales,
      localeResolutionCallback: resolveAppLocale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    ),
  );
}
