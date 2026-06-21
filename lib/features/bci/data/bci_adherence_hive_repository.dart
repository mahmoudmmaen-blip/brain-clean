import 'package:flutter/foundation.dart';

import '../../recovery/data/recovery_protocol_hive_repository.dart';
import '../../recovery/data/recovery_protocol_storage.dart';
import '../domain/bci_adherence_calculator.dart';
import '../domain/bci_adherence_snapshot.dart';
import '../domain/repositories/bci_adherence_repository.dart';

/// قراءة سجلات [RecoveryDayRecord] من Hive Box `recovery_protocol_v1`
/// وحساب متوسط [RecoveryDayRecord.dailyBcsScore] لآخر 7 أيام.
class BciAdherenceHiveRepository implements BciAdherenceRepository {
  BciAdherenceHiveRepository({RecoveryProtocolStorage? storage})
      : _storage = storage ?? RecoveryProtocolHiveRepository();

  final RecoveryProtocolStorage _storage;

  @override
  Future<BciAdherenceSnapshot> fetchLastSevenDaysAdherence() async {
    try {
      final state = await _storage.load();
      if (state == null) return BciAdherenceSnapshot.empty;
      return BciAdherenceCalculator.fromProtocolState(state);
    } catch (error, stackTrace) {
      debugPrint(
        'BciAdherenceHiveRepository: fetchLastSevenDaysAdherence failed: '
        '$error',
      );
      debugPrint('$stackTrace');
      return BciAdherenceSnapshot.empty;
    }
  }
}

/// تخزين في الذاكرة للاختبارات — بدون I/O.
class BciAdherenceMemoryRepository implements BciAdherenceRepository {
  BciAdherenceMemoryRepository(this._storage);

  final RecoveryProtocolStorage _storage;

  @override
  Future<BciAdherenceSnapshot> fetchLastSevenDaysAdherence() async {
    final state = await _storage.load();
    if (state == null) return BciAdherenceSnapshot.empty;
    return BciAdherenceCalculator.fromProtocolState(state);
  }
}
