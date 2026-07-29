import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/daily_program/data/daily_program_repository_impl.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late DailyProgramRepositoryImpl repository;

  setUp(() async {
    HiveBootstrap.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('bc_daily_program_hive_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();
    if (Hive.isBoxOpen(HiveBoxes.dailyProgram)) {
      await Hive.box(HiveBoxes.dailyProgram).close();
    }
    final box = await Hive.openBox<dynamic>(HiveBoxes.dailyProgram);
    repository = DailyProgramRepositoryImpl(box: box);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  test('completeStep persists done + unlocks next current', () async {
    final initial = await repository.getToday(dayNumber: 3);
    expect(initial.steps.first.status, DailyStepStatus.current);
    expect(initial.remainingCount, 8);

    final after = await repository.completeStep(DailyStep.dayStart);

    expect(after.steps[0].status, DailyStepStatus.done);
    expect(after.steps[1].status, DailyStepStatus.current);
    expect(after.remainingCount, 7);
    expect(after.progressRatio, closeTo(1 / 8, 0.001));

    if (Hive.isBoxOpen(HiveBoxes.dailyProgram)) {
      await Hive.box(HiveBoxes.dailyProgram).close();
    }
    final reopened = await Hive.openBox<dynamic>(HiveBoxes.dailyProgram);
    final reloadRepo = DailyProgramRepositoryImpl(box: reopened);
    final restored = await reloadRepo.getToday(dayNumber: 3);

    expect(restored.steps[0].status, DailyStepStatus.done);
    expect(restored.steps[1].status, DailyStepStatus.current);
    expect(restored.remainingCount, 7);
  });
}
