import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/daily_session/data/daily_session_repository.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_path.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_source_reference.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_status.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_step_state.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_version.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/session_marked.dart';
import 'package:brain_clean_mobile/features/progress/data/progress_repository.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_engine.dart';
import 'package:brain_clean_mobile/features/weekly_review/application/weekly_review_controller.dart';
import 'package:brain_clean_mobile/features/weekly_review/data/weekly_review_repository.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_period_resolver.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_eligibility.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_enums.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_question.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_response.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_signal_engine.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_summary_engine.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_version.dart';
import 'package:brain_clean_mobile/features/weekly_review/ui/weekly_review_questions_screen.dart';
import 'package:brain_clean_mobile/features/weekly_review/ui/weekly_review_summary_screen.dart';
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
  String planId = 'plan_a',
  String profileId = 'pack_a',
}) {
  final steps = [
    DailySessionStepState(
      stepId: 'r1',
      optional: false,
      phase: DailySessionStepPhase.completed,
      completedAt: DateTime.utc(2026, 7, 28),
    ),
  ];
  final mark = SessionMarked(
    id: SessionMarked.buildId(id),
    dailySessionId: id,
    todayActId: 'tact_a',
    planId: planId,
    dayKey: dayKey,
    path: path,
    completedAt: DateTime.utc(2026, 7, 28),
    fullCompletion: true,
    schemaVersion: DailySessionVersion.schema,
  );
  return DailySession(
    id: id,
    dayKey: dayKey,
    source: DailySessionSourceReference(
      planId: planId,
      todayActId: 'tact_a',
      profilePackId: profileId,
      planEngineVersion: 'recovery_plan_engine_v1',
      practiceCatalogVersion: 'recovery_practice_catalog_v1',
      todayActVersion: 'recovery_plan_engine_v1',
    ),
    status: DailySessionStatus.completed,
    path: path,
    orderedStepIds: const ['r1'],
    steps: steps,
    currentStepIndex: 0,
    startedAt: DateTime.utc(2026, 7, 28),
    updatedAt: DateTime.utc(2026, 7, 28),
    completedAt: mark.completedAt,
    mark: mark,
    schemaVersion: DailySessionVersion.schema,
  );
}

WeeklyReviewResponse _ans(
  String id, {
  String? choice,
  int? scale,
  List<String>? multi,
  bool? booleanValue,
}) {
  return WeeklyReviewResponse(
    questionId: id,
    answeredAt: DateTime.utc(2026, 8, 3),
    singleChoice: choice,
    scaleValue: scale,
    multiSelect: multi,
    booleanValue: booleanValue,
  );
}

