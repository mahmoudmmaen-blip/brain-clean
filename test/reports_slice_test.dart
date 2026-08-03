import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_profile/data/brain_profile_repository.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/brain_profile_domain_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_explanation.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_source_reference.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_version.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
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
import 'package:brain_clean_mobile/features/v2_reports/application/reports_controller.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/measurement_history_engine.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_archive_gate.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_comparison_result.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_evidence_depth.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_measurement_status.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_overview_builder.dart';
import 'package:brain_clean_mobile/features/weekly_review/data/weekly_review_repository.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_artifact.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_enums.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_summary.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_version.dart';
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
  DailySessionPath path = DailySessionPath.minimum,
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

WeeklyArtifact _artifact({
  required String periodId,
  required DateTime createdAt,
  int completedDays = 2,
  int sessions = 2,
}) {
  final summary = WeeklyReviewSummary(
    periodId: periodId,
    periodStartDayKey: '2026-07-27',
    periodEndDayKey: '2026-08-02',
    completedSessionCount: sessions,
    completedDayCount: completedDays,
    minimumPathCount: 1,
    standardPathCount: sessions > 1 ? 1 : 0,
    pathMixLabel: sessions == 1
        ? PathMixLabel.singleSessionOnly
        : PathMixLabel.balanced,
    rhythmLabel: RhythmLabel.intermittent,
    evidenceDepth: sessions == 1
        ? EvidenceDepth.limited
        : EvidenceDepth.developing,
    manageabilityResponse: 'about_right',
    pauseFocusResponse: 3,
    obstacleResponse: 'time',
    supportResponses: const [],
    accessibilityUsed: null,
    strongestObservedPattern: 'mixed_paths',
    attentionNext: 'maintain_observation',
    planUnchangedNotice: true,
    confidenceQualifier: 'early_evidence',
    generatedAt: createdAt,
    modelVersion: WeeklyReviewVersion.reviewModel,
  );
  final id = WeeklyArtifact.idFor(periodId);
  final hash = WeeklyArtifact.computeHash(
    artifactId: id,
    weeklyReviewRecordId: 'wr_$periodId',
    periodId: periodId,
    sourceProgressSnapshotId: 'snap_a',
    sourcePlanId: 'plan_a',
    sourceProfilePackId: 'pack_a',
    sourceRecoveryScoreReference: 'recovery_score_v1',
    summary: summary,
    completedSessionIds: const ['s1'],
  );
  return WeeklyArtifact(
    artifactId: id,
    weeklyReviewRecordId: 'wr_$periodId',
    periodId: periodId,
    sourceProgressSnapshotId: 'snap_a',
    sourcePlanId: 'plan_a',
    sourceProfilePackId: 'pack_a',
    sourceRecoveryScoreReference: 'recovery_score_v1',
    summary: summary,
    completedSessionIds: const ['s1'],
    createdAt: createdAt,
    artifactSchemaVersion: WeeklyReviewVersion.artifactSchema,
    reviewModelVersion: WeeklyReviewVersion.reviewModel,
    immutableHash: hash,
  );
}

