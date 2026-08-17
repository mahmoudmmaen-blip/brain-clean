import 'dart:io';

import 'package:brain_clean_mobile/features/gamification/data/adapters/xp_ledger_entry_adapter.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_ledger_entry.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_source.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_sync_state.dart';
import 'package:brain_clean_mobile/features/recovery/data/adapters/recovery_day_record_adapter.dart';
import 'package:brain_clean_mobile/features/recovery/data/adapters/recovery_protocol_state_adapter.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_daily_task.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Writes [value] through the registered adapters and reads it back from disk,
/// which is the only way to exercise [TypeAdapter.write] + [TypeAdapter.read].
Future<T> _roundTrip<T>(T value) async {
  var box = await Hive.openBox<dynamic>('adapter_round_trip');
  await box.put('value', value);
  await box.close();
  box = await Hive.openBox<dynamic>('adapter_round_trip');
  final restored = box.get('value') as T;
  await box.deleteFromDisk();
  return restored;
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('bc_adapters_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(XpLedgerEntryAdapter());
    Hive.registerAdapter(RecoveryDayRecordAdapter());
    Hive.registerAdapter(RecoveryProtocolStateAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('XpLedgerEntryAdapter', () {
    test('round-trips every field of a signed entry', () async {
      final entry = XpLedgerEntry(
        id: 'entry-1',
        source: XpSource.pomodoro,
        refId: 'pomodoro:2026-06-24',
        amount: 25,
        createdAtUtc: DateTime.utc(2026, 6, 24, 12, 30, 15),
        deviceId: 'device-abc',
        signature: 'sig-abc',
        syncState: XpSyncState.verified,
      );

      final restored = await _roundTrip(entry);

      expect(restored.id, entry.id);
      expect(restored.source, XpSource.pomodoro);
      expect(restored.refId, entry.refId);
      expect(restored.amount, 25);
      expect(restored.createdAtUtc, entry.createdAtUtc);
      expect(restored.deviceId, entry.deviceId);
      expect(restored.signature, entry.signature);
      expect(restored.syncState, XpSyncState.verified);
    });

    test('round-trips a null refId', () async {
      final entry = XpLedgerEntry(
        id: 'entry-2',
        source: XpSource.other,
        amount: 5,
        createdAtUtc: DateTime.utc(2026, 1, 1),
        deviceId: 'device-abc',
        signature: 'sig-def',
      );

      final restored = await _roundTrip(entry);

      expect(restored.refId, isNull);
      expect(restored.syncState, XpSyncState.pendingVerify);
    });

    test('normalizes a local timestamp to UTC on write', () async {
      final local = DateTime.utc(2026, 4, 5, 6, 7, 8).toLocal();
      final entry = XpLedgerEntry(
        id: 'entry-3',
        source: XpSource.game,
        amount: 3,
        createdAtUtc: local,
        deviceId: 'device-abc',
        signature: 'sig-ghi',
      );

      final restored = await _roundTrip(entry);

      expect(restored.createdAtUtc.isUtc, isTrue);
      expect(restored.createdAtUtc, local.toUtc());
    });
  });

  group('RecoveryDayRecordAdapter', () {
    test('round-trips day index, habit flags, and penalty', () async {
      final record = RecoveryDayRecord(dayIndex: 12, penaltyApplied: true)
          .toggleTask(RecoveryDailyTask.regulatedSleep, true)
          .toggleTask(RecoveryDailyTask.mentalSupport, true);

      final restored = await _roundTrip(record);

      expect(restored.dayIndex, 12);
      expect(restored.taskCompleted, record.taskCompleted);
      expect(restored.completedCount, 2);
      expect(restored.penaltyApplied, isTrue);
    });
  });

  group('RecoveryProtocolStateAdapter', () {
    test('round-trips the camelCase protocol envelope', () async {
      final state = RecoveryProtocolState(
        protocolStartDate: DateTime.utc(2026, 2, 1),
        selectedDayIndex: 4,
        totalPenaltyCount: 2,
        days: {
          4: RecoveryDayRecord(dayIndex: 4)
              .toggleTask(RecoveryDailyTask.movementTwentyMinutes, true),
        },
      );

      final restored = await _roundTrip(state);

      expect(restored.protocolStartDate, DateTime.utc(2026, 2, 1));
      expect(restored.selectedDayIndex, 4);
      expect(restored.totalPenaltyCount, 2);
      expect(restored.days.keys, [4]);
      expect(
        restored.days[4]!.taskCompleted,
        state.days[4]!.taskCompleted,
      );
    });
  });
}
