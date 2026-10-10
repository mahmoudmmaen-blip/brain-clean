import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/v3/application/session_controller.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/program_engine.dart';
import 'package:brain_clean_mobile/v3/ui/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late V3StateLocalRepository repo;
  late ContentBundle bundle;

  setUpAll(() async {
    bundle = await ContentRepository(
      assetLoader: (p) => File(p).readAsString(),
    ).load();
  });

  setUp(() {
    box = InMemoryHiveBox();
    repo = V3StateLocalRepository(box: box);
  });

  Future<void> seedProfile() async {
    await repo.saveProfile(
      UserProfile(
        name: 'Sara',
        goal: 'focus',
        reminderTime: '20:00',
        eveningCheckIn: true,
        onboardingDone: true,
        createdAt: DateTime(2026, 1, 1),
        locale: 'en',
      ),
    );
  }

  List<Override> overrides({bool isPro = false}) => [
        v3StateRepositoryProvider.overrideWithValue(repo),
        v3ContentProvider.overrideWith((ref) async => bundle),
        v3AppStateProvider.overrideWith((ref) => repo.load()),
        isProUserProvider.overrideWith((ref) => isPro),
        localeProvider.overrideWith((ref) => const Locale('en')),
      ];

  Widget wrap(Widget child, {bool isPro = false}) {
    return ProviderScope(
      overrides: overrides(isPro: isPro),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  group('Today hero states', () {
    testWidgets('not started', (tester) async {
      await seedProfile();
      await tester.pumpWidget(wrap(const V3TodayScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_today_hero_notStarted')), findsOneWidget);
      expect(find.byKey(const Key('v3_today_sos')), findsOneWidget);
    });

    testWidgets('in progress', (tester) async {
      await seedProfile();
      await repo.saveDayProgress(
        DayProgress(
          day: 1,
          startedAt: DateTime(2026, 1, 2, 10),
          lessonDone: true,
          practiceDone: false,
          usedEasy: false,
          challengeAccepted: false,
        ),
      );
      await tester.pumpWidget(wrap(const V3TodayScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_today_hero_inProgress')), findsOneWidget);
    });

    testWidgets('done', (tester) async {
      await seedProfile();
      await repo.saveDayProgress(
        DayProgress(
          day: 1,
          startedAt: DateTime(2026, 1, 2, 10),
          lessonDone: true,
          practiceDone: true,
          usedEasy: false,
          challengeAccepted: true,
          completedAt: DateTime(2026, 1, 2, 11),
        ),
      );
      await tester.pumpWidget(
        wrap(V3TodayScreen(nowOverride: DateTime(2026, 1, 2, 12))),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_today_hero_done')), findsOneWidget);
    });

    testWidgets('pro locked on day 8', (tester) async {
      await seedProfile();
      for (var d = 1; d <= 7; d++) {
        await repo.saveDayProgress(
          DayProgress(
            day: d,
            lessonDone: true,
            practiceDone: true,
            usedEasy: false,
            challengeAccepted: true,
            completedAt: DateTime(2026, 1, d),
          ),
        );
      }
      await tester.pumpWidget(
        wrap(
          V3TodayScreen(nowOverride: DateTime(2026, 1, 8, 10)),
          isPro: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_today_hero_proLocked')), findsOneWidget);
    });
  });

  group('session completion rules', () {
    test('easy version counts as complete', () async {
      await seedProfile();
      final container = ProviderContainer(
        overrides: [
          v3StateRepositoryProvider.overrideWithValue(repo),
          v3AppStateProvider.overrideWith((ref) => repo.load()),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(sessionControllerProvider(1).notifier);
      await ctrl.completeLesson();
      await ctrl.markEasyUsed();
      final ok = await ctrl.finishDay(now: DateTime(2026, 1, 2, 20));
      expect(ok, isTrue);

      final state = await repo.load();
      expect(ProgramEngine.isDayCompleted(state.progressForDay(1)!), isTrue);
      expect(state.progressForDay(1)!.usedEasy, isTrue);
    });

    test('skipping practice without easy does not complete day', () async {
      await seedProfile();
      final container = ProviderContainer(
        overrides: [
          v3StateRepositoryProvider.overrideWithValue(repo),
          v3AppStateProvider.overrideWith((ref) => repo.load()),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(sessionControllerProvider(1).notifier);
      await ctrl.completeLesson();
      await ctrl.skipPractice();
      final ok = await ctrl.finishDay(now: DateTime(2026, 1, 2, 20));
      expect(ok, isFalse);
    });

    test('next day unlocks only after local midnight', () async {
      await seedProfile();
      await repo.saveDayProgress(
        DayProgress(
          day: 1,
          lessonDone: true,
          practiceDone: true,
          usedEasy: false,
          challengeAccepted: true,
          completedAt: DateTime(2026, 1, 2, 18, 30),
        ),
      );
      final progress = (await repo.load()).dayProgress;
      expect(
        ProgramEngine.isDayUnlocked(
          day: 2,
          now: DateTime(2026, 1, 2, 23, 0),
          progress: progress,
        ),
        isFalse,
      );
      expect(
        ProgramEngine.isDayUnlocked(
          day: 2,
          now: DateTime(2026, 1, 3, 0, 0),
          progress: progress,
        ),
        isTrue,
      );
    });

    test('day 7 has clarityCheck flag in program content', () {
      final day7 = bundle.program.dayByNumber(7)!;
      expect(day7.clarityCheck, isTrue);
    });
  });
}
