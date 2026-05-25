import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../../diagnostic/domain/diagnostic_model.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_protocol_firestore.dart';
import '../domain/detox_protocol_state.dart';

/// Persists detox habit metrics using Firestore-compatible snake_case keys.
///
/// ## Transformation Layer
///
/// This repository is the **final gatekeeper** for all outgoing remote traffic.
/// Local habit metrics use Dart camelCase property names internally; every
/// write passes through [transformLocalMetricsToFirestorePayload], which
/// produces a `Map<String, dynamic>` with strictly:
///
/// - `boredom_befriended`
/// - `delayed_gratification_count`
/// - `body_activated`
///
/// Any camelCase keys encountered during mapping are converted to snake_case
/// before the payload reaches Firestore. [DetoxFirestorePayload.assertSnakeCaseOnly]
/// rejects invalid keys as a last line of defense.
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

  /// Transformation Layer — maps local [DetoxProtocolState] to Firestore snake_case.
  Map<String, dynamic> transformLocalMetricsToFirestorePayload(
    DetoxProtocolState state,
  ) =>
      DetoxFirestorePayload.transformToSnakeCase(state: state);

  /// Atomic upsert of habit metrics using validated snake_case [payload].
  Future<void> upsertSnakeCasePayload(Map<String, dynamic> payload) async {
    DetoxFirestorePayload.assertSnakeCaseOnly(payload);

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
      if (e is ArgumentError) rethrow;
      throw DetoxProtocolSyncException(
        'Could not save detox check-ins. Please try again.',
      );
    }
  }

  /// Upserts today's habit check-ins — transforms local state to snake_case first.
  Future<void> upsert(DetoxProtocolState state) async {
    final firestorePayload = transformLocalMetricsToFirestorePayload(state);
    await upsertSnakeCasePayload(firestorePayload);
  }

  /// Loads the latest remote check-ins for the signed-in user.
  ///
  /// Reads exclusively via [DiagnosticModelJsonKeys] snake_case fields so
  /// Firestore data overrides any stale local cache on hydration.
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
