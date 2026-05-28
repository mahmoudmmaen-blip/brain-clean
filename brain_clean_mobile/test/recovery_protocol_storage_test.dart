import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_daily_task.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('RecoveryProtocolState serialization', () {
    test('round-trips days, penalties, and start date', () {
      final original = RecoveryProtocolState(
        protocolStartDate: DateTime(2026, 1, 15),
        selectedDayIndex: 3,
        totalPenaltyCount: 2,
        days: {
          1: RecoveryDayRecord(
            dayIndex: 1,
            taskCompleted: [true, true, true, true, true],
          ),
          2: RecoveryDayRecord(
            dayIndex: 2,
            taskCompleted: const [true, false, false, false, false],
            penaltyApplied: true,
          ),
        },
      );

      final restored =
          RecoveryProtocolState.fromJson(original.toJson());

      expect(restored.selectedDayIndex, 3);
      expect(restored.totalPenaltyCount, 2);
      expect(restored.days[1]!.allTasksComplete, isTrue);
      expect(restored.days[2]!.penaltyApplied, isTrue);
      expect(restored.days[2]!.completedCount, 1);
    });

    test('toggleTask updates indexed habit', () {
      final record = RecoveryDayRecord(dayIndex: 5);
      final updated =
          record.toggleTask(RecoveryDailyTask.mentalSupport, true);
      expect(updated.taskCompleted[RecoveryDailyTask.mentalSupport.index],
          isTrue);
    });
  });

  group('RecoveryProtocolHiveRepository', () {
    late Directory tempDir;
    late Box<dynamic> box;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('recovery_hive_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<dynamic>(HiveBoxes.recoveryProtocol);
    });

    tearDown(() async {
      await box.close();
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('save and load persist full protocol state', () async {
      final repo = RecoveryProtocolHiveRepository(box: box);
      final state = RecoveryProtocolState(
        protocolStartDate: DateTime(2026, 5, 1),
        selectedDayIndex: 7,
        totalPenaltyCount: 1,
        days: {
          7: RecoveryDayRecord(
            dayIndex: 7,
            taskCompleted: [true, true, true, false, false],
          ),
        },
      );

      await repo.save(state);
      final loaded = await repo.load();

      expect(loaded, isNotNull);
      expect(loaded!.selectedDayIndex, 7);
      expect(loaded.days[7]!.completedCount, 3);
      expect(loaded.totalPenaltyCount, 1);
    });

    test('clear removes stored state', () async {
      final repo = RecoveryProtocolHiveRepository(box: box);
      await repo.save(
        RecoveryProtocolState(protocolStartDate: DateTime.now()),
      );
      await repo.clear();
      expect(await repo.load(), isNull);
    });
  });
}
