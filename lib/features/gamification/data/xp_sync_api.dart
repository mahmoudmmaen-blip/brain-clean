import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/xp_ledger_entry.dart';
import '../domain/xp_server_verdict.dart';

/// HTTP client for the [verify-xp] Supabase Edge Function.
///
/// The server does NOT verify client HMAC — it applies its own validation rules.
class XpSyncApi {
  const XpSyncApi({SupabaseClient? client}) : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  SupabaseClient? get _client {
    if (_clientOverride != null) return _clientOverride;
    try {
      if (SupabaseConfig.url.isEmpty) return null;
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  bool get hasAuthenticatedSession {
    final client = _client;
    return client != null && client.auth.currentSession != null;
  }

  Future<XpVerifyResponse?> verifyEntries(List<XpLedgerEntry> entries) async {
    final client = _client;
    if (client == null || client.auth.currentSession == null) return null;
    if (entries.isEmpty) {
      return const XpVerifyResponse(verdicts: [], serverTotalXp: 0);
    }

    try {
      final body = {
        'entries': entries.map(_entryPayload).toList(),
      };
      final response = await client.functions.invoke(
        'verify-xp',
        body: body,
      );

      if (response.status != 200) {
        debugPrint('XpSyncApi: verify-xp status ${response.status}');
        return null;
      }

      final data = response.data;
      if (data is! Map) return null;
      return XpVerifyResponse.fromJson(Map<String, dynamic>.from(data));
    } catch (error, stackTrace) {
      debugPrint('XpSyncApi.verifyEntries failed: $error');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Map<String, dynamic> _entryPayload(XpLedgerEntry entry) => {
        'id': entry.id,
        'source': entry.source.name,
        'refId': entry.refId,
        'amount': entry.amount,
        'createdAtUtc': entry.createdAtUtc.toUtc().toIso8601String(),
      };
}
