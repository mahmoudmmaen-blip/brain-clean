import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/data/evening_check_in.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/ui/today/today_screen.dart';
import 'package:brain_clean_mobile/v3/ui/tools/tools_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late V3StateLocalRepository repo;
  late ContentBundle bundle;
  late ContentRepository contentRepo;

  setUpAll(() async {
    contentRepo = ContentRepository(
      assetLoader: (p) => File(p).readAsString(),
    );
    bundle = await contentRepo.load();
  });

  setUp(() {
    box = InMemoryHiveBox();
    repo = V3StateLocalRepository(box: box);
  });

  Future<void> seedProfile({String goal = 'focus'}) async {
    await repo.saveProfile(
      UserProfile(
        name: 'Sara',
        goal: goal,
        reminderTime: '20:00',
        eveningCheckIn: true,
        onboardingDone: true,
        createdAt: DateTime(2026, 1, 1),
        locale: 'en',
      ),
    );
  }

  Future<void> seedCompletedDays(int count) async {
    for (var d = 1; d <= count; d++) {
      await repo.saveDayProgress(
        DayProgress(
          day: d,
          lessonDone: true,
          practiceDone: true,
          usedEasy: false,
          challengeAccepted: true,
          completedAt: DateTime(2026, 1, d, 12),
        ),
      );
    }
  }

  List<Override> overrides({bool isPro = true}) => [
        v3StateRepositoryProvider.overrideWithValue(repo),
        v3ContentProvider.overrideWith((ref) async => bundle),
        v3AppStateProvider.overrideWith((ref) => repo.load()),
        isProUserProvider.overrideWith((ref) => isPro),
        localeProvider.overrideWith((ref) => const Locale('en')),
      ];

  Widget wrap(Widget child, {bool isPro = true, Size? surfaceSize}) {
    final app = ProviderScope(
      overrides: overrides(isPro: isPro),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        home: child,
      ),
    );
    if (surfaceSize == null) return app;
    return MediaQuery(
      data: MediaQueryData(size: surfaceSize),
      child: app,
    );
  }

  testWidgets('hero shows days practiced count from seeded data',
      (tester) async {
    await seedProfile();
    await seedCompletedDays(3);
    await tester.pumpWidget(
      wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 4, 10))),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('v3_today_days_practiced')), findsOneWidget);
    expect(find.textContaining('3 training days'), findsOneWidget);
  });

  testWidgets('exactly one primary button in the hero card', (tester) async {
    await seedProfile();
    await tester.pumpWidget(
      wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 1, 10))),
    );
    await tester.pumpAndSettle();

    final hero = find.byKey(const Key('v3_today_hero_notStarted'));
    expect(hero, findsOneWidget);
    expect(
      find.descendant(of: hero, matching: find.byType(FilledButton)),
      findsOneWidget,
    );
    expect(find.byKey(const Key('v3_today_hero_cta')), findsOneWidget);
  });

  testWidgets('SOS button visible without scrolling on 360x640',
      (tester) async {
    await seedProfile();
    await seedCompletedDays(2);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        V3TodayScreen(nowOverride: DateTime(2026, 1, 3, 10)),
        surfaceSize: const Size(360, 640),
      ),
    );
    await tester.pumpAndSettle();

    final sos = find.byKey(const Key('v3_today_sos'));
    expect(sos, findsOneWidget);
    expect(tester.getRect(sos).bottom, lessThanOrEqualTo(640));
    // Visible in viewport without scrolling the list.
    expect(tester.getRect(sos).top, lessThan(640));
    expect(tester.getRect(sos).top, greaterThan(0));
  });

  testWidgets('evening slot locked at 10:00', (tester) async {
    await seedProfile();
    await tester.pumpWidget(
      wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 1, 10))),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_today_evening_locked')), findsOneWidget);
    expect(find.textContaining('after 6 PM'), findsOneWidget);
  });

  testWidgets('evening slot open at 19:00', (tester) async {
    await seedProfile();
    await tester.pumpWidget(
      wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 1, 19))),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_today_evening_open')), findsOneWidget);
    expect(find.text('How was your day?'), findsOneWidget);
  });

  testWidgets('evening slot done after check-in', (tester) async {
    await seedProfile();
    await repo.appendEveningCheckIn(
      EveningCheckIn(
        date: '2026-01-01',
        mood: 4,
        challenge: EveningChallengeAnswer.yes,
      ),
    );
    await tester.pumpWidget(
      wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 1, 19))),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_today_evening_done')), findsOneWidget);
    expect(find.textContaining('logged your review'), findsOneWidget);
  });

  test('goal tip for each goal and week (ar + en)', () async {
    const goals = ['focus', 'sleep', 'less_scroll', 'calm'];
    for (final goal in goals) {
      for (var week = 1; week <= 4; week++) {
        final en = await contentRepo.goalTip(goal, week, locale: 'en');
        final ar = await contentRepo.goalTip(goal, week, locale: 'ar');
        expect(en, isNotEmpty, reason: '$goal w$week en');
        expect(ar, isNotEmpty, reason: '$goal w$week ar');
        expect(en, isNot(equals(ar)), reason: '$goal w$week bilingual');
      }
    }

    // browse (stored profile value) maps to less_scroll tips.
    final browseEn = await contentRepo.goalTip('browse', 2, locale: 'en');
    final lessEn = await contentRepo.goalTip('less_scroll', 2, locale: 'en');
    expect(browseEn, lessEn);

    // Unknown goal falls back to less_scroll.
    final unknown = await contentRepo.goalTip('unknown_goal', 1, locale: 'en');
    final fallback = await contentRepo.goalTip('less_scroll', 1, locale: 'en');
    expect(unknown, fallback);
  });

  testWidgets('goal tip card shows on Today for profile goal', (tester) async {
    await seedProfile(goal: 'sleep');
    await tester.pumpWidget(
      wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 1, 10))),
    );
    await tester.pumpAndSettle();
    // Day 1 → week 1 tip for sleep goal (may sit below the fold).
    final tip = find.byKey(const Key('v3_today_goal_tip'));
    await tester.scrollUntilVisible(
      tip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final expected = await contentRepo.goalTip('sleep', 1, locale: 'en');
    expect(tip, findsOneWidget);
    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('no games section in Tools', (tester) async {
    await tester.pumpWidget(wrap(const V3ToolsScreen()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_tools_game_nback')), findsNothing);
    expect(find.byKey(const Key('v3_tools_game_number')), findsNothing);
    expect(find.byKey(const Key('v3_tools_game_color')), findsNothing);
    expect(find.byKey(const Key('v3_tools_game_pattern')), findsNothing);
    expect(find.text('Brain games'), findsNothing);
  });
}
