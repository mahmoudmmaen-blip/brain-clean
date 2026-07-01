import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/security/secure_key_store.dart';
import '../domain/xp_ledger_entry.dart';

/// HMAC-SHA256 signing for the append-only XP ledger.
///
/// **Security framing (honest):** client-side HMAC is *tamper-evident*, not
/// tamper-proof. It reliably detects direct edits to local storage on
/// non-compromised devices. A rooted/jailbroken device could extract the key;
/// that residual risk is mitigated (not eliminated) by [RootDetector]. The
/// authoritative source of truth for shared/competitive XP will be a future
/// Supabase Edge Function — entries are stored with [XpSyncState.pendingVerify]
/// until then.
abstract final class XpLedgerSigning {
  XpLedgerSigning._();

  /// Deterministic payload — field order and formatting must stay stable.
  static String canonicalPayload(XpLedgerEntry entry) {
    return '${entry.id}|${entry.source.name}|${entry.refId ?? ''}|'
        '${entry.amount}|${entry.createdAtUtc.toUtc().toIso8601String()}|'
        '${entry.deviceId}';
  }

  static Future<String> sign(XpLedgerEntry entry) async {
    final key = await SecureKeyStore.getOrCreateXpSigningKey();
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(canonicalPayload(entry)));
    return base64Encode(digest.bytes);
  }

  static Future<bool> verify(XpLedgerEntry entry) async {
    if (entry.signature.isEmpty) return false;
    final expected = await sign(entry);
    return _constantTimeEquals(expected, entry.signature);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
