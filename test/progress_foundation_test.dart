import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/daily_session/data/daily_session_repository.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_path.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_source_reference.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_status.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_step_state.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_version.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/session_marked.dart';
import 'package:brain_clean_mobile/features/progress/application/progress_controller.dart';
import 'package:brain_clean_mobile/features/progress/data/progress_repository.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_engine.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_version.dart';
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
  required List<DailySessionStepState> steps,
  bool full = true,
  String planId = 'plan_a',
  String profileId = 'pack_a',
  DateTime? completedAt,
}) {
  final mark = SessionMarked(
    id: SessionMarked.buildId(id),
    dailySessionId: id,
    todayActId: 'tact_a',
    planId: planId,
    dayKey: dayKey,
    path: path,
    completedAt: completedAt ?? DateTime.utc(2026, 8, 1),
    fullCompletion: full,
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
    status: full ? DailySessionStatus.completed : DailySessionStatus.partial,
    path: path,
    orderedStepIds: steps.map((s) => s.stepId).toList(),
    steps: steps,
    currentStepIndex: 0,
    startedAt: DateTime.utc(2026, 8, 1),
    updatedAt: DateTime.utc(2026, 8, 1),
    completedAt: mark.completedAt,
    mark: mark,
    schemaVersion: DailySessionVersion.schema,
  );
}

DailySessionStepState _done(String id, {bool optional = false}) =>
    DailySessionStepState(
      stepId: id,
      optional: optional,
      phase: DailySessionStepPhase.completed,
      completedAt: DateTime.utc(2026, 8, 1),
    );

