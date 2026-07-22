import 'package:brain_clean_mobile/features/recovery/domain/recovery_daily_task.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const points = RecoveryProtocolConstants.pointsPerScoredHabit;

  group('RecoveryDayRecord.dailyBcsScore', () {
    test('empty day scores 0', () {
      final record = RecoveryDayRecord(dayIndex: 1);
      expect(record.dailyBcsScore, 0);
      expect(record.scoredCompletedCount, 0);
    });

    test('each scored habit contributes equal points (~16.67)', () {
      final record = RecoveryDayRecord(dayIndex: 1);
      expect(record.dailyBcsScore, closeTo(0, 0.001));

      final withMovement = record.toggleTask(
        RecoveryDailyTask.movementTwentyMinutes,
        true,
      );
      expect(withMovement.dailyBcsScore, closeTo(points, 0.001));

      final withSleep = withMovement.toggleSleep(true);
      expect(withSleep.dailyBcsScore, closeTo(points * 2, 0.001));
    });

    test('regulatedSleep task slot does not affect score', () {
      final onlyLegacySleep = RecoveryDayRecord(
        dayIndex: 1,
        taskCompleted: const [true, false, false, false, false],
      );
      expect(onlyLegacySleep.dailyBcsScore, 0);
      expect(onlyLegacySleep.scoredCompletedCount, 0);
    });

    test('sleepCompleted is the sole sleep signal for scoring', () {
      final record = RecoveryDayRecord(dayIndex: 1).toggleSleep(true);
      expect(record.dailyBcsScore, closeTo(points, 0.001));
    });

    test('all six scored habits sum to 100', () {
      final record = RecoveryDayRecord(
        dayIndex: 1,
        taskCompleted: const [false, true, true, true, true],
        sleepCompleted: true,
        waterCompleted: true,
      );
      expect(record.dailyBcsScore, closeTo(100, 0.001));
      expect(record.allTasksComplete, isTrue);
    });

    test('fromJson migrates legacy regulatedSleep into sleepCompleted', () {
      final record = RecoveryDayRecord.fromJson({
        'dayIndex': 3,
        'taskCompleted': [true, false, false, false, false],
        'penaltyApplied': false,
      });
      expect(record.sleepCompleted, isTrue);
      expect(record.dailyBcsScore, closeTo(points, 0.001));
    });
  });
}
