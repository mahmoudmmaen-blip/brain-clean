import 'package:brain_clean_mobile/core/application/app_preferences_provider.dart';
import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/routing/app_router.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_screen.dart';
import 'package:brain_clean_mobile/features/onboarding/onboarding_screen.dart';
import 'package:brain_clean_mobile/features/pro/pro_paywall_screen.dart' show proPaywallKey;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_storage_provider.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_streak_provider.dart';
import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/hive_test_fixtures.dart';

void main() {
  testWidgets('router redirects to onboarding when hasSeenOnboarding is false',
      (tester) async {
    final metaBox = InMemoryHiveBox();
    final container = ProviderContainer(
      overrides: [
        appMetaBoxProvider.overrideWithValue(metaBox),
        appPreferencesProvider.overrideWith(_NeverSeenOnboarding.new),
        homeStreakTickerProvider.overrideWith((ref) => Stream<int>.value(0)),
        recoveryProtocolStorageProvider.overrideWithValue(
          RecoveryProtocolMemoryRepository(),
        ),
        ...diagnosticWidgetTestOverrides(),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('ar'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          localeResolutionCallback: resolveAppLocale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );

    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('OnboardingScreen shows PageView and skip button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(onboardingPageViewKey), findsOneWidget);
    expect(find.byKey(onboardingSkipKey), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('non-Pro user tapping emotion wheel opens paywall', (tester) async {
    final metaBox = InMemoryHiveBox();
    final container = ProviderContainer(
      overrides: [
        appMetaBoxProvider.overrideWithValue(metaBox),
        appPreferencesProvider.overrideWith(_FreeUserPreferences.new),
        homeStreakTickerProvider.overrideWith((ref) => Stream<int>.value(0)),
        recoveryProtocolStorageProvider.overrideWithValue(
          RecoveryProtocolMemoryRepository(),
        ),
        ...diagnosticWidgetTestOverrides(),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('ar'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          localeResolutionCallback: resolveAppLocale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );

    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(homeEmotionWheelKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(proPaywallKey), findsOneWidget);
  });
}

class _NeverSeenOnboarding extends AppPreferences {
  @override
  AppPreferencesState build() => AppPreferencesState.firstLaunch;
}

class _FreeUserPreferences extends AppPreferences {
  @override
  AppPreferencesState build() => const AppPreferencesState(
        hasSeenOnboarding: true,
        isProUser: false,
        emotionNotificationsEnabled: true,
        dailyFocusReminderEnabled: true,
        profileDisplayName: '',
        silenceWinsCount: 0,
        singleTasksCompletedCount: 0,
      );
}
