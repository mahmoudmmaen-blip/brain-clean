import 'package:brain_clean_mobile/core/bootstrap/app_hydration_provider.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/core/security/security_status_provider.dart';
import 'package:brain_clean_mobile/features/splash/presentation/splash_screen.dart';
import 'package:brain_clean_mobile/main.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'dart:io';
import 'package:brain_clean_mobile/v3/ui/onboarding/onboarding_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox v3Box;
  late ContentBundle contentBundle;

  setUpAll(() async {
    final repo = ContentRepository(
      assetLoader: (path) => File(path).readAsString(),
    );
    contentBundle = await repo.load();
  });

  setUp(() {
    SplashScreen.minSplashDuration = Duration.zero;
    SplashScreen.enableTypewriterAnimation = false;
    v3Box = InMemoryHiveBox();
  });

  tearDown(() {
    SplashScreen.minSplashDuration = const Duration(seconds: 2);
    SplashScreen.enableTypewriterAnimation = true;
  });

  List<Override> baseOverrides() => [
        appHydrationProvider.overrideWith(_InstantHydration.new),
        biometricLockSettingsProvider.overrideWith(
          () => _WidgetTestBiometricLockSettings(),
        ),
        biometricSessionProvider.overrideWith(() => _UnlockedBiometricSession()),
        localeProvider.overrideWith((ref) => const Locale('en')),
        v3StateRepositoryProvider.overrideWithValue(
          V3StateLocalRepository(box: v3Box),
        ),
        v3ContentProvider.overrideWith((ref) async => contentBundle),
      ];

  Future<void> pumpApp(WidgetTester tester, {List<Override> extra = const []}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...baseOverrides(), ...extra],
        child: const BrainCleanApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> waitForWelcome(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(V3OnboardingKeys.welcomeStart).evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Welcome screen did not appear');
  }

  Future<void> settle(WidgetTester tester, [Duration d = const Duration(milliseconds: 400)]) async {
    await tester.pump();
    await tester.pump(d);
  }

  Future<void> waitForFinder(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for $finder');
  }

  Future<void> tapFirstCheckOption(WidgetTester tester) async {
    await tester.tap(find.byKey(V3OnboardingKeys.checkOption));
    await settle(tester);
  }

  testWidgets('onboarding happy path saves clarity score', (tester) async {
    await pumpApp(tester);
    await waitForWelcome(tester);

    await tester.tap(find.byKey(V3OnboardingKeys.welcomeStart));
    await waitForFinder(tester, find.byKey(V3OnboardingKeys.checkContinue));

    await tester.tap(find.byKey(V3OnboardingKeys.checkContinue));
    await settle(tester);

    await tapFirstCheckOption(tester);
    for (var i = 0; i < 8; i++) {
      await tapFirstCheckOption(tester);
    }
    await waitForFinder(tester, find.byKey(V3OnboardingKeys.setupSubmit));

    await tester.tap(find.byKey(V3OnboardingKeys.setupSubmit));
    await waitForFinder(tester, find.byKey(V3OnboardingKeys.resultStartDay1));

    expect(find.byKey(V3OnboardingKeys.resultStartDay1), findsOneWidget);

    final repo = V3StateLocalRepository(box: v3Box);
    final state = await repo.load();
    expect(state.clarityResults, hasLength(1));
    expect(state.clarityResults.first.score, inInclusiveRange(0, 100));
    expect(state.profile?.onboardingDone, isTrue);
  });

  testWidgets('cold start after onboarding goes to today not welcome', (tester) async {
    final repo = V3StateLocalRepository(box: v3Box);
    await repo.saveProfile(
      UserProfile(
        goal: 'focus',
        reminderTime: '20:00',
        eveningCheckIn: true,
        onboardingDone: true,
        createdAt: DateTime(2026, 1, 1),
        locale: 'en',
      ),
    );

    await pumpApp(tester);
    await waitForFinder(tester, find.byKey(const Key('v3_today_screen')));

    expect(find.byKey(const Key('v3_today_screen')), findsOneWidget);
    expect(find.byKey(V3OnboardingKeys.welcomeStart), findsNothing);
  });
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

class _WidgetTestBiometricLockSettings extends BiometricLockSettings {
  @override
  bool build() => false;

  @override
  Future<void> hydrate() async {}
}

class _UnlockedBiometricSession extends BiometricSession {
  @override
  bool build() => true;
}
