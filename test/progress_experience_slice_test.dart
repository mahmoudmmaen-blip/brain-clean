import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/daily_session/data/daily_session_repository.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_path.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_source_reference.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_status.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_step_state.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_version.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/session_marked.dart';
import 'package:brain_clean_mobile/features/progress/application/progress_experience_controller.dart';
import 'package:brain_clean_mobile/features/progress/data/progress_repository.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_engine.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_experience_builder.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_experience_enums.dart';
import 'package:brain_clean_mobile/features/progress/ui/progress_home_screen.dart';
import 'package:brain_clean_mobile/features/weekly_review/data/weekly_review_repository.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_period_resolver.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_enums.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_question.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_record.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_response.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_source_reference.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_summary.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_summary_engine.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
  @override
  Future<String?> getTemporaryPath() async => root;
}

DailySession _session({
  required String id,
  required String dayKey,
  required DailySessionPath path,
}) {
  final mark = SessionMarked(
    id: SessionMarked.buildId(id),
    dailySessionId: id,
    todayActId: 'tact_a',
    planId: 'plan_a',
    dayKey: dayKey,
    path: path,
    completedAt: DateTime.utc(2026, 7, 28),
    fullCompletion: true,
    schemaVersion: DailySessionVersion.schema,
  );
  return DailySession(
    id: id,
    dayKey: dayKey,
    source: const DailySessionSourceReference(
      planId: 'plan_a',
      todayActId: 'tact_a',
      profilePackId: 'pack_a',
      planEngineVersion: 'recovery_plan_engine_v1',
      practiceCatalogVersion: 'recovery_practice_catalog_v1',
      todayActVersion: 'recovery_plan_engine_v1',
    ),
    status: DailySessionStatus.completed,
    path: path,
    orderedStepIds: const ['r1'],
    steps: [
      DailySessionStepState(
        stepId: 'r1',
        optional: false,
        phase: DailySessionStepPhase.completed,
        completedAt: DateTime.utc(2026, 7, 28),
      ),
    ],
    currentStepIndex: 0,
    startedAt: DateTime.utc(2026, 7, 28),
    updatedAt: DateTime.utc(2026, 7, 28),
    completedAt: mark.completedAt,
    mark: mark,
    schemaVersion: DailySessionVersion.schema,
  );
}

