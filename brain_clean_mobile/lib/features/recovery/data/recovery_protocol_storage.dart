import '../domain/recovery_protocol_state.dart';

/// Local persistence contract for the 30-day recovery protocol.
abstract interface class RecoveryProtocolStorage {
  Future<RecoveryProtocolState?> load();

  Future<void> save(RecoveryProtocolState state);

  Future<void> clear();
}
