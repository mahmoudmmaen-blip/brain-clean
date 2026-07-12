import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_service.dart';
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
          DailyStep.mood,
          DailyStep.journal,
          DailyStep.dayEnd,
        ],
      );
      expect(steps.first.status, DailyStepStatus.current);
      expect(
        steps.skip(1).every((e) => e.status == DailyStepStatus.locked),
        isTrue,
      );
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
  });

  group('DailyProgramService.afterSkip', () {
    test('skips journal and unlocks dayEnd', () {
      var steps = DailyProgramService.buildTodaySteps();
      for (final step in [
        DailyStep.dayStart,
        DailyStep.water,
        DailyStep.movement,
        DailyStep.sukoon,
        DailyStep.mood,
      ]) {
        steps = DailyProgramService.afterComplete(steps, step);
      }

      expect(steps[5].step, DailyStep.journal);
      expect(steps[5].status, DailyStepStatus.current);

      final skipped = DailyProgramService.afterSkip(steps, DailyStep.journal);
      expect(skipped[5].status, DailyStepStatus.skipped);
      expect(skipped[6].status, DailyStepStatus.current);
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
}
