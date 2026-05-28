import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/recovery_hive_payload.dart';
import '../domain/recovery_persistence_exception.dart';
import '../domain/recovery_protocol_state.dart';
import 'recovery_protocol_storage.dart';

/// Hive box adapter for [RecoveryProtocolState] with typed adapters + camelCase JSON.
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
  Future<RecoveryProtocolState?> load() async {
    final box = await _openBox();
    final raw = box.get(_stateKey);
    if (raw == null) return null;

    try {
      if (raw is RecoveryProtocolState) return raw;
      if (raw is Map) {
        return RecoveryHivePayload.decodeState(
          Map<String, dynamic>.from(raw),
        );
      }
      return null;
    } on RecoveryPersistenceException {
      rethrow;
    } catch (_) {
      return null;
    }
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
