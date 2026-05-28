import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/recovery_protocol_state.dart';
import 'recovery_protocol_storage.dart';

/// Hive box adapter for [RecoveryProtocolState] (Map JSON in a single box key).
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
    try {
      final box = await _openBox();
      final raw = box.get(_stateKey);
      if (raw == null) return null;
      if (raw is! Map) return null;
      return RecoveryProtocolState.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(RecoveryProtocolState state) async {
    try {
      final box = await _openBox();
      await box.put(_stateKey, state.toJson());
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      final box = await _openBox();
      await box.delete(_stateKey);
    } catch (_) {
      rethrow;
    }
  }
}

/// In-memory storage for widget/unit tests (no Hive I/O).
class RecoveryProtocolMemoryRepository implements RecoveryProtocolStorage {
  RecoveryProtocolState? _cached;

  @override
  Future<RecoveryProtocolState?> load() async => _cached;

  @override
  Future<void> save(RecoveryProtocolState state) async {
    _cached = state;
  }

  @override
  Future<void> clear() async {
    _cached = null;
  }
}
