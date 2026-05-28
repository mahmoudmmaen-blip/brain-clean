import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/recovery_hive_payload.dart';
import '../domain/recovery_protocol_load_result.dart';
import '../domain/recovery_protocol_state.dart';
import 'recovery_protocol_storage.dart';

/// Hive box adapter — never throws on [loadResult]; migrates legacy camelCase.
class RecoveryProtocolHiveRepository implements RecoveryProtocolStorage {
  RecoveryProtocolHiveRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const _stateKey = 'protocol_state';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.initialize();
    if (Hive.isBoxOpen(HiveBoxes.recoveryProtocol)) {
      return Hive.box<dynamic>(HiveBoxes.recoveryProtocol);
    }
    return Hive.openBox<dynamic>(HiveBoxes.recoveryProtocol);
  }

  @override
  Future<RecoveryProtocolLoadResult> loadResult() async {
    try {
      final box = await _openBox();
      final raw = box.get(_stateKey);
      final parsed = RecoveryHivePayload.tryParsePersisted(raw);

      if (parsed.recoveredFromCorruption) {
        await box.delete(_stateKey);
        debugPrint(
          'RecoveryProtocolHiveRepository: corrupt payload removed; '
          'starting fresh protocol.',
        );
        return const RecoveryProtocolLoadResult.corrupt();
      }

      if (!parsed.hasState) {
        return const RecoveryProtocolLoadResult.missing();
      }

      if (parsed.migratedFromLegacy) {
        try {
          await save(parsed.state!);
          debugPrint(
            'RecoveryProtocolHiveRepository: legacy payload migrated '
            'to camelCase.',
          );
        } catch (e) {
          debugPrint(
            'RecoveryProtocolHiveRepository: migration save failed: $e',
          );
        }
      }

      return parsed;
    } catch (e) {
      debugPrint('RecoveryProtocolHiveRepository: load failed: $e');
      return const RecoveryProtocolLoadResult.corrupt();
    }
  }

  @override
  Future<RecoveryProtocolState?> load() async {
    final result = await loadResult();
    return result.state;
  }

  @override
  Future<void> save(RecoveryProtocolState state) async {
    final box = await _openBox();
    final encoded = RecoveryHivePayload.encodeState(state);
    await box.put(_stateKey, encoded);
  }

  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_stateKey);
  }
}

/// In-memory storage for widget/unit tests (no Hive I/O).
class RecoveryProtocolMemoryRepository implements RecoveryProtocolStorage {
  RecoveryProtocolState? _cached;

  @override
  Future<RecoveryProtocolLoadResult> loadResult() async {
    if (_cached == null) return const RecoveryProtocolLoadResult.missing();
    return RecoveryProtocolLoadResult.success(_cached!);
  }

  @override
  Future<RecoveryProtocolState?> load() async => _cached;

  @override
  Future<void> save(RecoveryProtocolState state) async {
    _cached = RecoveryProtocolState.fromJson(state.toJson());
  }

  @override
  Future<void> clear() async {
    _cached = null;
  }
}