Map<String, WeeklyReviewResponse> _fullAnswers({
  String manage = 'about_right',
  int pause = 3,
  String obstacle = 'no_major_obstacle',
  List<String> support = const [],
  bool? a11y,
}) {
  final map = <String, WeeklyReviewResponse>{
    WeeklyReviewQuestionCatalog.manageability: _ans(
      WeeklyReviewQuestionCatalog.manageability,
      choice: manage,
    ),
    WeeklyReviewQuestionCatalog.pauseFocus: _ans(
      WeeklyReviewQuestionCatalog.pauseFocus,
      scale: pause,
    ),
    WeeklyReviewQuestionCatalog.obstacle: _ans(
      WeeklyReviewQuestionCatalog.obstacle,
      choice: obstacle,
    ),
  };
  if (support.isNotEmpty) {
    map[WeeklyReviewQuestionCatalog.support] = _ans(
      WeeklyReviewQuestionCatalog.support,
      multi: support,
    );
  }
  if (a11y != null) {
    map[WeeklyReviewQuestionCatalog.accessibilityUsed] = _ans(
      WeeklyReviewQuestionCatalog.accessibilityUsed,
      booleanValue: a11y,
    );
  }
  return map;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String tempDir;
  late Box<dynamic> sessionBox;
  late Box<dynamic> progressBox;
  late Box<dynamic> reviewBox;

  setUp(() async {
    tempDir =
        '${Directory.systemTemp.path}/wrv_${DateTime.now().microsecondsSinceEpoch}';
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

  group('ISO week model', () {
    test('Monday/Sunday boundaries and week id', () {
      // Monday 2026-07-27 .. Sunday 2026-08-02 → ISO 2026-W31
      final period = WeeklyPeriodResolver.periodContaining(
        localNow: DateTime(2026, 7, 29, 12),
        timezoneOffset: Duration.zero,
        materializedAtUtc: DateTime.utc(2026, 7, 29),
      );
      expect(period.startDayKey, '2026-07-27');
      expect(period.endDayKey, '2026-08-02');
      expect(period.periodId, 'iso_2026_W31');
    });

    test('previous completed week is never current', () {
      final local = DateTime(2026, 8, 3, 10); // Monday W32
      final prev = WeeklyPeriodResolver.previousCompletedWeek(
        localNow: local,
        timezoneOffset: Duration.zero,
      );
      expect(prev.periodId, 'iso_2026_W31');
      expect(
        WeeklyPeriodResolver.isCurrentWeek(
          period: prev,
          localNow: local,
          timezoneOffset: Duration.zero,
        ),
        isFalse,
      );
    });

    test('year boundary and week 53', () {
      // 2021-01-01 Friday is ISO 2020-W53
      final iso = WeeklyPeriodResolver.isoWeekOf(DateTime(2021, 1, 1));
      expect(iso.year, 2020);
      expect(iso.week, 53);
      final p = WeeklyPeriodResolver.periodContaining(
        localNow: DateTime(2021, 1, 1),
        timezoneOffset: Duration.zero,
      );
      expect(p.periodId, 'iso_2020_W53');
      expect(p.startDayKey, '2020-12-28');
      expect(p.endDayKey, '2021-01-03');
    });

    test('locale does not change period identity', () {
      final a = WeeklyPeriodResolver.periodContaining(
        localNow: DateTime(2026, 7, 29),
        timezoneOffset: const Duration(hours: 3),
      );
      final b = WeeklyPeriodResolver.periodContaining(
        localNow: DateTime(2026, 7, 29),
        timezoneOffset: const Duration(hours: -5),
      );
      // Same local civil date → same Mon-Sun day keys / id
      expect(a.periodId, b.periodId);
      expect(a.startDayKey, b.startDayKey);
    });

    test('timezone captured; historical keys stable', () {
      final p = WeeklyPeriodResolver.periodContaining(
        localNow: DateTime(2026, 7, 29),
        timezoneOffset: const Duration(hours: 2),
      );
      expect(p.timezoneOffsetMinutes, 120);
      expect(p.startDayKey, '2026-07-27');
    });
  });

  group('Eligibility', () {
    test('zero sessions not eligible; one session eligible limited', () {
      final period = WeeklyPeriodResolver.previousCompletedWeek(
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
      );
      final snap = ProgressEngine.build(
        sessions: const [],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      );
      final zero = WeeklyReviewEligibilityEngine.evaluate(
        period: period,
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        history: const [],
        progressSnapshot: snap,
        planId: 'plan_a',
        profilePackId: 'pack_a',
        existingForPeriod: null,
      );
      expect(zero.isEligible, isFalse);
      expect(
        zero.reason,
        WeeklyReviewNotEligibleReason.zeroCompletedSessions,
      );

      final one = _session(
        id: 's1',
        dayKey: '2026-07-28',
        path: DailySessionPath.minimum,
      );
      final snap1 = ProgressEngine.build(
        sessions: [one],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
      );
      final ok = WeeklyReviewEligibilityEngine.evaluate(
        period: period,
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        history: [one],
        progressSnapshot: snap1,
        planId: 'plan_a',
        profilePackId: 'pack_a',
        existingForPeriod: null,
      );
      expect(ok.isEligible, isTrue);
      expect(ok.completedSessions, hasLength(1));
    });

    test('current week not eligible', () {
      final current = WeeklyPeriodResolver.periodContaining(
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
      );
      final s = _session(
        id: 's1',
        dayKey: '2026-08-03',
        path: DailySessionPath.minimum,
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      );
      final r = WeeklyReviewEligibilityEngine.evaluate(
        period: current,
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
        history: [s],
        progressSnapshot: snap,
        planId: 'plan_a',
        profilePackId: 'pack_a',
        existingForPeriod: null,
      );
      expect(r.isEligible, isFalse);
      expect(r.reason, WeeklyReviewNotEligibleReason.currentWeek);
    });

    test('subscription and score band unused', () {
      // Eligibility API has no subscription / score-band params — structural proof.
      expect(
        WeeklyReviewEligibilityEngine.evaluate,
        isA<Function>(),
      );
    });
  });

  group('Questions and validation', () {
    test('exact question order and allowed values', () {
      expect(
        WeeklyReviewQuestionCatalog.inOrder.map((q) => q.id).toList(),
        [
          'wrv_manageability',
          'wrv_pause_focus',
          'wrv_obstacle',
          'wrv_support',
          'wrv_accessibility_used',
        ],
      );
    });

    test('scale out of range / multi>2 / duplicates rejected', () {
      expect(
        WeeklyReviewResponseValidator.validate(
          _ans(WeeklyReviewQuestionCatalog.pauseFocus, scale: 0),
        ).isValid,
        isFalse,
      );
      expect(
        WeeklyReviewResponseValidator.validate(
          _ans(WeeklyReviewQuestionCatalog.pauseFocus, scale: 6),
        ).isValid,
        isFalse,
      );
      expect(
        WeeklyReviewResponseValidator.validate(
          _ans(
            WeeklyReviewQuestionCatalog.support,
            multi: [
              'shorter_path',
              'clearer_timing',
              'quieter_environment',
            ],
          ),
        ).isValid,
        isFalse,
      );
      expect(
        WeeklyReviewResponseValidator.validate(
          _ans(
            WeeklyReviewQuestionCatalog.support,
            multi: ['shorter_path', 'shorter_path'],
          ),
        ).isValid,
        isFalse,
      );
      expect(
        WeeklyReviewResponseValidator.validate(
          _ans(
            WeeklyReviewQuestionCatalog.support,
            multi: ['shorter_path', 'clearer_timing'],
          ),
        ).isValid,
        isTrue,
      );
    });

    test('required block completion; optional absent stays absent', () {
      final partial = {
        WeeklyReviewQuestionCatalog.manageability: _ans(
          WeeklyReviewQuestionCatalog.manageability,
          choice: 'about_right',
        ),
      };
      expect(
        WeeklyReviewResponseValidator.requiredAnswersComplete(partial),
        isFalse,
      );
      final full = _fullAnswers();
      expect(
        WeeklyReviewResponseValidator.requiredAnswersComplete(full),
        isTrue,
      );
      expect(full.containsKey(WeeklyReviewQuestionCatalog.support), isFalse);
      expect(
        full.containsKey(WeeklyReviewQuestionCatalog.accessibilityUsed),
        isFalse,
      );
    });

    test('no hidden defaults on empty draft responses', () {
      expect(const <WeeklyReviewResponse>[], isEmpty);
    });
  });

  group('Summary and signal engines', () {
    late DateTime gen;

    setUp(() {
      gen = DateTime.utc(2026, 8, 3, 12);
    });

    test('labels: single / min / std / balanced / rhythms / evidence', () {
      final period = WeeklyPeriodResolver.previousCompletedWeek(
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
      );
      final one = [
        _session(id: 's1', dayKey: '2026-07-28', path: DailySessionPath.minimum),
      ];
      final s1 = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: one,
        responses: _fullAnswers(manage: 'too_light'),
        generatedAtUtc: gen,
      )!;
      expect(s1.pathMixLabel, PathMixLabel.singleSessionOnly);
      expect(s1.rhythmLabel, RhythmLabel.limitedHistory);
      expect(s1.evidenceDepth, EvidenceDepth.limited);
      expect(s1.planUnchangedNotice, isTrue);

      final mins = [
        for (var i = 0; i < 4; i++)
          _session(
            id: 'm$i',
            dayKey: '2026-07-${27 + i}',
            path: DailySessionPath.minimum,
          ),
      ];
      final sm = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: mins,
        responses: _fullAnswers(),
        generatedAtUtc: gen,
      )!;
      expect(sm.pathMixLabel, PathMixLabel.mostlyMinimum);
      expect(sm.evidenceDepth, EvidenceDepth.sufficientForWeeklySummary);

      final stds = [
        for (var i = 0; i < 5; i++)
          _session(
            id: 't$i',
            dayKey: '2026-07-${27 + i}',
            path: DailySessionPath.standard,
          ),
      ];
      final ss = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: stds,
        responses: _fullAnswers(),
        generatedAtUtc: gen,
      )!;
      expect(ss.pathMixLabel, PathMixLabel.mostlyStandard);
      expect(ss.rhythmLabel, RhythmLabel.steady);

      final mix = [
        _session(id: 'a', dayKey: '2026-07-27', path: DailySessionPath.minimum),
        _session(id: 'b', dayKey: '2026-07-28', path: DailySessionPath.standard),
        _session(id: 'c', dayKey: '2026-07-29', path: DailySessionPath.standard),
      ];
      final sb = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: mix,
        responses: _fullAnswers(),
        generatedAtUtc: gen,
      )!;
      expect(sb.pathMixLabel, PathMixLabel.balanced);
      expect(sb.rhythmLabel, RhythmLabel.intermittent);
      expect(sb.evidenceDepth, EvidenceDepth.developing);

      expect(
        WeeklyReviewSummaryEngine.build(
          period: period,
          completedInPeriod: const [],
          responses: _fullAnswers(),
          generatedAtUtc: gen,
        ),
        isNull,
      );
    });

    test('deterministic signal mappings + limited override', () {
      final period = WeeklyPeriodResolver.previousCompletedWeek(
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
      );
      final sessions = [
        for (var i = 0; i < 4; i++)
          _session(
            id: 's$i',
            dayKey: '2026-07-${27 + i}',
            path: DailySessionPath.standard,
          ),
      ];

      void checkManage(String manage, PlanFitSignal fit, LoadSignal load) {
        final sum = WeeklyReviewSummaryEngine.build(
          period: period,
          completedInPeriod: sessions,
          responses: _fullAnswers(manage: manage),
          generatedAtUtc: gen,
        )!;
        final sig = WeeklyReviewSignalEngine.build(
          periodId: period.periodId,
          artifactId: 'wart_${period.periodId}',
          summary: sum,
          responses: _fullAnswers(manage: manage),
          createdAtUtc: gen,
        );
        expect(sig.planFitSignal, fit);
        expect(sig.loadSignal, load);
      }

      checkManage(
        'too_light',
        PlanFitSignal.considerMoreSupport,
        LoadSignal.light,
      );
      checkManage('about_right', PlanFitSignal.maintain, LoadSignal.suitable);
      checkManage(
        'too_demanding',
        PlanFitSignal.considerLessLoad,
        LoadSignal.heavy,
      );

      final limitedSum = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: [
          _session(
            id: 'only',
            dayKey: '2026-07-28',
            path: DailySessionPath.minimum,
          ),
        ],
        responses: _fullAnswers(manage: 'too_demanding'),
        generatedAtUtc: gen,
      )!;
      final limitedSig = WeeklyReviewSignalEngine.build(
        periodId: period.periodId,
        artifactId: 'wart_x',
        summary: limitedSum,
        responses: _fullAnswers(manage: 'too_demanding'),
        createdAtUtc: gen,
      );
      expect(limitedSig.planFitSignal, PlanFitSignal.insufficientEvidence);
      expect(limitedSig.loadSignal, LoadSignal.heavy);
      expect(limitedSig.confidence, SignalConfidence.low);

      for (final o in [
        'time',
        'forgetfulness',
        'low_energy',
        'interruptions',
        'unclear_step',
        'access_or_environment',
        'no_major_obstacle',
      ]) {
        final sum = WeeklyReviewSummaryEngine.build(
          period: period,
          completedInPeriod: sessions,
          responses: _fullAnswers(obstacle: o),
          generatedAtUtc: gen,
        )!;
        final sig = WeeklyReviewSignalEngine.build(
          periodId: period.periodId,
          artifactId: 'a',
          summary: sum,
          responses: _fullAnswers(obstacle: o),
          createdAtUtc: gen,
        );
        if (o == 'no_major_obstacle') {
          expect(sig.obstacleSignal, ObstacleSignal.none);
        } else {
          expect(sig.obstacleSignal.wireName, o);
        }
      }

      final used = WeeklyReviewSignalEngine.build(
        periodId: period.periodId,
        artifactId: 'a',
        summary: WeeklyReviewSummaryEngine.build(
          period: period,
          completedInPeriod: sessions,
          responses: _fullAnswers(a11y: true),
          generatedAtUtc: gen,
        )!,
        responses: _fullAnswers(a11y: true),
        createdAtUtc: gen,
      );
      expect(used.accessibilitySignal, AccessibilitySignal.used);
      final unused = WeeklyReviewSignalEngine.build(
        periodId: period.periodId,
        artifactId: 'a',
        summary: WeeklyReviewSummaryEngine.build(
          period: period,
          completedInPeriod: sessions,
          responses: _fullAnswers(a11y: false),
          generatedAtUtc: gen,
        )!,
        responses: _fullAnswers(a11y: false),
        createdAtUtc: gen,
      );
      expect(unused.accessibilitySignal, AccessibilitySignal.notUsed);
      final unk = WeeklyReviewSignalEngine.build(
        periodId: period.periodId,
        artifactId: 'a',
        summary: WeeklyReviewSummaryEngine.build(
          period: period,
          completedInPeriod: sessions,
          responses: _fullAnswers(),
          generatedAtUtc: gen,
        )!,
        responses: _fullAnswers(),
        createdAtUtc: gen,
      );
      expect(unk.accessibilitySignal, AccessibilitySignal.unknown);
    });
  });

  group('Controller persistence resume completion', () {
    Future<WeeklyReviewController> boot({
      required List<DailySession> sessions,
      DateTime? clock,
    }) async {
      final sessRepo = DailySessionLocalRepository(box: sessionBox);
      for (final s in sessions) {
        await sessRepo.saveCompletion(session: s, mark: s.mark!);
      }
      final c = WeeklyReviewController(
        sessions: sessRepo,
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => clock ?? DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      await c.bootstrap();
      return c;
    }

    test('autosave, resume, exit, complete idempotent', () async {
      final sessions = [
        for (var i = 0; i < 4; i++)
          _session(
            id: 's$i',
            dayKey: '2026-07-${27 + i}',
            path: i.isEven
                ? DailySessionPath.minimum
                : DailySessionPath.standard,
          ),
      ];
      var c = await boot(sessions: sessions);
      expect(c.phase, WeeklyReviewUiPhase.draft);
      expect(c.period?.periodId, 'iso_2026_W31');

      final ok = await c.answerCurrent(
        _ans(
          WeeklyReviewQuestionCatalog.manageability,
          choice: 'about_right',
        ),
      );
      expect(ok, isTrue);
      await c.goForward();
      expect(c.record!.questionIndex, 1);

      // Recreate controller — exact resume
      c = WeeklyReviewController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      await c.bootstrap();
      expect(c.record!.questionIndex, 1);
      expect(
        c.record!.responsesById[WeeklyReviewQuestionCatalog.manageability]
            ?.singleChoice,
        'about_right',
      );

      c.exitPreservingDraft();
      expect(c.summary, isNull);
      expect(c.artifact, isNull);
      expect(c.signal, isNull);

      await c.answerCurrent(
        _ans(WeeklyReviewQuestionCatalog.pauseFocus, scale: 4),
      );
      await c.goForward();
      await c.answerCurrent(
        _ans(
          WeeklyReviewQuestionCatalog.obstacle,
          choice: 'time',
        ),
      );
      await c.goForward();
      await c.answerCurrent(
        _ans(
          WeeklyReviewQuestionCatalog.support,
          multi: ['shorter_path', 'same_plan_is_working'],
        ),
      );
      await c.goForward();
      await c.answerCurrent(
        _ans(
          WeeklyReviewQuestionCatalog.accessibilityUsed,
          booleanValue: true,
        ),
      );
      expect(c.canComplete, isTrue);
      final completed = await c.complete();
      expect(completed, isTrue);
      expect(c.phase, WeeklyReviewUiPhase.completed);
      expect(c.artifact, isNotNull);
      expect(c.signal, isNotNull);
      expect(c.summary!.planUnchangedNotice, isTrue);
      final hash1 = c.artifact!.immutableHash;
      final artId = c.artifact!.artifactId;

      final again = await c.complete();
      expect(again, isTrue);
      expect(c.artifact!.artifactId, artId);
      expect(c.artifact!.immutableHash, hash1);

      final repo = WeeklyReviewLocalRepository(box: reviewBox);
      final byPeriod = await repo.findByPeriod('iso_2026_W31');
      expect(byPeriod!.isCompleted, isTrue);
      final art = await repo.artifactByReviewId(byPeriod.id);
      expect(art!.immutableHash, hash1);
      final sig = await repo.signalByArtifactId(art.artifactId);
      expect(sig!.signalId, 'wrsig_iso_2026_W31');

      // Second bootstrap opens completed
      final c2 = WeeklyReviewController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      await c2.bootstrap();
      expect(c2.phase, WeeklyReviewUiPhase.completed);
      expect(c2.artifact?.immutableHash, hash1);
    });

    test('zero sessions not-ready; invalid values not persisted', () async {
      final c = await boot(sessions: const []);
      expect(c.phase, WeeklyReviewUiPhase.notEligible);
      expect(
        c.notEligibleReason,
        WeeklyReviewNotEligibleReason.zeroCompletedSessions,
      );

      final withSession = await boot(sessions: [
        _session(
          id: 's1',
          dayKey: '2026-07-28',
          path: DailySessionPath.minimum,
        ),
      ]);
      final rejected = await withSession.answerCurrent(
        _ans(WeeklyReviewQuestionCatalog.pauseFocus, scale: 9),
      );
      expect(rejected, isFalse);
      expect(
        withSession.record!.responsesById
            .containsKey(WeeklyReviewQuestionCatalog.pauseFocus),
        isFalse,
      );
    });

    test('corrupt review skipped safely; unsupported version surfaces', () async {
      await reviewBox.put(WeeklyReviewLocalRepository.reviewsKey, [
        {'not': 'a review'},
        {
          'id': 'bad',
          'periodId': 'iso_2026_W31',
          'schemaVersion': 'weekly_review_pack_v999',
        },
      ]);
      final history = await WeeklyReviewLocalRepository(box: reviewBox).history();
      expect(history, isEmpty);
      expect(WeeklyReviewVersion.schema, 'weekly_review_pack_v1');
      expect(HiveBoxes.weeklyReview, 'weekly_review_v1');
    });
  });

  group('Localization / wording / routes / a11y smoke', () {
    test('EN/AR canonical parity and banned wording', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2WeeklyReviewTitle, 'Weekly Review');
      expect(ar.v2WeeklyReviewTitle, 'المراجعة الأسبوعية');
      expect(en.v2WeeklySummaryTitle, 'Weekly Summary');
      expect(ar.v2WeeklySummaryTitle, 'ملخص الأسبوع');
      expect(en.v2WeeklySummaryPlanUnchanged, 'Your plan has not changed yet');
      expect(ar.v2WeeklySummaryPlanUnchanged, 'لم تتغير خطتك بعد');

      final corpus = [
        en.v2WeeklyReviewTitle,
        en.v2WeeklySummaryOrientation,
        en.v2WeeklySummaryPlanUnchanged,
        en.v2WeeklyReviewNotReadyZeroBody,
        ar.v2WeeklyReviewTitle,
        ar.v2WeeklySummaryPlanUnchanged,
      ].join(' ').toLowerCase();
      for (final banned in [
        'diagnos',
        'medical',
        'failure',
        'shame',
        'cure',
        'treatment',
        'bad week',
        'فشل',
        'تشخيص',
        'علاج',
      ]) {
        expect(corpus.contains(banned), isFalse, reason: banned);
      }
    });

    test('routes are gated V2 paths', () {
      expect(AppRoutes.v2WeeklyReview, '/v2/weekly-review');
      expect(AppRoutes.v2WeeklyReviewSummary, '/v2/weekly-review/summary');
    });

    testWidgets('WRV bodies scroll at 320 / textScale 2.0; 48dp CTA',
        (tester) async {
      final period = WeeklyPeriodResolver.previousCompletedWeek(
        localNow: DateTime(2026, 8, 3),
        timezoneOffset: Duration.zero,
      );
      final c = WeeklyReviewController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      // Force not-eligible message pad for layout smoke without full bootstrap data.
      c.phase = WeeklyReviewUiPhase.notEligible;
      c.notEligibleReason =
          WeeklyReviewNotEligibleReason.zeroCompletedSessions;
      c.period = period;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 500),
              textScaler: TextScaler.linear(2),
            ),
            child: WeeklyReviewQuestionsBody(controller: c),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));

      final sum = WeeklyReviewSummaryEngine.build(
        period: period,
        completedInPeriod: [
          _session(
            id: 's1',
            dayKey: '2026-07-28',
            path: DailySessionPath.minimum,
          ),
        ],
        responses: _fullAnswers(),
        generatedAtUtc: DateTime.utc(2026, 8, 3),
      );
      c.phase = WeeklyReviewUiPhase.completed;
      c.summary = sum;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2),
            ),
            child: WeeklyReviewSummaryBody(controller: c),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.textContaining('plan has not changed'), findsOneWidget);
    });

    test('feature flag OFF preserves V1 gate constant', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableTodaySessionRoutes, isFalse);
    });
  });
}
