import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_bhi_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late DiagnosticLocalRepository repository;

  setUp(() async {
    HiveBootstrap.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('bc_diagnostic_hive_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();
    if (Hive.isBoxOpen(HiveBoxes.diagnosticPersistence)) {
      await Hive.box(HiveBoxes.diagnosticPersistence).close();
    }
    final box = await Hive.openBox<dynamic>(HiveBoxes.diagnosticPersistence);
    repository = DiagnosticLocalRepository(box: box);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  test('persists and restores committed session across box reopen', () async {
    const model = DiagnosticModel(
      brainPerformance: 77,
      digitalDiscipline: 66,
      healthyHabits: 55,
      consistency: 44,
    );
    final session = DiagnosticSession.fromAssessment(
      model: model,
      metrics: const DiagnosticMetrics(sleepQuality: 7),
      brainRot: DiagnosticModel.evaluateBrainRot(List<bool>.filled(10, false)),
      brainRotAnswers: List<bool>.filled(10, false),
      committedAt: DateTime(2026, 5, 20, 10),
    );

    await repository.saveCommittedSession(session);
    if (Hive.isBoxOpen(HiveBoxes.diagnosticPersistence)) {
      await Hive.box(HiveBoxes.diagnosticPersistence).close();
    }
    final reopened = await Hive.openBox<dynamic>(HiveBoxes.diagnosticPersistence);
    final reloadRepo = DiagnosticLocalRepository(box: reopened);

    final restored = (await reloadRepo.loadBundle()).committedSession;
    expect(restored, isNotNull);
    expect(restored!.bcScore, closeTo(session.bcScore, 0.01));
    expect(restored.metrics.sleepQuality, 7);
  });

  test('persists draft metrics and questionnaire', () async {
    const metrics = DiagnosticMetrics(sleepQuality: 8, burnout: 3);
    const questionnaire = BrainRotQuestionnaireSnapshot(
      answers: [true, false, null, null, null, null, null, null, null, null],
      currentIndex: 2,
    );

    await repository.saveDraft(
      metrics: metrics,
      questionnaire: questionnaire,
    );

    final bundle = await repository.loadBundle();
    expect(bundle.metrics?.sleepQuality, 8);
    expect(bundle.metrics?.burnout, 3);
    expect(bundle.questionnaire?.currentIndex, 2);
    expect(bundle.questionnaire?.answers[0], isTrue);
  });

  test('clearDraft removes draft keys only', () async {
    const metrics = DiagnosticMetrics(sleepQuality: 6);
    final session = DiagnosticSession.fromAssessment(
      model: const DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      ),
      metrics: metrics,
      brainRot: DiagnosticModel.evaluateBrainRot(List<bool>.filled(10, false)),
      brainRotAnswers: List<bool>.filled(10, false),
      committedAt: DateTime(2026, 5, 21),
    );
    await repository.saveCommittedSession(session);
    await repository.saveDraft(metrics: metrics);
    await repository.clearDraft();

    final bundle = await repository.loadBundle();
    expect(bundle.committedSession, isNotNull);
    expect(bundle.metrics, isNull);
  });
}
