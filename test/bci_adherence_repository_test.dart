import 'package:brain_clean_mobile/features/bci/data/bci_adherence_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BciAdherenceHiveRepository', () {
    test('fetchLastSevenDaysAdherence reads from storage and averages BCS', () async {
      final storage = RecoveryProtocolMemoryRepository();
      await storage.save(
        RecoveryProtocolState(
          protocolStartDate: DateTime.now().subtract(const Duration(days: 2)),
          days: {
            1: RecoveryDayRecord(
              dayIndex: 1,
              taskCompleted: List<bool>.filled(5, true),
              sleepCompleted: true,
              waterCompleted: true,
            ),
            2: RecoveryDayRecord(
              dayIndex: 2,
              taskCompleted: const [true, true, true, false, false],
            ),
            3: RecoveryDayRecord(
              dayIndex: 3,
              taskCompleted: List<bool>.filled(5, true),
              sleepCompleted: true,
              waterCompleted: true,
            ),
          },
        ),
      );

      final repository = BciAdherenceMemoryRepository(storage);
      final snapshot = await repository.fetchLastSevenDaysAdherence();

      expect(snapshot.daysSampled, 3);
      expect(snapshot.records.length, 3);
      expect(snapshot.averageDailyBcsScore, closeTo(78.67, 0.01));
      expect(snapshot.adherenceScore, closeTo(78.67, 0.01));
    });

    test('returns empty snapshot when protocol state is missing', () async {
      final repository = BciAdherenceMemoryRepository(
        RecoveryProtocolMemoryRepository(),
      );

      final snapshot = await repository.fetchLastSevenDaysAdherence();

      expect(snapshot.daysSampled, 0);
      expect(snapshot.records, isEmpty);
      expect(snapshot.averageDailyBcsScore, 0);
    });
  });
}
