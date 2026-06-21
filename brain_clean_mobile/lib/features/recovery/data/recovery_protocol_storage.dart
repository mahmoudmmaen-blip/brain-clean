import '../domain/recovery_protocol_load_result.dart';
import '../domain/recovery_protocol_state.dart';

/// Local persistence contract for the 30-day recovery protocol.
abstract interface class RecoveryProtocolStorage {
  /// Non-throwing read — migrates legacy payloads when possible.
  Future<RecoveryProtocolLoadResult> loadResult();

  Future<RecoveryProtocolState?> load();

  Future<void> save(RecoveryProtocolState state);

  Future<void> clear();
}
