import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/application/app_preferences_provider.dart';
import 'package:brain_clean_mobile/core/bootstrap/app_hydration_provider.dart';
import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/routing/app_router.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/dashboard/data/daily_snapshots_repository.dart';
import 'package:brain_clean_mobile/features/dashboard/domain/daily_snapshot.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_screen.dart';
import 'package:brain_clean_mobile/features/home/presentation/widgets/global_progress_tracker.dart';
import 'package:brain_clean_mobile/features/onboarding/onboarding_screen.dart';
import 'package:brain_clean_mobile/features/pro/pro_paywall_screen.dart'
    show proPaywallKey;
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_storage_provider.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/hive_test_fixtures.dart';
import 'helpers/localized_test_app.dart';

void main() {
  testWidgets('onboarding skip flow reaches home with BCS ring and emotion card',
      (tester) async {
    final metaBox = InMemoryHiveBox();
    final container = ProviderContainer(
      overrides: [
        appMetaBoxProvider.overrideWithValue(metaBox),
        appHydrationProvider.overrideWith(_InstantHydration.new),
        homeStreakTickerProvider.overrideWith((ref) => Stream<int>.value(0)),
        recoveryProtocolStorageProvider.overrideWithValue(
          RecoveryProtocolMemoryRepository(),
        ),
        ...diagnosticWidgetTestOverrides(),
      ],
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> pumpRouter(GoRouter router) async {
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
    }

    var router = container.read(goRouterProvider);
    await pumpRouter(router);

    router.go(AppRoutes.onboarding);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.byKey(onboardingSkipKey));
    await tester.pumpAndSettle();

    expect(
      metaBox.get(HiveMetaKeys.hasSeenOnboarding, defaultValue: false),
      isTrue,
    );

    // GoRouter was built before onboarding completed — refresh config.
    router = container.read(goRouterProvider);
    await pumpRouter(router);
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(globalProgressTrackerKey), findsOneWidget);
    expect(find.byKey(homeEmotionWheelKey), findsOneWidget);
    expect(find.textContaining('كيف تشعر'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('GlobalProgressTracker clamps BCS display to 0–100', (tester) async {
    await tester.pumpWidget(
      createLocalizedTestWidget(
        const GlobalProgressTracker(
          bcScore: 105,
          challengeProgress: 0,
          hasSession: true,
        ),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 950));

    expect(find.text('100%'), findsOneWidget);

    await tester.pumpWidget(
      createLocalizedTestWidget(
        const GlobalProgressTracker(
          bcScore: -5,
          challengeProgress: 0,
          hasSession: true,
        ),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 950));

    expect(find.text('0%'), findsOneWidget);
  });

  test('DailySnapshotsRepository trims to 7 and removes oldest', () async {
    final box = InMemoryHiveBox();
    final repo = DailySnapshotsRepository(box);
    final base = DateTime(2026, 1, 1);

    for (var i = 0; i < 8; i++) {
      await repo.save(
        DailySnapshot(
          date: base.add(Duration(days: i)),
          bcsValue: 10.0 + i,
        ),
      );
    }

    final all = repo.loadAll();
    expect(all.length, 7);
    expect(all.first.bcsValue, 11);
    expect(all.last.bcsValue, 17);
  });

  testWidgets('non-Pro emotion wheel tap opens paywall from home', (tester) async {
    final metaBox = InMemoryHiveBox();
    final container = ProviderContainer(
      overrides: [
        appMetaBoxProvider.overrideWithValue(metaBox),
        appPreferencesProvider.overrideWith(_FreeUserPreferences.new),
        appHydrationProvider.overrideWith(_InstantHydration.new),
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

    await tester.pump(const Duration(seconds: 3));
  });
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

class _InstantHydration extends AppHydration {
  @override
  Future<AppHydrationSnapshot> build() async {
    return const AppHydrationSnapshot(
      hasCommittedSession: false,
      hasDraftProgress: false,
    );
  }
}
