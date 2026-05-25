import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../../diagnostic/domain/diagnostic_model.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_protocol_firestore.dart';
import '../domain/detox_protocol_state.dart';

/// Persists detox habit metrics using Firestore-compatible snake_case keys.
class DetoxProtocolRepository {
  DetoxProtocolRepository({SupabaseClient? client})
      : _clientOverride = client;

  static const table = 'detox_protocol';

  final SupabaseClient? _clientOverride;

  SupabaseClient? get _client {
    if (_clientOverride != null) return _clientOverride;
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      return null;
    }
    return SupabaseConfig.client;
  }

  /// Atomic upsert of habit metrics using pre-mapped snake_case [payload].
  Future<void> upsertSnakeCasePayload(Map<String, dynamic> payload) async {
    try {
      final client = _client;
      if (client == null) return;

      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      await client.from(table).upsert({
        'user_id': userId,
        ...payload,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      throw DetoxProtocolSyncException(
        'Could not save detox check-ins. Please try again.',
      );
    }
  }

  /// Upserts today's habit check-ins for the signed-in user.
  Future<void> upsert(DetoxProtocolState state) async {
    await upsertSnakeCasePayload(state.toFirestoreHabitPayload());
  }

  /// Loads the latest remote check-ins for the signed-in user.
  Future<DetoxProtocolState?> fetchLatest() async {
    try {
      final client = _client;
      if (client == null) return null;

      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final row = await client
          .from(table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) return null;

      return DetoxProtocolState.fromDailyCheckIn(
        current: const DetoxProtocolState(),
        checkIn: DailyCheckInInput(
          boredomBefriended:
              row[DiagnosticModelJsonKeys.boredomBefriendedSnake] as bool?,
          delayedGratificationCount: (row[
                      DiagnosticModelJsonKeys.delayedGratificationCountSnake]
                  as num?)
              ?.toInt(),
          bodyActivated:
              row[DiagnosticModelJsonKeys.bodyActivatedSnake] as bool?,
        ),
      ).copyWith(
        lastSyncedAt: DateTime.tryParse(row['updated_at'] as String? ?? ''),
      );
    } catch (e) {
      throw DetoxProtocolSyncException(
        'Could not load detox check-ins. Please try again.',
      );
    }
  }
}

class DetoxProtocolSyncException implements Exception {
  DetoxProtocolSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
