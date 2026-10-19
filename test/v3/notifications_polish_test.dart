import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'dart:io';

import 'package:brain_clean_mobile/v3/application/trial_status_provider.dart';
import 'package:brain_clean_mobile/v3/application/usage_providers.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/data/clarity_result.dart';
import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/data/usage_data_source.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/notification_plan.dart';
import 'package:brain_clean_mobile/v3/domain/trial_status.dart';
import 'package:brain_clean_mobile/v3/domain/western_digits.dart';
import 'package:brain_clean_mobile/v3/routing/v3_startup.dart';
import 'package:brain_clean_mobile/v3/ui/migration/migration_screen.dart';
import 'package:brain_clean_mobile/v3/ui/paywall/v3_paywall_screen.dart';
import 'package:brain_clean_mobile/v3/ui/progress/progress_screen.dart';
import 'package:brain_clean_mobile/v3/ui/session/session_player_screen.dart';
import 'package:brain_clean_mobile/v3/ui/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

UserProfile _profile() => UserProfile(
      goal: 'focus',
      reminderTime: '20:00',
      eveningCheckIn: true,
      onboardingDone: true,
      createdAt: DateTime(2026, 1, 1),
      locale: 'ar',
    );

DayProgress _doneDay(int day) => DayProgress(
      day: day,
      lessonDone: true,
      practiceDone: true,
      usedEasy: false,
      challengeAccepted: false,
      completedAt: DateTime(2026, 1, day),
    );

void main() {
  late ContentBundle bundle;

  setUpAll(() async {
    final contentRepo = ContentRepository(
      assetLoader: (p) => File(p).readAsString(),
    );
    bundle = await contentRepo.load();
  });

  test('reminder skipped when today done', () {
    final plan = V3NotificationPlan.build(
      now: DateTime(2026, 1, 10, 12),
      currentDay: 5,
      programFinished: false,
      todayDone: true,
      eveningEnabled: true,
      eveningDoneToday: false,
      isClarityRecheckDay: false,
      clarityDoneForCurrentDay: false,
      reminderHour: 20,
      reminderMinute: 0,
    );
    expect(plan.every((p) => p.kind != V3NotificationKind.dailyReminder), isTrue);
    expect(plan.length, 1);
    expect(plan.single.kind, V3NotificationKind.eveningCheckIn);
  });

  test('max 2 notifications per day', () {
    final plan = V3NotificationPlan.build(
      now: DateTime(2026, 1, 7, 9),
      currentDay: 7,
      programFinished: false,
      todayDone: false,
      eveningEnabled: true,
      eveningDoneToday: false,
      isClarityRecheckDay: true,
      clarityDoneForCurrentDay: false,
      reminderHour: 20,
      reminderMinute: 0,
    );
    expect(plan.length, lessThanOrEqualTo(2));
    expect(plan.length, 2);
    expect(plan.first.kind, V3NotificationKind.clarityRecheck);
    expect(plan.last.kind, V3NotificationKind.eveningCheckIn);
  });

  test('migration once via meta flag', () async {
    final meta = InMemoryHiveBox();
    expect(
      await shouldShowV3Migration(metaBox: meta, legacyBoxesOverride: true),
      isTrue,
    );
    await meta.put(HiveMetaKeys.v3MigrationCompleted, true);
    expect(
      await shouldShowV3Migration(metaBox: meta, legacyBoxesOverride: true),
      isFalse,
    );
    expect(
      V3Startup.afterSplash(onboardingDone: false, showMigration: true),
      '/migration',
    );
    expect(
      V3Startup.afterSplash(onboardingDone: false, showMigration: false),
      '/welcome',
    );
  });

  test('after-day-30 restart keeps ClarityResults', () async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile());
    for (var d = 1; d <= 30; d++) {
      await repo.saveDayProgress(_doneDay(d));
    }
    await repo.appendClarityResult(
      ClarityResult(
        takenAt: DateTime(2026, 1, 1),
        programDay: 1,
        score: 40,
        areas: const ClarityAreaScores(
          focus: 10,
          control: 10,
          sleep: 10,
          calm: 10,
        ),
        hoursEstimate: 5,
        answers: const {},
      ),
    );
    await repo.appendClarityResult(
      ClarityResult(
        takenAt: DateTime(2026, 1, 30),
        programDay: 30,
        score: 70,
        areas: const ClarityAreaScores(
          focus: 18,
          control: 17,
          sleep: 17,
          calm: 18,
        ),
        hoursEstimate: 3,
        answers: const {},
      ),
    );

    final before = await repo.load();
    expect(before.dayProgress.length, 30);
    expect(before.clarityResults.length, 2);

    await repo.clearDayProgressOnly();
    final after = await repo.load();
    expect(after.dayProgress, isEmpty);
    expect(after.clarityResults.length, 2);
    expect(after.clarityResults.last.score, 70);
    expect(after.profile?.onboardingDone, isTrue);
  });

  testWidgets('after-day-30 Today state', (tester) async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile());
    for (var d = 1; d <= 30; d++) {
      await repo.saveDayProgress(_doneDay(d));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v3StateRepositoryProvider.overrideWithValue(repo),
          v3ContentProvider.overrideWith((ref) async => bundle),
          usageDataSourceProvider.overrideWithValue(
            FakeUsageDataSource(hasAccessValue: false),
          ),
          isProUserProvider.overrideWith((ref) => true),
          trialStatusProvider.overrideWith(
            (ref) async => const TrialStatus(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          home: V3TodayScreen(
            nowOverride: DateTime(2026, 2, 1, 10),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_today_after_program')), findsOneWidget);
    expect(find.byKey(const Key('v3_today_after_tools')), findsOneWidget);
    expect(find.byKey(const Key('v3_today_after_restart')), findsOneWidget);
  });

  test('Western digits stay 0-9 in Arabic locale helpers', () {
    expect(WesternDigits.formatInt(30), '30');
    expect(WesternDigits.formatNumber(6.5), '6.5');
    expect(WesternDigits.formatDate(DateTime(2026, 1, 9)), '2026-01-09');
    expect(RegExp(r'[٠-٩]').hasMatch(WesternDigits.formatInt(123)), isFalse);
  });

  testWidgets('Today/Session/Paywall/Progress no overflow at textScale 1.3',
      (tester) async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile());
    await repo.saveDayProgress(_doneDay(1));

    Future<void> pumpScreen(Widget home) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            v3StateRepositoryProvider.overrideWithValue(repo),
            v3ContentProvider.overrideWith((ref) async => bundle),
            usageDataSourceProvider.overrideWithValue(
              FakeUsageDataSource(hasAccessValue: false),
            ),
            isProUserProvider.overrideWith((ref) => true),
            trialStatusProvider.overrideWith(
              (ref) async => const TrialStatus(),
            ),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: MaterialApp(
              locale: const Locale('ar'),
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: supportedLocales,
              home: home,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }

    await pumpScreen(
      V3TodayScreen(nowOverride: DateTime(2026, 1, 2, 10)),
    );
    await pumpScreen(const V3SessionPlayerScreen(day: 1));
    await pumpScreen(const V3PaywallScreen(source: 'settings'));
    await pumpScreen(const V3ProgressScreen());
  });
}
