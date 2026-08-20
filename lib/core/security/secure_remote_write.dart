import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import 'authenticated_session.dart';

/// JWT-gated remote writes for user_progress / focus_journey / related tables.
///
/// The Edge Function `write-user-state` re-verifies the JWT and ignores any
/// client-supplied `user_id`.
class SecureRemoteWrite {
  const SecureRemoteWrite({SupabaseClient? client}) : _clientOverride = client;

  static const functionName = 'write-user-state';

  final SupabaseClient? _clientOverride;

  SupabaseClient? get _client => _clientOverride ?? SupabaseConfig.clientOrNull;

  Future<bool> upsert({
    required String table,
    required Map<String, dynamic> row,
  }) async {
    final client = _client;
    final session = client?.auth.currentSession;
    if (client == null || !AuthenticatedSession.isUsable(session)) {
      return false;
    }

    final sanitized = Map<String, dynamic>.from(row)
      ..remove('user_id')
      ..remove('id');

    try {
      final response = await client.functions.invoke(
        functionName,
        body: {
          'table': table,
          'row': sanitized,
        },
      );
      if (response.status != 200) {
        debugPrint('SecureRemoteWrite: $table status ${response.status}');
        return false;
      }
      return true;
    } catch (error) {
      debugPrint('SecureRemoteWrite: $table failed');
      return false;
    }
  }
}