DailySessionStepState _skipped(String id) => DailySessionStepState(
      stepId: id,
      optional: true,
      phase: DailySessionStepPhase.skipped,
      skippedAt: DateTime.utc(2026, 8, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String tempDir;

  setUp(() async {
    tempDir =
        '${Directory.systemTemp.path}/prg_${DateTime.now().microsecondsSinceEpoch}';
    await Directory(tempDir).create(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    HiveBootstrap.resetForTesting();
    await Hive.initFlutter(tempDir);
  });

  tearDown(() async {
    await Hive.close();
    HiveBootstrap.resetForTesting();
    try {
      await Directory(tempDir).delete(recursive: true);
    } catch (_) {}
  });

  group('ProgressEngine', () {
    test('empty history is honest empty', () {
      final snap = ProgressEngine.build(
        sessions: const [],
        nowUtc: DateTime.utc(2026, 8, 3),
        asOfDayKey: '2026-08-03',
      );
      expect(snap.isEmpty, isTrue);
      expect(snap.statistics.totalSessions, 0);
      expect(snap.statistics.currentStreak, 0);
      expect(snap.statistics.completionRate, 0);
      expect(snap.summary.hasHistory, isFalse);
      expect(snap.timeline.isEmpty, isTrue);
    });

    test('one completed day', () {
      final s = _session(
        id: 's1',
        dayKey: '2026-08-01',
        path: DailySessionPath.minimum,
        steps: [_done('step_a')],
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 1, 20),
        asOfDayKey: '2026-08-01',
        activePlanId: 'plan_a',
        profilePackId: 'pack_a',
        recoveryScoreModelVersion: 'recovery_score_v1',
      );
      expect(snap.statistics.totalSessions, 1);
      expect(snap.statistics.completedDays, 1);
      expect(snap.statistics.minimumPathCount, 1);
      expect(snap.statistics.standardPathCount, 0);
      expect(snap.statistics.completionRate, 1.0);
      expect(snap.statistics.currentStreak, 1);
      expect(snap.statistics.longestStreak, 1);
      expect(snap.summary.firstCompletedSessionId, 's1');
      expect(snap.summary.lastCompletedSessionId, 's1');
      expect(snap.summary.activePlanId, 'plan_a');
      expect(snap.summary.profilePackId, 'pack_a');
      expect(snap.summary.recoveryScoreModelVersion, 'recovery_score_v1');
    });

    test('multiple sessions, paths, skips, streaks, rate', () {
      final sessions = [
        _session(
          id: 's1',
          dayKey: '2026-08-01',
          path: DailySessionPath.minimum,
          steps: [_done('r1'), _skipped('o1')],
        ),
        _session(
          id: 's2',
          dayKey: '2026-08-02',
          path: DailySessionPath.standard,
          steps: [_done('r1'), _done('r2')],
        ),
        _session(
          id: 's3',
          dayKey: '2026-08-03',
          path: DailySessionPath.standard,
          steps: [_done('r1'), _skipped('o2')],
        ),
        // gap on 04
        _session(
          id: 's4',
          dayKey: '2026-08-05',
          path: DailySessionPath.minimum,
          steps: [_done('r1')],
        ),
      ];
      final snap = ProgressEngine.build(
        sessions: sessions,
        nowUtc: DateTime.utc(2026, 8, 5, 18),
        asOfDayKey: '2026-08-05',
      );
      expect(snap.statistics.totalSessions, 4);
      expect(snap.statistics.completedDays, 4);
      expect(snap.statistics.minimumPathCount, 2);
      expect(snap.statistics.standardPathCount, 2);
      expect(snap.statistics.skippedOptionalSteps, 2);
      expect(snap.statistics.requiredStepsCompleted, 5);
      expect(snap.statistics.longestStreak, 3); // 1-2-3
      expect(snap.statistics.currentStreak, 1); // only 05
      // span 01→05 = 5 days, 4 completed → 0.8
      expect(snap.statistics.completionRate, closeTo(0.8, 0.001));
      expect(snap.timeline.entries.length, 4);
      expect(snap.summary.firstCompletedSessionId, 's1');
      expect(snap.summary.lastCompletedSessionId, 's4');
    });

    test('partial without fullCompletion excluded', () {
      final partial = _session(
        id: 'p1',
        dayKey: '2026-08-01',
        path: DailySessionPath.minimum,
        steps: [_done('r1')],
        full: false,
      );
      final snap = ProgressEngine.build(
        sessions: [partial],
        nowUtc: DateTime.utc(2026, 8, 1),
        asOfDayKey: '2026-08-01',
      );
      expect(snap.isEmpty, isTrue);
    });

    test('deterministic content hash', () {
      final s = _session(
        id: 's1',
        dayKey: '2026-08-01',
        path: DailySessionPath.minimum,
        steps: [_done('r1')],
      );
      final a = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 1, 10),
        asOfDayKey: '2026-08-01',
      );
      final b = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 1, 22),
        asOfDayKey: '2026-08-01',
      );
      expect(a.contentHash, b.contentHash);
    });

    test('grace streak uses yesterday when today empty', () {
      final s = _session(
        id: 's1',
        dayKey: '2026-08-02',
        path: DailySessionPath.minimum,
        steps: [_done('r1')],
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 3, 8),
        asOfDayKey: '2026-08-03',
      );
      expect(snap.statistics.currentStreak, 1);
    });
  });

  group('repository + controller', () {
    test('append-only + idempotent save + corrupt skip', () async {
      final box = await Hive.openBox<dynamic>('progress_box');
      final repo = ProgressLocalRepository(box: box);
      final s = _session(
        id: 's1',
        dayKey: '2026-08-01',
        path: DailySessionPath.minimum,
        steps: [_done('r1')],
      );
      final snap = ProgressEngine.build(
        sessions: [s],
        nowUtc: DateTime.utc(2026, 8, 1),
        asOfDayKey: '2026-08-01',
      );
      final a = await repo.saveIfNew(snap);
      final b = await repo.saveIfNew(snap);
      expect(a.id, b.id);
      expect((await repo.history()).length, 1);

      await box.put(ProgressLocalRepository.historyKey, [
        {'broken': true},
        snap.toJson(),
      ]);
      final hist = await repo.history();
      expect(hist.length, 1);
      expect(HiveBoxes.progress, ProgressVersion.box);
      await box.close();
    });

    test('controller refresh + hydrate survives restart', () async {
      final sessBox = await Hive.openBox<dynamic>('sessions');
      final progBox = await Hive.openBox<dynamic>('progress');
      final sessions = DailySessionLocalRepository(box: sessBox);
      final progress = ProgressLocalRepository(box: progBox);
      final s = _session(
        id: 's1',
        dayKey: '2026-08-01',
        path: DailySessionPath.standard,
        steps: [_done('r1'), _done('r2', optional: false)],
      );
      await sessions.save(s);
      // ensure mark listed via completion path too
      await sessions.saveCompletion(session: s, mark: s.mark!);

      final c1 = ProgressController(
        sessions: sessions,
        progress: progress,
        clock: () => DateTime.utc(2026, 8, 1, 12),
        timeZoneOffset: Duration.zero,
      );
      await c1.refresh();
      expect(c1.snapshot!.statistics.totalSessions, 1);
      expect(c1.isEmpty, isFalse);

      final c2 = ProgressController(
        sessions: sessions,
        progress: progress,
        clock: () => DateTime.utc(2026, 8, 1, 15),
        timeZoneOffset: Duration.zero,
      );
      await c2.hydrateLatest();
      expect(c2.snapshot!.statistics.totalSessions, 1);
      expect(c2.snapshot!.contentHash, c1.snapshot!.contentHash);
      await sessBox.close();
      await progBox.close();
    });

    test('empty refresh does not invent history', () async {
      final sessBox = await Hive.openBox<dynamic>('sessions_e');
      final progBox = await Hive.openBox<dynamic>('progress_e');
      final c = ProgressController(
        sessions: DailySessionLocalRepository(box: sessBox),
        progress: ProgressLocalRepository(box: progBox),
        clock: () => DateTime.utc(2026, 8, 1),
        timeZoneOffset: Duration.zero,
      );
      await c.refresh();
      expect(c.isEmpty, isTrue);
      expect(c.snapshot!.summary.hasHistory, isFalse);
      await sessBox.close();
      await progBox.close();
    });
  });

  group('localization', () {
    test('EN/AR parity and calm wording', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      expect(en.v2ProgressEmptyTitle, isNotEmpty);
      expect(ar.v2ProgressEmptyTitle, isNotEmpty);
      expect(en.v2ProgressEmptyBody.toLowerCase(), contains('nothing is invented'));
      expect(ar.v2ProgressEmptyBody, contains('لا يُختلق'));
      final enApp = AppLocalizationsEn();
      final arApp = AppLocalizationsAr();
      final blob =
          '${enApp.v2ProgressEmptyBody} ${arApp.v2ProgressEmptyBody}'.toLowerCase();
      expect(blob.contains('diagnose'), isFalse);
      expect(RegExp(r'\bcure\b').hasMatch(blob), isFalse);
      expect(blob.contains('clinical'), isFalse);
    });
  });
}
