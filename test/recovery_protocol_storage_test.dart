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

    test('assertCamelCaseOnly rejects forbidden snake_case drift keys', () {
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

    test('assertCamelCaseOnly rejects unexpected root keys', () {
      expect(
        () => RecoveryHivePayload.assertCamelCaseOnly({
          RecoveryProtocolJsonKeys.selectedDayIndex: 1,
          'unexpectedKey': true,
          RecoveryProtocolJsonKeys.days: <String, dynamic>{},
        }),
        throwsA(isA<RecoveryPersistenceException>()),
      );
    });

    test('tryParsePersisted migrates legacy snake_case without throwing', () {
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

      final result = RecoveryHivePayload.tryParsePersisted(legacy);

      expect(result.hasState, isTrue);
      expect(result.migratedFromLegacy, isTrue);
      expect(
        result.state!.toJson().containsKey('protocol_start_date'),
        isFalse,
      );
      expect(result.state!.selectedDayIndex, 2);
    });

    test('tryParsePersisted returns corrupt for non-map payloads', () {
      final result = RecoveryHivePayload.tryParsePersisted('invalid');
      expect(result.recoveredFromCorruption, isTrue);
      expect(result.hasState, isFalse);
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
      final loaded = await repo.loadResult();

      expect(loaded.hasState, isTrue);
      expect(loaded.state!.selectedDayIndex, 7);
      expect(loaded.state!.days[7]!.completedCount, 3);
      expect(loaded.state!.totalPenaltyCount, 1);
    });

    test('loadResult migrates legacy snake_case in box', () async {
      final repo = RecoveryProtocolHiveRepository(box: box);
      await box.put('protocol_state', {
        'protocol_start_date': '2026-04-01T00:00:00.000',
        'selected_day_index': 4,
        'total_penalty_count': 0,
        'days': <String, dynamic>{},
      });

      final loaded = await repo.loadResult();

      expect(loaded.hasState, isTrue);
      expect(loaded.migratedFromLegacy, isTrue);
      final stored = box.get('protocol_state');
      expect(stored, isA<Map>());
      expect(
        (stored as Map).containsKey(RecoveryProtocolJsonKeys.protocolStartDate),
        isTrue,
      );
    });

    test('loadResult clears corrupt payloads', () async {
      final repo = RecoveryProtocolHiveRepository(box: box);
      await box.put('protocol_state', 'not-a-map');

      final loaded = await repo.loadResult();

      expect(loaded.recoveredFromCorruption, isTrue);
      expect(box.get('protocol_state'), isNull);
      expect(await repo.load(), isNull);
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