ProfilePack _pack({
  required String id,
  required int score,
  required DateTime createdAt,
  BrainCheckMode mode = BrainCheckMode.full,
  String modelVersion = 'recovery_score_v1',
  MeasurementConfidence confidence = MeasurementConfidence.moderate,
  bool pending = false,
}) {
  final domains = [
    BrainProfileDomainResult(
      domainId: 'attention',
      titleEn: 'Attention',
      titleAr: 'الانتباه',
      answeredCount: 3,
      expectedCount: 3,
      missingQuestionIds: const [],
      normalizedMean: score.toDouble(),
      displayScore: score,
    ),
  ];
  return ProfilePack(
    id: id,
    source: ProfileSourceReference(
      sessionId: 'sess_$id',
      mode: mode,
      brainCheckSchemaVersion: ProfileVersion.brainCheckSchema,
    ),
    createdAt: createdAt,
    lastRecalculatedAt: createdAt,
    domains: domains,
    recoveryScore: pending
        ? RecoveryScore.pending
        : RecoveryScore(
            modelVersion: modelVersion,
            band: RecoveryScoreBand.findingSteadiness,
            value: score,
            valueInternal: score.toDouble(),
            weightSetVersion: ProfileVersion.weightSet,
          ),
    confidence: confidence,
    explanation: ProfileExplanationCatalog.build(
      strongerTitlesEn: const [],
      strongerTitlesAr: const [],
      supportTitlesEn: const [],
      supportTitlesAr: const [],
      confidence: confidence,
      scorePending: pending,
    ),
    profileSchemaVersion: ProfileVersion.profileSchema,
    domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportsOverviewBuilder evidence depth', () {
    test('zero / early / developing / established', () {
      expect(
        ReportsOverviewBuilder.evidenceDepth(
          completedSessionCount: 0,
          completedDayCount: 0,
          weeklyArtifactCount: 0,
          validMeasurementCount: 0,
        ),
        ReportsEvidenceDepth.noEvidence,
      );
      expect(
        ReportsOverviewBuilder.evidenceDepth(
          completedSessionCount: 1,
          completedDayCount: 1,
          weeklyArtifactCount: 0,
          validMeasurementCount: 0,
        ),
        ReportsEvidenceDepth.earlyEvidence,
      );
      expect(
        ReportsOverviewBuilder.evidenceDepth(
          completedSessionCount: 4,
          completedDayCount: 4,
          weeklyArtifactCount: 1,
          validMeasurementCount: 0,
        ),
        ReportsEvidenceDepth.earlyEvidence,
      );
      expect(
        ReportsOverviewBuilder.evidenceDepth(
          completedSessionCount: 5,
          completedDayCount: 4,
          weeklyArtifactCount: 2,
          validMeasurementCount: 1,
        ),
        ReportsEvidenceDepth.developingEvidence,
      );
      expect(
        ReportsOverviewBuilder.evidenceDepth(
          completedSessionCount: 10,
          completedDayCount: 10,
          weeklyArtifactCount: 4,
          validMeasurementCount: 2,
        ),
        ReportsEvidenceDepth.establishedHistory,
      );
    });

    test('deterministic overview id for identical inputs', () {
      final stats = ProgressEngine.build(
        sessions: [_session(id: 's1', dayKey: '2026-07-28')],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      ).statistics;
      final a = ReportsOverviewBuilder.build(
        asOfDayKey: '2026-08-03',
        nowUtc: DateTime.utc(2026, 8, 3, 12),
        snapshot: null,
        stats: stats,
        firstDay: '2026-07-28',
        lastDay: '2026-07-28',
        artifactsNewestFirst: const [],
        validMeasurementsNewestFirst: const [],
        hasComparablePair: false,
        hasIncompatibleOnly: false,
      );
      final b = ReportsOverviewBuilder.build(
        asOfDayKey: '2026-08-03',
        nowUtc: DateTime.utc(2026, 8, 3, 18),
        snapshot: null,
        stats: stats,
        firstDay: '2026-07-28',
        lastDay: '2026-07-28',
        artifactsNewestFirst: const [],
        validMeasurementsNewestFirst: const [],
        hasComparablePair: false,
        hasIncompatibleOnly: false,
      );
      expect(a.reportOverviewId, b.reportOverviewId);
      expect(a.evidenceDepth, ReportsEvidenceDepth.earlyEvidence);
      expect(a.primaryCta, ReportsPrimaryCta.backToProgress);
    });
  });

  group('Archive gate Free/Premium', () {
    test('Free latest+previous; Premium full', () {
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(0, isPremium: false),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(1, isPremium: false),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: false),
        isFalse,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: true),
        isTrue,
      );
      expect(
        ReportsArchiveGate.visibleArtifactCount(5, isPremium: false),
        2,
      );
      expect(
        ReportsArchiveGate.visibleArtifactCount(5, isPremium: true),
        5,
      );
      expect(
        ReportsArchiveGate.visibleMeasurementCount(4, isPremium: false),
        2,
      );
    });
  });

  group('MeasurementHistoryEngine', () {
    test('one measurement insufficient; compatible higher/lower/same', () {
      final older = _pack(
        id: 'p1',
        score: 40,
        createdAt: DateTime.utc(2026, 6, 1),
      );
      final newerHigh = _pack(
        id: 'p2',
        score: 50,
        createdAt: DateTime.utc(2026, 7, 1),
      );
      final newerSame = _pack(
        id: 'p3',
        score: 40,
        createdAt: DateTime.utc(2026, 7, 10),
      );
      expect(
        MeasurementHistoryEngine.compareOverall(latest: older, earlier: null)
            .result,
        ReportsComparisonResult.insufficientHistory,
      );
      final up = MeasurementHistoryEngine.compareOverall(
        latest: newerHigh,
        earlier: older,
      );
      expect(up.result, ReportsComparisonResult.higher);
      expect(up.tooEarlyToInterpret, isFalse);
      expect(
        MeasurementHistoryEngine.compareOverall(
          latest: older,
          earlier: newerHigh,
        ).result,
        ReportsComparisonResult.lower,
      );
      expect(
        MeasurementHistoryEngine.compareOverall(
          latest: newerSame,
          earlier: older,
        ).result,
        ReportsComparisonResult.unchangedWithinRounding,
      );
    });

    test('incompatible model / mode / soft early delta', () {
      final a = _pack(
        id: 'a',
        score: 40,
        createdAt: DateTime.utc(2026, 7, 1),
      );
      final badModel = _pack(
        id: 'b',
        score: 50,
        createdAt: DateTime.utc(2026, 7, 20),
        modelVersion: 'recovery_score_pending_v0',
      );
      final lite = _pack(
        id: 'c',
        score: 50,
        createdAt: DateTime.utc(2026, 7, 20),
        mode: BrainCheckMode.lite,
      );
      expect(
        MeasurementHistoryEngine.compareOverall(latest: badModel, earlier: a)
            .result,
        ReportsComparisonResult.notComparable,
      );
      expect(
        MeasurementHistoryEngine.compareOverall(latest: lite, earlier: a)
            .result,
        ReportsComparisonResult.notComparable,
      );
      final near = _pack(
        id: 'd',
        score: 42,
        createdAt: DateTime.utc(2026, 7, 3),
      );
      final soft = MeasurementHistoryEngine.compareOverall(
        latest: near,
        earlier: a,
      );
      expect(soft.result, ReportsComparisonResult.higher);
      expect(soft.tooEarlyToInterpret, isTrue);
    });

    test('pending packs excluded from valid history', () {
      final pending = _pack(
        id: 'pend',
        score: 0,
        createdAt: DateTime.utc(2026, 7, 1),
        pending: true,
      );
      final valid = _pack(
        id: 'ok',
        score: 55,
        createdAt: DateTime.utc(2026, 7, 2),
      );
      final list = MeasurementHistoryEngine.validNewestFirst([pending, valid]);
      expect(list.length, 1);
      expect(list.first.id, 'ok');
    });
  });

  group('ReportsController integration', () {
    late String tempDir;
    late Box<dynamic> sessionBox;
    late Box<dynamic> progressBox;
    late Box<dynamic> reviewBox;
    late Box<dynamic> profileBox;
    var premium = false;

    setUp(() async {
      premium = false;
      tempDir =
          '${Directory.systemTemp.path}/rpt82_${DateTime.now().microsecondsSinceEpoch}';
      await Directory(tempDir).create(recursive: true);
      PathProviderPlatform.instance = _FakePathProvider(tempDir);
      HiveBootstrap.resetForTesting();
      await Hive.initFlutter(tempDir);
      sessionBox = await Hive.openBox('t_sess');
      progressBox = await Hive.openBox('t_prog');
      reviewBox = await Hive.openBox('t_wrv');
      profileBox = await Hive.openBox('t_prof');
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

    Future<ReportsController> boot() async {
      return ReportsController(
        sessions: DailySessionLocalRepository(box: sessionBox),
        progress: ProgressLocalRepository(box: progressBox),
        reviews: WeeklyReviewLocalRepository(box: reviewBox),
        profiles: BrainProfileLocalRepository(box: profileBox),
        isPremium: () => premium,
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
    }

    Future<void> seedSessions(List<DailySession> sessions) async {
      final repo = DailySessionLocalRepository(box: sessionBox);
      for (final s in sessions) {
        await repo.saveCompletion(session: s, mark: s.mark!);
      }
      final snap = ProgressEngine.build(
        sessions: sessions,
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      );
      await ProgressLocalRepository(box: progressBox).saveIfNew(snap);
    }

    Future<void> seedArtifacts(List<WeeklyArtifact> arts) async {
      await reviewBox.put(
        WeeklyReviewLocalRepository.artifactsKey,
        arts.map((a) => a.toJson()).toList(),
      );
      await reviewBox.put(
        WeeklyReviewLocalRepository.schemaKey,
        WeeklyReviewVersion.schema,
      );
    }

    Future<void> seedPacks(List<ProfilePack> packs) async {
      final repo = BrainProfileLocalRepository(box: profileBox);
      for (final p in packs) {
        await repo.save(p);
      }
    }

    test('zero evidence empty state', () async {
      final c = await boot();
      await c.loadOverview();
      expect(c.phase, ReportsPhase.empty);
      expect(c.overview.evidenceDepth, ReportsEvidenceDepth.noEvidence);
      expect(c.overview.primaryCta, ReportsPrimaryCta.goToToday);
    });

    test('one session early evidence; rebuild after restart', () async {
      await seedSessions([_session(id: 's1', dayKey: '2026-07-28')]);
      var c = await boot();
      await c.loadOverview();
      expect(c.phase, ReportsPhase.ready);
      expect(c.overview.evidenceDepth, ReportsEvidenceDepth.earlyEvidence);
      expect(c.overview.completedSessionCount, 1);
      final id1 = c.overview.reportOverviewId;

      c = await boot();
      await c.loadOverview();
      expect(c.overview.reportOverviewId, id1);
      expect(c.overview.completedSessionCount, 1);
    });

    test('developing and established depths', () async {
      final sessions = [
        for (var i = 0; i < 5; i++)
          _session(
            id: 's$i',
            dayKey: '2026-07-${25 + i}',
            path: i.isEven
                ? DailySessionPath.minimum
                : DailySessionPath.standard,
          ),
      ];
      await seedSessions(sessions);
      await seedArtifacts([
        _artifact(
          periodId: 'iso_2026_W30',
          createdAt: DateTime.utc(2026, 7, 27),
        ),
        _artifact(
          periodId: 'iso_2026_W31',
          createdAt: DateTime.utc(2026, 8, 3),
        ),
      ]);
      var c = await boot();
      await c.loadOverview();
      expect(c.overview.evidenceDepth, ReportsEvidenceDepth.developingEvidence);

      await seedArtifacts([
        for (var w = 28; w <= 31; w++)
          _artifact(
            periodId: 'iso_2026_W$w',
            createdAt: DateTime.utc(2026, 7, w - 20),
          ),
      ]);
      await seedPacks([
        _pack(id: 'p1', score: 40, createdAt: DateTime.utc(2026, 6, 1)),
        _pack(id: 'p2', score: 55, createdAt: DateTime.utc(2026, 7, 15)),
      ]);
      c = await boot();
      await c.loadOverview();
      expect(c.overview.evidenceDepth, ReportsEvidenceDepth.establishedHistory);
      expect(
        c.overview.measurementStatus,
        ReportsMeasurementStatus.comparableAvailable,
      );
    });

    test('Free archive depth vs Premium; content identical', () async {
      await seedSessions([_session(id: 's1', dayKey: '2026-07-28')]);
      final arts = [
        for (var i = 0; i < 4; i++)
          _artifact(
            periodId: 'iso_2026_W${28 + i}',
            createdAt: DateTime.utc(2026, 7, 20 + i),
          ),
      ];
      await seedArtifacts(arts);
      premium = false;
      var c = await boot();
      await c.loadOverview();
      expect(c.visibleArtifacts.length, 2);
      expect(c.premiumLockedArtifactCount, 2);
      final freeLatest = c.visibleArtifacts.first.immutableHash;

      // Newest is Free-accessible.
      await c.loadArtifact(arts.last.artifactId);
      expect(c.artifactPhase, ArtifactDetailPhase.ready);

      // Oldest is Premium-gated for Free.
      final oldest = arts.first;
      await c.loadArtifact(oldest.artifactId);
      expect(c.artifactPhase, ArtifactDetailPhase.premiumGated);

      premium = true;
      c = await boot();
      await c.loadOverview();
      expect(c.visibleArtifacts.length, 4);
      expect(c.visibleArtifacts.first.immutableHash, freeLatest);
      await c.loadArtifact(oldest.artifactId);
      expect(c.artifactPhase, ArtifactDetailPhase.ready);
      expect(c.selectedArtifact!.immutableHash, oldest.immutableHash);
    });

    test('artifact detail hides source ids; missing artifact recovers', () async {
      await seedArtifacts([
        _artifact(
          periodId: 'iso_2026_W31',
          createdAt: DateTime.utc(2026, 8, 3),
        ),
      ]);
      final c = await boot();
      await c.loadOverview();
      await c.loadArtifact(c.overview.latestWeeklyArtifactId);
      expect(c.artifactPhase, ArtifactDetailPhase.ready);
      expect(c.selectedArtifact!.summary.planUnchangedNotice, isTrue);

      await c.loadArtifact('wart_missing');
      expect(c.artifactPhase, ArtifactDetailPhase.missing);
    });

    test('measurement history one vs multiple; no score mutation', () async {
      final p1 = _pack(
        id: 'p1',
        score: 44,
        createdAt: DateTime.utc(2026, 6, 1),
      );
      await seedPacks([p1]);
      var c = await boot();
      await c.loadOverview();
      await c.loadMeasurements();
      expect(c.measurementPhase, MeasurementHistoryPhase.baselineOnly);
      expect(
        c.comparison.result,
        ReportsComparisonResult.insufficientHistory,
      );

      final p2 = _pack(
        id: 'p2',
        score: 60,
        createdAt: DateTime.utc(2026, 7, 20),
      );
      await seedPacks([p2]);
      c = await boot();
      await c.loadOverview();
      await c.loadMeasurements();
      expect(c.measurementPhase, MeasurementHistoryPhase.ready);
      expect(c.comparison.result, ReportsComparisonResult.higher);

      final again = await BrainProfileLocalRepository(box: profileBox).history();
      expect(again.map((e) => e.recoveryScore.value).toList(), [44, 60]);
    });

    test('corrupt artifact skipped; overview still builds', () async {
      await seedSessions([_session(id: 's1', dayKey: '2026-07-28')]);
      final good = _artifact(
        periodId: 'iso_2026_W31',
        createdAt: DateTime.utc(2026, 8, 3),
      );
      await reviewBox.put(WeeklyReviewLocalRepository.artifactsKey, [
        {'artifactId': 'bad', 'broken': true},
        good.toJson(),
      ]);
      await reviewBox.put(
        WeeklyReviewLocalRepository.schemaKey,
        WeeklyReviewVersion.schema,
      );
      final c = await boot();
      await c.loadOverview();
      expect(c.overview.weeklyArtifactCount, 1);
      expect(c.visibleArtifacts.single.artifactId, good.artifactId);
    });

    test('missing ProgressSnapshot still derives counts', () async {
      final sessions = [_session(id: 's1', dayKey: '2026-07-28')];
      final repo = DailySessionLocalRepository(box: sessionBox);
      await repo.saveCompletion(session: sessions.first, mark: sessions.first.mark!);
      final c = await boot();
      await c.loadOverview();
      expect(c.overview.completedSessionCount, 1);
      expect(c.overview.snapshotMissing, isTrue);
      expect(c.phase, ReportsPhase.snapshotMissing);
    });
  });

  group('Localization + accessibility smoke', () {
    test('canonical EN/AR terms present; no banned wording', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2ReportsTitle, 'Reports');
      expect(ar.v2ReportsTitle, 'التقارير');
      expect(en.v2ReportsEvidenceOverview, 'Evidence overview');
      expect(ar.v2ReportsEvidenceOverview, 'نظرة عامة على الأدلة');
      expect(en.v2ReportsWeeklyHistory, 'Weekly history');
      expect(ar.v2ReportsWeeklyHistory, 'السجل الأسبوعي');
      expect(en.v2ReportsWeeklyReport, 'Weekly report');
      expect(ar.v2ReportsWeeklyReport, 'تقرير الأسبوع');
      expect(en.v2ReportsMeasurementHistory, 'Measurement history');
      expect(ar.v2ReportsMeasurementHistory, 'سجل القياسات');
      expect(
        en.v2ReportsEvidenceStillDeveloping,
        'Your evidence is still developing',
      );
      expect(ar.v2ReportsEvidenceStillDeveloping, contains('التكوّن'));
      expect(en.v2ReportsNotEnoughMeasurements, contains('Not enough'));
      expect(ar.v2ReportsNotEnoughMeasurements, contains('قياسات'));
      expect(en.v2ReportsComparedWithEarlier, contains('earlier'));
      expect(ar.v2ReportsComparedWithEarlier, contains('مقارنة'));
      expect(en.v2ReportsSelfReportEstimate, contains('self-report'));
      expect(ar.v2ReportsSelfReportEstimate, contains('تقدير'));
      expect(en.v2ReportsNoCauseFromHistory, contains('No cause'));
      expect(ar.v2ReportsNoCauseFromHistory, contains('السبب'));
      expect(en.v2ReportsBackOverview.isNotEmpty, isTrue);
      expect(ar.v2ReportsBackOverview.isNotEmpty, isTrue);

      for (final s in [
        en.v2ReportsOrientation,
        en.v2ReportsComparisonHigher,
        ar.v2ReportsOrientation,
        ar.v2ReportsComparisonHigher,
      ]) {
        final lower = s.toLowerCase();
        expect(lower.contains('healed'), isFalse);
        expect(lower.contains('damaged'), isFalse);
        expect(lower.contains('cured'), isFalse);
        expect(lower.contains('diagnos'), isFalse);
        expect(lower.contains('%'), isFalse);
      }
    });
  });

  group('Routing / feature flag', () {
    test('routes defined and Reports gate aliases Brain Profile', () {
      expect(AppRoutes.v2Reports, '/v2/reports');
      expect(AppRoutes.v2ReportArtifact, '/v2/reports/artifact');
      expect(AppRoutes.v2ReportMeasurements, '/v2/reports/measurements');
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableReportsRoutes, isFalse);
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableReportsRoutes, isTrue);
      V2FeatureBoundary.enableBrainProfileRoutes = false;
    });
  });
}
