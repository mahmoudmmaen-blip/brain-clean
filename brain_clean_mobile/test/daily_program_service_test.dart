import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_service.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_state.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyProgramService.buildTodaySteps', () {
    test('returns fixed order with first current and rest locked', () {
      final steps = DailyProgramService.buildTodaySteps();
      expect(
        steps.map((e) => e.step).toList(),
        [
          DailyStep.dayStart,
          DailyStep.water,
          DailyStep.movement,
          DailyStep.sukoon,
          DailyStep.focusTask,
          DailyStep.mood,
          DailyStep.journal,
          DailyStep.dayEnd,
        ],
      );
      expect(steps.length, 8);
      expect(steps.first.status, DailyStepStatus.current);
      expect(
        steps.skip(1).every((e) => e.status == DailyStepStatus.locked),
        isTrue,
      );
    });
  });

  group('DailyProgramService.ensureCurrentStepSchema', () {
    test('inserts focusTask into older 7-step payloads', () {
      final legacy = [
        for (final step in [
          DailyStep.dayStart,
          DailyStep.water,
          DailyStep.movement,
          DailyStep.sukoon,
          DailyStep.mood,
          DailyStep.journal,
          DailyStep.dayEnd,
        ])
          DailyStepEntry(
            step: step,
            status: step == DailyStep.dayStart
                ? DailyStepStatus.done
                : step == DailyStep.water
                    ? DailyStepStatus.current
                    : DailyStepStatus.locked,
          ),
      ];

      final migrated = DailyProgramService.ensureCurrentStepSchema(legacy);
      expect(migrated.map((e) => e.step).toList(), DailyStep.values);
      expect(migrated[0].status, DailyStepStatus.done);
      expect(migrated[1].status, DailyStepStatus.current);
      expect(migrated[4].step, DailyStep.focusTask);
      expect(migrated[4].status, DailyStepStatus.locked);
    });
  });

  group('DailyProgramService.afterComplete', () {
    test('marks step done and unlocks the next locked step', () {
      final initial = DailyProgramService.buildTodaySteps();
      final after = DailyProgramService.afterComplete(
        initial,
        DailyStep.dayStart,
      );

      expect(after[0].status, DailyStepStatus.done);
      expect(after[0].completedAt, isNotNull);
      expect(after[1].status, DailyStepStatus.current);
      expect(after[2].status, DailyStepStatus.locked);
    });

    test('toJson nests step maps so Hive can persist (no Freezed objects)', () {
      final initial = DailyProgramService.buildTodaySteps();
      final after = DailyProgramService.afterComplete(
        initial,
        DailyStep.dayStart,
      );
      final stateJson = {
        'date': DateTime(2026, 7, 17).toIso8601String(),
        'dayNumber': 1,
        'steps': after.map((e) => e.toJson()).toList(),
      };

      expect(stateJson['steps'], isA<List<dynamic>>());
      final first = (stateJson['steps'] as List).first;
      expect(first, isA<Map<String, dynamic>>());
      expect(first['step'], 'dayStart');
      expect(first['status'], 'done');
    });
  });

  group('DailyProgramService.afterSkip', () {
    test('skips journal and unlocks dayEnd', () {
      var steps = DailyProgramService.buildTodaySteps();
      for (final step in [
        DailyStep.dayStart,
        DailyStep.water,
        DailyStep.movement,
        DailyStep.sukoon,
        DailyStep.focusTask,
        DailyStep.mood,
      ]) {
        steps = DailyProgramService.afterComplete(steps, step);
      }

      expect(steps[6].step, DailyStep.journal);
      expect(steps[6].status, DailyStepStatus.current);

      final skipped = DailyProgramService.afterSkip(steps, DailyStep.journal);
      expect(skipped[6].status, DailyStepStatus.skipped);
      expect(skipped[7].status, DailyStepStatus.current);
    });

    test('does nothing when skipping a non-journal step', () {
      final initial = DailyProgramService.buildTodaySteps();
      final same =
          DailyProgramService.afterSkip(initial, DailyStep.water);
      expect(same, initial);
    });
  });

  group('DailyProgramService.getMorningMessage', () {
    test('rotates by day of month modulo 5', () {
      expect(
        DailyProgramService.getMorningMessage(DateTime(2026, 7, 5)),
        'صباح الخير 🌿 هدفنا اليوم مش الكمال، بس خطوة واحدة صح.',
      );
      expect(
        DailyProgramService.getMorningMessage(DateTime(2026, 7, 6)),
        'يوم جديد 🌅 خطوة صغيرة النهارده أحسن من خطة مثالية بكرة.',
      );
      expect(
        DailyProgramService.getMorningMessage(DateTime(2026, 7, 9)),
        'بداية هادية ✨ كل خطوة بتقرّبك من صفاء ذهنك.',
      );
    });
  });

  group('DailyProgramService focusTask copy', () {
    test('exposes Arabic and English focus titles', () {
      expect(
        DailyProgramService.getStepTitle(DailyStep.focusTask),
        'مهمة تركيز واحدة',
      );
      expect(
        DailyProgramService.getStepTitle(
          DailyStep.focusTask,
          languageCode: 'en',
        ),
        'One focus task',
      );
      expect(DailyProgramService.getStepEmoji(DailyStep.focusTask), '🎯');
    });
  });
}
