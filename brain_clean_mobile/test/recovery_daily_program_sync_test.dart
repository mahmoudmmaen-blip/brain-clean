import 'package:brain_clean_mobile/features/daily_program/domain/daily_step.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_daily_program_sync.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_daily_task.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('recoveryAutoMarkForDailyStep', () {
    test('maps water, movement, and sukoon only', () {
      expect(
        recoveryAutoMarkForDailyStep(DailyStep.water),
        RecoveryDailyProgramAutoMark.water,
      );
      expect(
        recoveryAutoMarkForDailyStep(DailyStep.movement),
        RecoveryDailyProgramAutoMark.movement,
      );
      expect(
        recoveryAutoMarkForDailyStep(DailyStep.sukoon),
        RecoveryDailyProgramAutoMark.mentalSupport,
      );
    });

    test('returns null for steps without recovery signals', () {
      expect(recoveryAutoMarkForDailyStep(DailyStep.dayStart), isNull);
      expect(recoveryAutoMarkForDailyStep(DailyStep.focusTask), isNull);
      expect(recoveryAutoMarkForDailyStep(DailyStep.mood), isNull);
      expect(recoveryAutoMarkForDailyStep(DailyStep.journal), isNull);
      expect(recoveryAutoMarkForDailyStep(DailyStep.dayEnd), isNull);
    });
  });

  group('applyRecoveryDailyProgramAutoMark', () {
    test('sets waterCompleted true via toggleWater', () {
      final record = RecoveryDayRecord(dayIndex: 1);
      final next = applyRecoveryDailyProgramAutoMark(
        record,
        RecoveryDailyProgramAutoMark.water,
      );
      expect(next.waterCompleted, isTrue);
      expect(next.sleepCompleted, isFalse);
    });

    test('sets movementTwentyMinutes true via toggleTask', () {
      final record = RecoveryDayRecord(dayIndex: 2);
      final next = applyRecoveryDailyProgramAutoMark(
        record,
        RecoveryDailyProgramAutoMark.movement,
      );
      expect(
        next.taskCompleted[RecoveryDailyTask.movementTwentyMinutes.index],
        isTrue,
      );
      expect(
        next.taskCompleted[RecoveryDailyTask.mentalSupport.index],
        isFalse,
      );
    });

    test('sets mentalSupport true via toggleTask', () {
      final record = RecoveryDayRecord(dayIndex: 3);
      final next = applyRecoveryDailyProgramAutoMark(
        record,
        RecoveryDailyProgramAutoMark.mentalSupport,
      );
      expect(
        next.taskCompleted[RecoveryDailyTask.mentalSupport.index],
        isTrue,
      );
    });

    test('manual un-check stays false until auto-mark sets true again', () {
      var record = RecoveryDayRecord(dayIndex: 1);
      record = applyRecoveryDailyProgramAutoMark(
        record,
        RecoveryDailyProgramAutoMark.water,
      );
      expect(record.waterCompleted, isTrue);

      record = record.toggleWater(false);
      expect(record.waterCompleted, isFalse);

      record = applyRecoveryDailyProgramAutoMark(
        record,
        RecoveryDailyProgramAutoMark.water,
      );
      expect(record.waterCompleted, isTrue);
    });
  });
}
