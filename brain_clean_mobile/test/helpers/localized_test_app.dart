import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wraps [child] in a [MaterialApp] using the same localization setup as production.
///
/// Uses [appLocalizationsDelegates] from production config:
/// - [GlobalMaterialLocalizations.delegate]
/// - [GlobalWidgetsLocalizations.delegate]
/// - [GlobalCupertinoLocalizations.delegate]
/// - [AppLocalizations.delegate]
Widget createLocalizedTestWidget(
  Widget child, {
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    title: 'Brain Clean',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
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
      routerConfig: router,
    ),
  );
}

/// Minimal GoRouter with dashboard → detox routes for navigation widget tests.
GoRouter createDashboardDetoxTestRouter() {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.detox,
        builder: (context, state) => const DetoxProtocolScreen(),
      ),
    ],
  );
}
