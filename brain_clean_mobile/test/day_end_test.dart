import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/daily_program/data/daily_program_repository_impl.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_service.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('DailyProgramService.reflectionQuestionIndex', () {
    test('rotates by date.day % 4', () {
      expect(
        DailyProgramService.reflectionQuestionIndex(DateTime(2026, 7, 20)),
        0,
      );
      expect(
        DailyProgramService.reflectionQuestionIndex(DateTime(2026, 7, 21)),
        1,
      );
      expect(
        DailyProgramService.reflectionQuestionIndex(DateTime(2026, 7, 22)),
        2,
      );
      expect(
        DailyProgramService.reflectionQuestionIndex(DateTime(2026, 7, 23)),
        3,
      );
      expect(
        DailyProgramService.reflectionQuestionIndex(DateTime(2026, 7, 24)),
        0,
      );
    });
  });

  group('DailyProgramRepositoryImpl.completeDayEnd', () {
    late Directory tempDir;
    late DailyProgramRepositoryImpl repository;

    setUp(() async {
      HiveBootstrap.resetForTesting();
      tempDir = await Directory.systemTemp.createTemp('bc_day_end_hive_');
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

    Future<void> advanceToDayEnd() async {
      var state = await repository.getToday(dayNumber: 1);
      for (final step in [
        DailyStep.dayStart,
        DailyStep.water,
        DailyStep.movement,
        DailyStep.sukoon,
        DailyStep.focusTask,
        DailyStep.mood,
        DailyStep.journal,
      ]) {
        state = await repository.completeStep(step);
      }
      expect(state.currentStep?.step, DailyStep.dayEnd);
    }

    test('completeDayEnd marks program finished and saves reflectionNote',
        () async {
      await advanceToDayEnd();

      final finished = await repository.completeDayEnd(
        reflectionNote: '  شكراً على يوم هادئ  ',
      );

      expect(finished.isAllDone, isTrue);
      expect(finished.reflectionNote, 'شكراً على يوم هادئ');
      expect(finished.steps.last.step, DailyStep.dayEnd);
      expect(finished.steps.last.status, DailyStepStatus.done);

      if (Hive.isBoxOpen(HiveBoxes.dailyProgram)) {
        await Hive.box(HiveBoxes.dailyProgram).close();
      }
      final reopened = await Hive.openBox<dynamic>(HiveBoxes.dailyProgram);
      final reloadRepo = DailyProgramRepositoryImpl(box: reopened);
      final restored = await reloadRepo.getToday(dayNumber: 1);

      expect(restored.reflectionNote, 'شكراً على يوم هادئ');
      expect(restored.isAllDone, isTrue);
    });

    test('completeDayEnd without note stores null reflectionNote', () async {
      await advanceToDayEnd();

      final finished = await repository.completeDayEnd();
      expect(finished.isAllDone, isTrue);
      expect(finished.reflectionNote, isNull);
    });

    test('day-end summary counts treat done/skipped/remaining separately',
        () async {
      await advanceToDayEnd();
      final state = await repository.getToday(dayNumber: 1);

      final completed =
          state.steps.where((s) => s.status == DailyStepStatus.done).length;
      final skipped =
          state.steps.where((s) => s.status == DailyStepStatus.skipped).length;
      final remaining = state.steps
          .where(
            (s) =>
                s.status == DailyStepStatus.current ||
                s.status == DailyStepStatus.locked,
          )
          .length;

      expect(completed + skipped + remaining, state.steps.length);
      expect(state.currentStep?.step, DailyStep.dayEnd);
      expect(remaining, greaterThanOrEqualTo(1));
    });
  });
}
