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

    test('journal step does not map to recovery (worry entry handles mentalSupport)', () {
      expect(recoveryAutoMarkForDailyStep(DailyStep.journal), isNull);
    });
  });

  group('applyRecoveryEngagementAutoMark', () {
    test('sets mentalSupport from worry journal signal', () {
      final record = RecoveryDayRecord(dayIndex: 1);
      final next = applyRecoveryEngagementAutoMark(
        record,
        RecoveryEngagementAutoMark.mentalSupport,
      );
      expect(
        next.taskCompleted[RecoveryDailyTask.mentalSupport.index],
        isTrue,
      );
    });

    test('sets distractionManagement from pomodoro or focused thinking', () {
      final record = RecoveryDayRecord(dayIndex: 1);
      final next = applyRecoveryEngagementAutoMark(
        record,
        RecoveryEngagementAutoMark.distractionManagement,
      );
      expect(
        next.taskCompleted[RecoveryDailyTask.distractionManagement.index],
        isTrue,
      );
    });

    test('recoveryEngagementAutoMarkIsApplied detects existing flags', () {
      final marked = applyRecoveryEngagementAutoMark(
        RecoveryDayRecord(dayIndex: 1),
        RecoveryEngagementAutoMark.distractionManagement,
      );
      expect(
        recoveryEngagementAutoMarkIsApplied(
          marked,
          RecoveryEngagementAutoMark.distractionManagement,
        ),
        isTrue,
      );
      expect(
        recoveryEngagementAutoMarkIsApplied(
          RecoveryDayRecord(dayIndex: 1),
          RecoveryEngagementAutoMark.distractionManagement,
        ),
        isFalse,
      );
    });

    test('idempotent when mentalSupport already set by sukoon auto-mark', () {
      var record = applyRecoveryDailyProgramAutoMark(
        RecoveryDayRecord(dayIndex: 1),
        RecoveryDailyProgramAutoMark.mentalSupport,
      );
      expect(
        recoveryEngagementAutoMarkIsApplied(
          record,
          RecoveryEngagementAutoMark.mentalSupport,
        ),
        isTrue,
      );
      record = applyRecoveryEngagementAutoMark(
        record,
        RecoveryEngagementAutoMark.mentalSupport,
      );
      expect(
        record.taskCompleted[RecoveryDailyTask.mentalSupport.index],
        isTrue,
      );
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
