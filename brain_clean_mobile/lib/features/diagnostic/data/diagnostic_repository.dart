import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';

/// Persists committed diagnostic sessions (BHI + Brain Rot band).
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

  /// Snake_case payload for Supabase — safe to call without auth (no-op).
  Map<String, dynamic> toSnakeCasePayload({
    required DiagnosticSession session,
    required DiagnosticMetrics metrics,
  }) {
    final model = session.model;
    final band = session.brainRotBand;
    return {
      'brain_rot_score': session.brainRotScore,
      'interpretation_band': band?.name,
      'brain_performance': model.brainPerformance,
      'digital_discipline': model.digitalDiscipline,
      'healthy_habits': model.healthyHabits,
      'consistency': model.consistency,
      'bc_score': session.bcScore,
      'sleep_quality': metrics.sleepQuality,
      'sustained_attention': metrics.sustainedAttention,
      'fragmentation': metrics.fragmentation,
      'dopamine_seeking': metrics.dopamineSeeking,
      'task_switching': metrics.taskSwitching,
      'burnout': metrics.burnout,
      'committed_at': session.committedAt.toUtc().toIso8601String(),
    };
  }

  Future<void> upsertSession({
    required DiagnosticSession session,
    required DiagnosticMetrics metrics,
  }) async {
    try {
      final client = _client;
      if (client == null) return;

      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      await client.from(table).upsert({
        'user_id': userId,
        ...toSnakeCasePayload(session: session, metrics: metrics),
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
