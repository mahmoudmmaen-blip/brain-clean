import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/security/secure_key_store.dart';
import '../domain/xp_ledger_entry.dart';
import '../domain/xp_rejected.dart';
import '../domain/xp_source.dart';
import '../domain/xp_sync_state.dart';
import 'xp_ledger_constants.dart';
import 'xp_ledger_signing.dart';

/// Append-only signed XP ledger backed by an encrypted Hive box.
class XpLedgerRepository {
  XpLedgerRepository({
    required Box<dynamic> ledgerBox,
    required Box<dynamic> metaBox,
  })  : _ledgerBox = ledgerBox,
        _metaBox = metaBox;

  final Box<dynamic> _ledgerBox;
  final Box<dynamic> _metaBox;

  List<XpLedgerEntry> allEntries() {
    final items = <XpLedgerEntry>[];
    for (final value in _ledgerBox.values) {
      if (value is XpLedgerEntry) items.add(value);
    }
    items.sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));
    return items;
  }

  Stream<List<XpLedgerEntry>> watch() async* {
    yield allEntries();
    await for (final _ in _ledgerBox.watch()) {
      yield allEntries();
    }
  }

  /// Recomputes XP from valid signatures only; tampered rows are excluded.
  Future<int> verifiedTotalXp() async {
    var total = 0;
    for (final entry in allEntries()) {
      if (entry.syncState == XpSyncState.rejected) continue;
      final valid = await XpLedgerSigning.verify(entry);
      if (!valid) {
        debugPrint(
          'XpLedgerRepository: tampered entry excluded id=${entry.id} '
          'source=${entry.source.name} amount=${entry.amount}',
        );
        continue;
      }
      total += entry.amount;
    }
    return total;
  }

  /// Appends a signed entry after local guards; throws [XpRejected] on failure.
  Future<XpLedgerEntry> append(
    XpSource source,
    int amount, {
    String? refId,
    DateTime? createdAtUtc,
  }) async {
    if (amount <= 0) {
      throw const XpRejected(XpRejectReason.invalidAmount);
    }

    final now = (createdAtUtc ?? DateTime.now()).toUtc();
    _assertClockNotRolledBack(now);
    _assertNotDuplicate(source, refId);
    _assertPlausible(source, amount, refId);
    await _assertWithinDailyCap(source, amount, now);

    final deviceId = await SecureKeyStore.getOrCreateDeviceId();
    final unsigned = XpLedgerEntry(
      id: const Uuid().v4(),
      source: source,
      refId: refId,
      amount: amount,
      createdAtUtc: now,
      deviceId: deviceId,
      signature: '',
    );
    final signature = await XpLedgerSigning.sign(unsigned);
    final entry = unsigned.copyWith(signature: signature);

    await _ledgerBox.put(entry.id, entry);
    await _updateHighWaterMark(now);
    return entry;
  }

  /// Entries awaiting server validation (signed, not yet synced).
  Future<List<XpLedgerEntry>> pendingVerifyEntries() async {
    final pending = <XpLedgerEntry>[];
    for (final entry in allEntries()) {
      if (entry.syncState != XpSyncState.pendingVerify) continue;
      if (!await XpLedgerSigning.verify(entry)) continue;
      pending.add(entry);
    }
    return pending;
  }

  /// Applies server verdicts from [verify-xp] to local ledger rows.
  Future<void> applyServerVerdicts(
    Iterable<({String id, bool accepted})> verdicts,
  ) async {
    for (final verdict in verdicts) {
      final raw = _ledgerBox.get(verdict.id);
      if (raw is! XpLedgerEntry) continue;
      final nextState = verdict.accepted
          ? XpSyncState.verified
          : XpSyncState.rejected;
      if (raw.syncState == nextState) continue;
      await _ledgerBox.put(verdict.id, raw.copyWith(syncState: nextState));
    }
  }

  Future<void> persistServerTotalXp(int total) async {
    await _metaBox.put(HiveMetaKeys.serverTotalXp, total);
    await _metaBox.put(
      HiveMetaKeys.serverTotalXpSyncedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  int? readCachedServerTotalXp() {
    final raw = _metaBox.get(HiveMetaKeys.serverTotalXp);
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return null;
  }

  void _assertClockNotRolledBack(DateTime createdAtUtc) {
    final raw = _metaBox.get(HiveMetaKeys.xpLedgerHighWaterMarkUtc) as String?;
    if (raw == null || raw.isEmpty) return;
    try {
      final mark = DateTime.parse(raw).toUtc();
      if (createdAtUtc.isBefore(mark)) {
        throw const XpRejected(XpRejectReason.clockRollback);
      }
    } catch (e) {
      if (e is XpRejected) rethrow;
      debugPrint('XpLedgerRepository: high-water mark parse failed: $e');
    }
  }

  void _assertNotDuplicate(XpSource source, String? refId) {
    if (refId == null || refId.isEmpty) return;
    for (final entry in allEntries()) {
      if (entry.source == source && entry.refId == refId) {
        throw const XpRejected(XpRejectReason.duplicateRef);
      }
    }
  }

  Future<void> _assertWithinDailyCap(
    XpSource source,
    int amount,
    DateTime createdAtUtc,
  ) async {
    final dayKey = XpLedgerConstants.utcDayKey(createdAtUtc);
    var todayTotal = 0;
    for (final entry in allEntries()) {
      if (entry.source != source) continue;
      if (XpLedgerConstants.utcDayKey(entry.createdAtUtc) != dayKey) continue;
      if (entry.syncState == XpSyncState.rejected) continue;
      if (!await XpLedgerSigning.verify(entry)) continue;
      todayTotal += entry.amount;
    }
    final cap = XpLedgerConstants.dailyCapFor(source);
    if (todayTotal + amount > cap) {
      throw const XpRejected(XpRejectReason.dailyCapExceeded);
    }
  }

  void _assertPlausible(XpSource source, int amount, String? refId) {
    final max = XpLedgerConstants.maxPlausibleForSource(source, refId: refId);
    if (amount > max) {
      throw XpRejected(
        XpRejectReason.implausibleAmount,
        'amount=$amount max=$max',
      );
    }
  }

  Future<void> _updateHighWaterMark(DateTime createdAtUtc) async {
    final raw = _metaBox.get(HiveMetaKeys.xpLedgerHighWaterMarkUtc) as String?;
    if (raw != null && raw.isNotEmpty) {
      try {
        final existing = DateTime.parse(raw).toUtc();
        if (!createdAtUtc.isAfter(existing)) return;
      } catch (_) {
        // Overwrite corrupt mark.
      }
    }
    await _metaBox.put(
      HiveMetaKeys.xpLedgerHighWaterMarkUtc,
      createdAtUtc.toIso8601String(),
    );
  }
}
