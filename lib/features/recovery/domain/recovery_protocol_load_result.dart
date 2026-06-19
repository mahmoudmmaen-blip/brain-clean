import 'recovery_protocol_state.dart';

/// Outcome of reading protocol data from Hive (never throws).
class RecoveryProtocolLoadResult {
  const RecoveryProtocolLoadResult._({
    this.state,
    this.migratedFromLegacy = false,
    this.recoveredFromCorruption = false,
  });

  const RecoveryProtocolLoadResult.missing() : this._();

  const RecoveryProtocolLoadResult.success(
    RecoveryProtocolState state, {
    bool migratedFromLegacy = false,
  }) : this._(
          state: state,
          migratedFromLegacy: migratedFromLegacy,
        );

  const RecoveryProtocolLoadResult.corrupt()
      : this._(recoveredFromCorruption: true);

  final RecoveryProtocolState? state;
  final bool migratedFromLegacy;
  final bool recoveredFromCorruption;

  bool get hasState => state != null;
}
