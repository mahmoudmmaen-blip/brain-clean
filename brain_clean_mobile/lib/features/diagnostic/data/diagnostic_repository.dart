import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/bhi_pillar_json_keys.dart';
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

  /// Loads the newest committed diagnostic for the signed-in user.
  Future<DiagnosticSession?> fetchLatest() async {
    try {
      final client = _client;
      if (client == null) return null;

      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final rows = await client
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(1);

      if (rows is! List || rows.isEmpty) return null;
      final row = rows.first;
      if (row is! Map<String, dynamic>) return null;

      final sessionJson = row[BhiPillarJsonKeys.sessionJsonSnake] ??
          row['session_json'];
      if (sessionJson is Map<String, dynamic>) {
        return DiagnosticSession.fromJson(sessionJson);
      }

      final frozenJson = row[BhiPillarJsonKeys.bhiFrozenSnapshotSnake];
      if (frozenJson is! Map<String, dynamic>) return null;

      final committedRaw = row[BhiPillarJsonKeys.committedAtSnake] as String?;
      if (committedRaw == null) return null;

      return DiagnosticSession.fromJson({
        BhiPillarJsonKeys.committedAt: committedRaw,
        BhiPillarJsonKeys.bhi: {
          BhiPillarJsonKeys.metrics: _metricsFromRow(row),
          BhiPillarJsonKeys.frozenPillars: frozenJson,
        },
        BhiPillarJsonKeys.recoveryPenaltyDeduction:
            (row[BhiPillarJsonKeys.recoveryPenaltyDeductionSnake] as num?)
                    ?.toDouble() ??
                0,
      });
    } catch (e) {
      debugPrint('DiagnosticRepository.fetchLatest: $e');
      return null;
    }
  }

  static Map<String, dynamic> _metricsFromRow(Map<String, dynamic> row) {
    return {
      BhiPillarJsonKeys.sleepQuality:
          row[BhiPillarJsonKeys.sleepQualitySnake] ?? 5,
      BhiPillarJsonKeys.sustainedAttention:
          row[BhiPillarJsonKeys.sustainedAttentionSnake] ?? 5,
      BhiPillarJsonKeys.fragmentation:
          row[BhiPillarJsonKeys.fragmentationSnake] ?? 5,
      BhiPillarJsonKeys.dopamineSeeking:
          row[BhiPillarJsonKeys.dopamineSeekingSnake] ?? 5,
      BhiPillarJsonKeys.taskSwitching:
          row[BhiPillarJsonKeys.taskSwitchingSnake] ?? 5,
      BhiPillarJsonKeys.burnout: row[BhiPillarJsonKeys.burnoutSnake] ?? 5,
    };
  }

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
