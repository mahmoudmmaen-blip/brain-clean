import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/diagnostic_session.dart';

/// Persists committed diagnostic sessions (BHI + Brain Rot + questionnaire).
class DiagnosticRepository {
  DiagnosticRepository({SupabaseClient? client}) : _clientOverride = client;

  static const table = 'user_diagnostics';

  final SupabaseClient? _clientOverride;

  SupabaseClient? get _client {
    if (_clientOverride != null) return _clientOverride;
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      return null;
    }
    return SupabaseConfig.client;
  }

  /// Full snake_case payload derived from [DiagnosticSession.toRepositoryPayload].
  Map<String, dynamic> toSnakeCasePayload(DiagnosticSession session) =>
      session.toRepositoryPayload();

  Future<void> upsertSession({required DiagnosticSession session}) async {
    session.ensurePillarBoundCoherence();
    try {
      final client = _client;
      if (client == null) return;

      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      await client.from(table).upsert({
        'user_id': userId,
        ...toSnakeCasePayload(session),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      throw DiagnosticSyncException(
        'Could not save your diagnostic. Please try again.',
      );
    }
  }
}

class DiagnosticSyncException implements Exception {
  DiagnosticSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
