import 'xp_source.dart';
import 'xp_sync_state.dart';

/// Single append-only XP credit with HMAC signature.
class XpLedgerEntry {
  const XpLedgerEntry({
    required this.id,
    required this.source,
    required this.amount,
    required this.createdAtUtc,
    required this.deviceId,
    required this.signature,
    this.refId,
    this.syncState = XpSyncState.pendingVerify,
  });

  final String id;
  final XpSource source;
  final String? refId;
  final int amount;
  final DateTime createdAtUtc;
  final String deviceId;
  final String signature;
  final XpSyncState syncState;

  XpLedgerEntry copyWith({
    String? id,
    XpSource? source,
    String? refId,
    int? amount,
    DateTime? createdAtUtc,
    String? deviceId,
    String? signature,
    XpSyncState? syncState,
  }) {
    return XpLedgerEntry(
      id: id ?? this.id,
      source: source ?? this.source,
      refId: refId ?? this.refId,
      amount: amount ?? this.amount,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      deviceId: deviceId ?? this.deviceId,
      signature: signature ?? this.signature,
      syncState: syncState ?? this.syncState,
    );
  }
}

/// Hive [TypeAdapter] type id — must not collide with existing adapters.
abstract final class XpLedgerHiveTypeIds {
  static const xpLedgerEntry = 14;
}