Map<String, WeeklyReviewResponse> _answers() => {
      WeeklyReviewQuestionCatalog.manageability: WeeklyReviewResponse(
        questionId: WeeklyReviewQuestionCatalog.manageability,
        answeredAt: DateTime.utc(2026, 8, 3),
        singleChoice: 'about_right',
      ),
      WeeklyReviewQuestionCatalog.pauseFocus: WeeklyReviewResponse(
        questionId: WeeklyReviewQuestionCatalog.pauseFocus,
        answeredAt: DateTime.utc(2026, 8, 3),
        scaleValue: 3,
      ),
      WeeklyReviewQuestionCatalog.obstacle: WeeklyReviewResponse(
        questionId: WeeklyReviewQuestionCatalog.obstacle,
        answeredAt: DateTime.utc(2026, 8, 3),
        singleChoice: 'time',
      ),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String tempDir;
  late Box<dynamic> sessionBox;
  late Box<dynamic> progressBox;
  late Box<dynamic> reviewBox;

  setUp(() async {
    tempDir =
        '${Directory.systemTemp.path}/prg81_${DateTime.now().microsecondsSinceEpoch}';
    await Directory(tempDir).create(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    HiveBootstrap.resetForTesting();
    await Hive.initFlutter(tempDir);
    sessionBox = await Hive.openBox('t_sess');
    progressBox = await Hive.openBox('t_prog');
    reviewBox = await Hive.openBox('t_wrv');
    V2FeatureBoundary.enableBrainProfileRoutes = true;
  });

  tearDown(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    await Hive.close();
    HiveBootstrap.resetForTesting();
    try {
      await Directory(tempDir).delete(recursive: true);
    } catch (_) {}
  });

  group('ProgressExperienceBuilder', () {
    final localNow = DateTime(2026, 8, 3, 12);
    final period = WeeklyPeriodResolver.previousCompletedWeek(
      localNow: localNow,
      timezoneOffset: Duration.zero,
    );

    test('empty snapshot → empty headline and Today CTA', () {
      final snap = ProgressEngine.build(
        sessions: const [],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      );
      final vm = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: const [],
        profilePack: null,
        previousPeriod: period,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );
      expect(vm.isEmpty, isTrue);
      expect(vm.proofHeadline, ProgressProofHeadline.empty);
      expect(vm.evidenceDepth, ProgressEvidenceDepth.empty);
      expect(vm.primaryDestination, ProgressNextDestination.today);
      expect(
        vm.weeklyReviewCardState,
        ProgressWeeklyReviewCardState.notEnoughActivity,
      );
      expect(vm.showScoreRow, isFalse);
      expect(vm.completionRatePercent, 0);
    });

    test('one session → limited evidence; no invented days', () {
      final s = _session(
        id: 's1',
        dayKey: '2026-07-28',
        path: DailySessionPath.minimum,
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final vm = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: [s],
        profilePack: null,
        previousPeriod: period,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );
      expect(vm.totalCompletedSessions, 1);
      expect(vm.completedDays, 1);
      expect(vm.minimumPathCount, 1);
      expect(vm.standardPathCount, 0);
      expect(vm.evidenceDepth, ProgressEvidenceDepth.limited);
      expect(vm.proofHeadline, ProgressProofHeadline.firstSession);
      expect(vm.recentTimeline, hasLength(1));
      expect(vm.recentTimeline.first.dayKey, '2026-07-28');
      expect(vm.weeklyReviewCardState, ProgressWeeklyReviewCardState.available);
      expect(
        vm.primaryDestination,
        ProgressNextDestination.weeklyReviewQuestions,
      );
    });

    test('several sessions → counts, rhythm, path mix, bounded timeline', () {
      final sessions = [
        for (var i = 0; i < 5; i++)
          _session(
            id: 's$i',
            dayKey: '2026-07-${27 + i}',
            path:
                i.isEven ? DailySessionPath.minimum : DailySessionPath.standard,
          ),
      ];
      // Extra older sessions outside recent limit window of same week — still one week.
      final snap = ProgressEngine.build(
        sessions: sessions,
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final vm = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: sessions,
        profilePack: null,
        previousPeriod: period,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );
      expect(vm.totalCompletedSessions, 5);
      expect(vm.completedDays, 5);
      expect(vm.minimumPathCount, 3);
      expect(vm.standardPathCount, 2);
      expect(vm.longestRhythmDays, greaterThan(0));
      expect(vm.completionRatePercent, inInclusiveRange(0, 100));
      expect(vm.recentTimeline.length, lessThanOrEqualTo(7));
      expect(vm.evidenceDepth, ProgressEvidenceDepth.sufficient);
      expect(vm.pathMixHint, PathMixLabel.balanced);
      // REVIEW_DUE priority
      expect(
        vm.primaryDestination,
        ProgressNextDestination.weeklyReviewQuestions,
      );
    });

    test('draft / completed weekly review state + summary preview', () {
      final sessions = [
        _session(
            id: 's1', dayKey: '2026-07-28', path: DailySessionPath.minimum),
        _session(
            id: 's2', dayKey: '2026-07-29', path: DailySessionPath.standard),
      ];
      final snap = ProgressEngine.build(
        sessions: sessions,
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final draft = WeeklyReviewRecord.draft(
        period: period,
        source: const WeeklyReviewSourceReference(
          progressSnapshotId: 'ps',
          planId: 'plan_a',
          profilePackId: 'pack_a',
          recoveryScoreReference: 'recovery_score_v1',
        ),
        completedSessionIds: ['s1', 's2'],
        nowUtc: DateTime.utc(2026, 8, 3),
      );
      final vmDraft = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: sessions,
        profilePack: null,
        previousPeriod: period,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: draft,
        artifactSummary: null,
        schemasSupported: true,
      );
      expect(
        vmDraft.weeklyReviewCardState,
        ProgressWeeklyReviewCardState.draftInProgress,
      );

      final summary = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: sessions,
        responses: _answers(),
        generatedAtUtc: DateTime.utc(2026, 8, 3),
      )!;
      final completed = draft.copyWith(
        status: WeeklyReviewStatus.completed,
        summary: summary,
        artifactId: 'wart_${period.periodId}',
        completedAt: DateTime.utc(2026, 8, 3),
      );
      final vmDone = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: sessions,
        profilePack: null,
        previousPeriod: period,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: completed,
        artifactSummary: summary,
        schemasSupported: true,
      );
      expect(
        vmDone.weeklyReviewCardState,
        ProgressWeeklyReviewCardState.summaryAvailable,
      );
      expect(
        vmDone.primaryDestination,
        ProgressNextDestination.weeklyReviewSummary,
      );
      expect(vmDone.weeklySummaryPreview, isNotNull);
      expect(vmDone.weeklySummaryPreview!.planUnchangedNotice, isTrue);
      expect(
          vmDone.proofHeadline, ProgressProofHeadline.weeklyEvidenceAvailable);
      // Preview must not need raw responses on the model surface.
      expect(vmDone.weeklySummaryPreview, isA<WeeklyReviewSummary>());
    });

    test('unsupported schema / missing refs / current week', () {
      final s = _session(
        id: 's1',
        dayKey: '2026-07-28',
        path: DailySessionPath.minimum,
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      );
      final unsupported = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: [s],
        profilePack: null,
        previousPeriod: period,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: false,
      );
      expect(
        unsupported.weeklyReviewCardState,
        ProgressWeeklyReviewCardState.unsupportedVersion,
      );

      final current = WeeklyPeriodResolver.periodContaining(
        localNow: localNow,
        timezoneOffset: Duration.zero,
      );
      final curSession = _session(
        id: 'c1',
        dayKey: '2026-08-03',
        path: DailySessionPath.minimum,
      );
      final curSnap = ProgressEngine.build(
        sessions: [curSession],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final vmCur = ProgressExperienceBuilder.build(
        snapshot: curSnap,
        sessionHistory: [curSession],
        profilePack: null,
        previousPeriod: current,
        localNow: localNow,
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );
      expect(
        vmCur.weeklyReviewCardState,
        ProgressWeeklyReviewCardState.currentWeekInProgress,
      );
    });
  });

  group('ProgressExperienceController', () {
    test('load empty / with sessions; no Plan or Score mutation API', () async {
      final c = ProgressExperienceController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      await c.load();
      expect(c.phase, ProgressExperiencePhase.empty);
      expect(c.viewModel.isEmpty, isTrue);

      final sess = DailySessionLocalRepository(box: sessionBox);
      final s = _session(
        id: 's1',
        dayKey: '2026-07-28',
        path: DailySessionPath.minimum,
      );
      await sess.saveCompletion(session: s, mark: s.mark!);
      await c.load();
      expect(c.phase, ProgressExperiencePhase.ready);
      expect(c.viewModel.totalCompletedSessions, 1);
      expect(WeeklyReviewVersion.box, 'weekly_review_v1');
    });
  });

  group('Localization / routes / a11y', () {
    test('EN/AR parity and banned wording', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2ProgressTitle, 'Progress');
      expect(ar.v2ProgressTitle, 'التقدّم');
      expect(en.v2ProgressCurrentRhythm(1), 'Current rhythm: 1 day');
      expect(en.v2ProgressCurrentRhythm(2), 'Current rhythm: 2 days');
      expect(en.v2ProgressLongestRhythm(1), 'Longest rhythm: 1 day');
      expect(en.v2ProgressLongestRhythm(0), 'Longest rhythm: 0 days');
      expect(ar.v2ProgressCurrentRhythm(1), contains('يوم'));
      expect(en.v2ProgressWrAvailable, contains('Weekly Review'));
      expect(ar.v2ProgressWrAvailable, contains('المراجعة'));
      expect(en.v2WeeklySummaryCtaProgress, 'Back to Progress');
      expect(ar.v2WeeklySummaryCtaProgress, 'العودة إلى التقدّم');
      expect(en.v2ProgressScoreDisclaimer.toLowerCase(),
          contains('does not instantly'));
      final corpus = [
        en.v2ProgressHeadlineEmpty,
        en.v2ProgressEvidenceLimited,
        en.v2ProgressScoreDisclaimer,
        ar.v2ProgressHeadlineEmpty,
        ar.v2ProgressEvidenceDeveloping,
      ].join(' ').toLowerCase();
      for (final banned in [
        'failure',
        'cure',
        'damage',
        'clinical',
        'bad week',
        'فشل',
        'علاج',
        'تلف',
      ]) {
        expect(corpus.contains(banned), isFalse, reason: banned);
      }
    });

    test('gated Progress route', () {
      expect(AppRoutes.v2Progress, '/v2/progress');
    });

    testWidgets('PRG-01 empty scrolls at 320 / textScale 2; 48dp CTA',
        (tester) async {
      final c = ProgressExperienceController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      c.phase = ProgressExperiencePhase.empty;
      c.viewModel = ProgressExperienceBuilder.build(
        snapshot: ProgressEngine.build(
          sessions: const [],
          nowUtc: DateTime.utc(2026, 8, 3),
          asOfDayKey: '2026-08-03',
        ),
        sessionHistory: const [],
        profilePack: null,
        previousPeriod: WeeklyPeriodResolver.previousCompletedWeek(
          localNow: DateTime(2026, 8, 3),
          timezoneOffset: Duration.zero,
        ),
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 520),
              textScaler: TextScaler.linear(2),
            ),
            child: ProgressHomeBody(controller: c, onRetry: () {}),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(find.textContaining('completed sessions'), findsWidgets);
      // Empty: no pattern-details disclosure / invented history chrome.
      expect(find.text('Pattern details'), findsNothing);
      expect(find.text('What is recorded'), findsNothing);
    });

    testWidgets('decision-first: primary CTA before pattern details',
        (tester) async {
      final s = _session(
        id: 's1',
        dayKey: '2026-07-28',
        path: DailySessionPath.minimum,
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final c = ProgressExperienceController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      c.phase = ProgressExperiencePhase.ready;
      c.viewModel = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: [s],
        profilePack: null,
        previousPeriod: WeeklyPeriodResolver.previousCompletedWeek(
          localNow: DateTime(2026, 8, 3),
          timezoneOffset: Duration.zero,
        ),
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(411, 820)),
            child: ProgressHomeBody(controller: c, onRetry: () {}),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final headline = find.text('Your first completed session is recorded');
      final movement = find.text('What is recorded');
      final cta = find.byType(FilledButton);
      final details = find.text('Pattern details');
      final recent = find.text('Recent activity');

      expect(headline, findsOneWidget);
      expect(movement, findsOneWidget);
      expect(cta, findsOneWidget);
      expect(details, findsOneWidget);
      expect(recent, findsOneWidget);

      // Product contract: insight → movement → next action → progressive detail.
      expect(
        tester.getTopLeft(headline).dy,
        lessThan(tester.getTopLeft(movement).dy),
      );
      expect(
        tester.getTopLeft(movement).dy,
        lessThan(tester.getTopLeft(cta).dy),
      );
      expect(
        tester.getTopLeft(cta).dy,
        lessThan(tester.getTopLeft(details).dy),
      );
      expect(
        tester.getTopLeft(details).dy,
        lessThan(tester.getTopLeft(recent).dy),
      );

      // Details stay collapsed — no dense timeline lines until opened.
      expect(find.textContaining('2026-07-28 ·'), findsNothing);

      // Compact movement: one calm summary line, not a number stack.
      expect(
        find.textContaining('Completed days: 1 · Completed sessions: 1'),
        findsOneWidget,
      );
    });

    testWidgets('Phase B: empty WR stays quiet (no period chrome)',
        (tester) async {
      final c = ProgressExperienceController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      c.phase = ProgressExperiencePhase.empty;
      c.viewModel = ProgressExperienceBuilder.build(
        snapshot: ProgressEngine.build(
          sessions: const [],
          nowUtc: DateTime.utc(2026, 8, 3),
          asOfDayKey: '2026-08-03',
        ),
        sessionHistory: const [],
        profilePack: null,
        previousPeriod: WeeklyPeriodResolver.previousCompletedWeek(
          localNow: DateTime(2026, 8, 3),
          timezoneOffset: Duration.zero,
        ),
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(411, 820)),
            child: ProgressHomeBody(controller: c, onRetry: () {}),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Weekly Review'), findsOneWidget);
      expect(
          find.textContaining('Not enough completed activity'), findsOneWidget);
      expect(find.textContaining('Period '), findsNothing);
      expect(find.text('Start Weekly Review'), findsNothing);
      // One primary decision only.
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
          find.text(AppLocalizationsEn().v2ProgressCtaToday), findsOneWidget);
    });

    testWidgets(
        'Phase B: WR-due primary CTA only; score after details; expand OK',
        (tester) async {
      final s = _session(
        id: 's1',
        dayKey: '2026-07-28',
        path: DailySessionPath.minimum,
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final c = ProgressExperienceController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      c.phase = ProgressExperiencePhase.ready;
      c.viewModel = ProgressExperienceBuilder.build(
        snapshot: snap,
        sessionHistory: [s],
        profilePack: null,
        previousPeriod: WeeklyPeriodResolver.previousCompletedWeek(
          localNow: DateTime(2026, 8, 3),
          timezoneOffset: Duration.zero,
        ),
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 780),
              textScaler: TextScaler.linear(1.3),
            ),
            child: ProgressHomeBody(controller: c, onRetry: () {}),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Start Weekly Review'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Start Weekly Review'),
          findsNothing);
      expect(find.text('Weekly Review available'), findsOneWidget);

      final cta = find.text('Start Weekly Review');
      final details = find.text('Pattern details');
      expect(
        tester.getTopLeft(cta).dy,
        lessThan(tester.getTopLeft(details).dy),
      );

      await tester.tap(details);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Minimum path:'), findsOneWidget);
      expect(find.textContaining('Completed-day rate:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Phase B: Arabic empty Progress at 320 scrolls',
        (tester) async {
      final c = ProgressExperienceController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      c.phase = ProgressExperiencePhase.empty;
      c.viewModel = ProgressExperienceBuilder.build(
        snapshot: ProgressEngine.build(
          sessions: const [],
          nowUtc: DateTime.utc(2026, 8, 3),
          asOfDayKey: '2026-08-03',
        ),
        sessionHistory: const [],
        profilePack: null,
        previousPeriod: WeeklyPeriodResolver.previousCompletedWeek(
          localNow: DateTime(2026, 8, 3),
          timezoneOffset: Duration.zero,
        ),
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        reviewForPeriod: null,
        artifactSummary: null,
        schemasSupported: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: ProgressHomeBody(controller: c, onRetry: () {}),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('التقدّم'), findsNothing); // AppBar not in body
      expect(find.text('تقدّمك'), findsOneWidget);
      expect(find.text('لا جلسات مكتملة بعد'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('feature flag OFF', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableTodaySessionRoutes, isFalse);
    });
  });
}
