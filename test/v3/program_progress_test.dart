import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/data/clarity_result.dart';
import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/data/focus_log.dart';
import 'package:brain_clean_mobile/v3/data/sos_log.dart';
import 'package:brain_clean_mobile/v3/data/user_inputs.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/program_day_tile.dart';
import 'package:brain_clean_mobile/v3/domain/program_engine.dart';
import 'package:brain_clean_mobile/v3/domain/progress_calendar.dart';
import 'package:brain_clean_mobile/v3/domain/progress_stats.dart';
import 'package:brain_clean_mobile/v3/ui/program/program_day_review_screen.dart';
import 'package:brain_clean_mobile/v3/ui/program/program_screen.dart';
import 'package:brain_clean_mobile/v3/ui/progress/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/hive_test_fixtures.dart';

DayProgress _done(int day, DateTime at, {bool challengeDone = false}) {
  return DayProgress(
    day: day,
    startedAt: at,
    lessonDone: true,
    practiceDone: true,
    usedEasy: false,
    challengeAccepted: true,
    challengeDone: challengeDone,
    completedAt: at,
  );
}

ClarityResult _clarity(int day, int score, double hours) {
  return ClarityResult(
    takenAt: DateTime(2026, 1, day),
    programDay: day,
    score: score,
    areas: const ClarityAreaScores(focus: 1, control: 1, sleep: 1, calm: 1),
    hoursEstimate: hours,
    answers: const {},
  );
}

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

  Future<void> seedProfile({String locale = 'en'}) async {
    await repo.saveProfile(
      UserProfile(
        name: 'Sara',
        goal: 'focus',
        reminderTime: '20:00',
        eveningCheckIn: true,
        onboardingDone: true,
        createdAt: DateTime(2026, 1, 1),
        locale: locale,
      ),
    );
  }

  List<Override> overrides({
    bool isPro = false,
    Locale locale = const Locale('en'),
  }) =>
      [
        v3StateRepositoryProvider.overrideWithValue(repo),
        v3ContentProvider.overrideWith((ref) async => bundle),
        v3AppStateProvider.overrideWith((ref) => repo.load()),
        isProUserProvider.overrideWith((ref) => isPro),
        localeProvider.overrideWith((ref) => locale),
      ];

  Widget wrap(
    Widget child, {
    bool isPro = false,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: overrides(isPro: isPro, locale: locale),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  Widget wrapWithRouter(
    Widget home, {
    bool isPro = false,
    Locale locale = const Locale('en'),
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => home),
        GoRoute(
          path: '/program/day/:n',
          builder: (context, state) {
            final day = int.tryParse(state.pathParameters['n'] ?? '1') ?? 1;
            return V3ProgramDayReviewScreen(day: day);
          },
        ),
        GoRoute(
          path: '/paywall',
          builder: (_, __) => const Scaffold(
            body: Text('paywall', key: Key('test_paywall')),
          ),
        ),
        GoRoute(
          path: '/session/:n',
          builder: (_, __) => const Scaffold(body: Text('session')),
        ),
        GoRoute(
          path: '/today',
          builder: (_, __) => const Scaffold(body: Text('today')),
        ),
      ],
    );
    return ProviderScope(
      overrides: overrides(isPro: isPro, locale: locale),
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }

  group('ProgramDayTile states', () {
    test('done / today / future / Pro-locked / Pro-unlocked', () {
      final progress = [
        _done(1, DateTime(2026, 1, 1)),
        _done(2, DateTime(2026, 1, 2)),
        _done(3, DateTime(2026, 1, 3)),
        _done(4, DateTime(2026, 1, 4)),
        _done(5, DateTime(2026, 1, 5)),
        _done(6, DateTime(2026, 1, 6)),
        _done(7, DateTime(2026, 1, 7)),
      ];
      final now = DateTime(2026, 1, 8, 10);

      expect(
        ProgramDayTile.state(
          day: 1,
          progress: progress,
          now: now,
          isPro: false,
        ),
        ProgramDayTileState.done,
      );
      expect(
        ProgramDayTile.state(
          day: 8,
          progress: progress,
          now: now,
          isPro: false,
        ),
        ProgramDayTileState.proLocked,
      );
      expect(
        ProgramDayTile.state(
          day: 8,
          progress: progress,
          now: now,
          isPro: true,
        ),
        ProgramDayTileState.today,
      );
      expect(
        ProgramDayTile.state(
          day: 9,
          progress: progress,
          now: now,
          isPro: true,
        ),
        ProgramDayTileState.future,
      );
      expect(
        ProgramDayTile.state(
          day: 3,
          progress: [_done(1, DateTime(2026, 1, 1))],
          now: DateTime(2026, 1, 2, 10),
          isPro: false,
        ),
        ProgramDayTileState.future,
      );
      expect(
        ProgramDayTile.state(
          day: 2,
          progress: [_done(1, DateTime(2026, 1, 1))],
          now: DateTime(2026, 1, 2, 10),
          isPro: false,
        ),
        ProgramDayTileState.today,
      );
    });
  });

  group('Program tab widgets', () {
    testWidgets('future sheet shows opens-after copy', (tester) async {
      await seedProfile();
      await tester.pumpWidget(
        wrapWithRouter(
          V3ProgramScreen(nowOverride: DateTime(2026, 1, 1, 10)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('v3_program_tile_1_today')), findsOneWidget);
      expect(find.byKey(const Key('v3_program_tile_2_future')), findsOneWidget);

      await tester.tap(find.byKey(const Key('v3_program_tile_2_future')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_program_future_sheet')), findsOneWidget);
      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('done review shows saved input', (tester) async {
      await seedProfile();
      await repo.saveDayProgress(_done(1, DateTime(2026, 1, 1, 12)));
      await repo.saveUserInputs(
        const UserInputs(
          screenAudit: ScreenAuditInput(
            hours: 6,
            apps: ['Instagram'],
            pickups: 40,
          ),
        ),
      );

      final loaded = await repo.load();
      expect(loaded.userInputs.screenAudit?.apps, contains('Instagram'));
      final day1 = bundle.program.dayByNumber(1)!;
      final ex = bundle.exercises.byId(day1.practiceId);
      expect(ex?.input, 'screen_audit');

      await tester.pumpWidget(
        wrap(const V3ProgramDayReviewScreen(day: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('v3_program_day_review')), findsOneWidget);
      expect(find.byKey(const Key('v3_program_review_lesson_title')), findsOneWidget);

      expect(
        find.byKey(const Key('v3_program_review_saved_input')),
        findsOneWidget,
      );
      expect(find.textContaining('Instagram'), findsOneWidget);
      expect(find.textContaining('6'), findsWidgets);
    });

    testWidgets('Pro-locked tile navigates to paywall', (tester) async {
      await seedProfile();
      for (var d = 1; d <= 7; d++) {
        await repo.saveDayProgress(_done(d, DateTime(2026, 1, d)));
      }
      await tester.pumpWidget(
        wrapWithRouter(
          V3ProgramScreen(nowOverride: DateTime(2026, 1, 8, 10)),
          isPro: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('v3_program_tile_8_proLocked')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('v3_program_tile_8_proLocked')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('test_paywall')), findsOneWidget);
    });
  });

  group('Progress tab', () {
    testWidgets('empty state has exactly one button', (tester) async {
      await seedProfile();
      await tester.pumpWidget(wrap(const V3ProgressScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('v3_progress_empty')), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byKey(const Key('v3_progress_empty_cta')), findsOneWidget);
      expect(find.byKey(const Key('v3_progress_clarity_chart_0')), findsNothing);
    });

    testWidgets('chart points = number of results; stats match seed',
        (tester) async {
      await seedProfile();
      await repo.saveDayProgress(
        _done(1, DateTime(2026, 1, 1), challengeDone: true),
      );
      await repo.saveDayProgress(
        _done(2, DateTime(2026, 1, 2), challengeDone: true),
      );
      await repo.appendClarityResult(_clarity(1, 40, 7));
      await repo.appendClarityResult(_clarity(7, 55, 5.5));
      await repo.appendFocusLog(
        FocusLog(at: DateTime(2026, 1, 1, 15), minutes: 25, completed: true),
      );
      await repo.appendSosLog(
        SosLog(at: DateTime(2026, 1, 1, 20), flowId: 'bored', before: 8, after: 3),
      );

      await tester.pumpWidget(
        wrap(V3ProgressScreen(nowOverride: DateTime(2026, 1, 3, 10))),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('v3_progress_clarity_chart_2')), findsOneWidget);
      expect(find.byKey(const Key('v3_progress_clarity_latest')), findsOneWidget);
      expect(find.text('55'), findsWidgets);

      final state = await repo.load();
      final stats = ProgressStats.fromState(
        dayProgress: state.dayProgress,
        clarityResults: state.clarityResults,
        focusLogs: state.focusLogs,
        sosLogs: state.sosLogs,
        now: DateTime(2026, 1, 3, 10),
      );
      expect(stats.daysPracticed, 2);
      expect(stats.challengesDone, 2);
      expect(stats.focusMinutes, 25);
      expect(stats.urgesBeaten, 1);
      expect(stats.clarityFirst, 40);
      expect(stats.clarityLatest, 55);

      expect(find.byKey(const Key('v3_progress_stat_days')), findsOneWidget);
      expect(find.byKey(const Key('v3_progress_stat_challenges')), findsOneWidget);
      expect(find.byKey(const Key('v3_progress_stat_focus')), findsOneWidget);
      expect(find.byKey(const Key('v3_progress_stat_urges')), findsOneWidget);
    });

    testWidgets('missed day marked', (tester) async {
      await seedProfile();
      // Day 1 completed; day 2 incomplete while day 3 completed → day 2 missed.
      await repo.saveDayProgress(_done(1, DateTime(2026, 1, 1)));
      await repo.saveDayProgress(
        const DayProgress(
          day: 2,
          lessonDone: false,
          practiceDone: false,
          usedEasy: false,
          challengeAccepted: false,
        ),
      );
      await repo.saveDayProgress(_done(3, DateTime(2026, 1, 3)));

      await tester.pumpWidget(
        wrap(V3ProgressScreen(nowOverride: DateTime(2026, 1, 4, 10))),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('v3_progress_cal_2_missed')),
        findsOneWidget,
      );
    });

    testWidgets('Arabic calendar starts Saturday', (tester) async {
      await seedProfile(locale: 'ar');
      await repo.saveDayProgress(_done(1, DateTime(2026, 1, 1)));

      await tester.pumpWidget(
        wrap(
          V3ProgressScreen(nowOverride: DateTime(2026, 1, 2, 10)),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('v3_progress_calendar_weekstart_sat')),
        findsOneWidget,
      );
      expect(
        ProgressCalendar.weekdayHeaders(arabicLocale: true).first,
        DateTime.saturday,
      );
      expect(
        ProgressCalendar.weekdayHeaders(arabicLocale: false).first,
        DateTime.monday,
      );
    });
  });

  group('engine helpers used by Progress', () {
    test('bestStreak tracks longest run', () {
      final progress = [
        _done(1, DateTime(2026, 3, 1)),
        _done(2, DateTime(2026, 3, 2)),
        _done(3, DateTime(2026, 3, 3)),
        _done(4, DateTime(2026, 3, 10)),
        _done(5, DateTime(2026, 3, 11)),
      ];
      expect(ProgramEngine.bestStreak(progress: progress), 3);
      expect(
        ProgramEngine.currentStreak(
          progress: progress,
          now: DateTime(2026, 3, 11, 20),
        ),
        2,
      );
    });
  });
}
