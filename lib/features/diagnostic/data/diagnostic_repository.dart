import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/security/secure_remote_write.dart';
import '../domain/bhi_pillar_json_keys.dart';
import '../domain/diagnostic_session.dart';

/// Persists committed diagnostic sessions (BHI + Brain Rot + questionnaire).
class DiagnosticRepository {
  DiagnosticRepository({
    SupabaseClient? client,
    SecureRemoteWrite? remoteWrite,
  })  : _clientOverride = client,
        _remoteWrite = remoteWrite;

  static const table = 'user_diagnostics';

  final SupabaseClient? _clientOverride;
  final SecureRemoteWrite? _remoteWrite;

  SupabaseClient? get _client => _clientOverride ?? SupabaseConfig.clientOrNull;

  SecureRemoteWrite get _writer =>
      _remoteWrite ?? SecureRemoteWrite(client: _client);

  /// Full snake_case payload derived from [DiagnosticSession.toRepositoryPayload].
  Map<String, dynamic> toSnakeCasePayload(DiagnosticSession session) =>
      session.toRepositoryPayload();

  /// Loads the newest committed diagnostic for the signed-in user.
  Future<DiagnosticSession?> fetchLatest() async {
    try {
      final client = _client;
      if (client == null) return null;

      final userId = client.authenticatedUserId;
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
      final ok = await _writer.upsert(
        table: table,
        row: {
          BhiPillarJsonKeys.sessionJsonSnake: session.toJson(),
          BhiPillarJsonKeys.bcScoreSnake: session.bcScore,
          BhiPillarJsonKeys.committedAtSnake:
              session.committedAt.toUtc().toIso8601String(),
        },
      );
      if (!ok) return;
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
