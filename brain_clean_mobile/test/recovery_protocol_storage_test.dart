import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_daily_task.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_hive_payload.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_persistence_exception.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_json_keys.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('RecoveryProtocolState serialization', () {
    test('round-trips days, penalties, and start date with camelCase keys', () {
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

      final json = original.toJson();
      expect(
        json.containsKey(RecoveryProtocolJsonKeys.protocolStartDate),
        isTrue,
      );
      expect(json.containsKey('protocol_start_date'), isFalse);

      final restored = RecoveryProtocolState.fromJson(json);

      expect(restored.selectedDayIndex, 3);
      expect(restored.totalPenaltyCount, 2);
      expect(restored.days[1]!.allTasksComplete, isTrue);
      expect(restored.days[2]!.penaltyApplied, isTrue);
      expect(restored.days[2]!.completedCount, 1);
    });

    test('rejects forbidden snake_case drift keys', () {
      expect(
        () => RecoveryHivePayload.assertCamelCaseOnly({
          'protocol_start_date': DateTime.now().toIso8601String(),
          'selected_day_index': 1,
          'total_penalty_count': 0,
          'days': <String, dynamic>{},
        }),
        throwsA(isA<RecoveryPersistenceException>()),
      );
    });

    test('normalizes legacy snake_case then encodes strict camelCase', () {
      final legacy = {
        'protocol_start_date': '2026-03-01T00:00:00.000',
        'selected_day_index': 2,
        'total_penalty_count': 1,
        'days': {
          '2': {
            'day_index': 2,
            'task_completed': [true, false, false, false, false],
            'penalty_applied': false,
          },
        },
      };

      final state = RecoveryHivePayload.decodeState(legacy);
      final encoded = state.toJson();

      expect(encoded.containsKey('protocol_start_date'), isFalse);
      expect(
        encoded[RecoveryProtocolJsonKeys.selectedDayIndex],
        2,
      );
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
      HiveBootstrap.registerRecoveryAdaptersForTests();
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
