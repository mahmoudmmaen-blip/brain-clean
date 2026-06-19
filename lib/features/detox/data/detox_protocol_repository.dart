import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../../diagnostic/domain/diagnostic_model.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_protocol_firestore.dart';
import '../domain/detox_protocol_state.dart';

/// Persists detox habit metrics using Firestore-compatible snake_case keys.
///
/// **Data Transformation Layer:** Ensures strict Firestore compliance by
/// converting local camelCase model fields to required snake_case database
/// keys. Every write passes through [_toFirestorePayload] before reaching
/// the backend.
class DetoxProtocolRepository {
  DetoxProtocolRepository({SupabaseClient? client})
      : _clientOverride = client;

  static const table = 'detox_protocol';

  static const _keyBoredomSnake = 'boredom_befriended';
  static const _keyDelayedSnake = 'delayed_gratification_count';
  static const _keyBodySnake = 'body_activated';

  final SupabaseClient? _clientOverride;

  SupabaseClient? get _client {
    if (_clientOverride != null) return _clientOverride;
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      return null;
    }
    return SupabaseConfig.client;
  }

  /// Maps a scored [DetoxProtocolState] to camelCase local data, then transforms.
  Map<String, dynamic> transformLocalMetricsToFirestorePayload(
    DetoxProtocolState state,
  ) =>
      _toFirestorePayload({
        DiagnosticModelJsonKeys.boredomBefriendedCamel: state.boredomBefriended,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel:
            state.delayedGratificationCount,
        DiagnosticModelJsonKeys.bodyActivatedCamel: state.bodyActivated,
      });

  /// Data Transformation Layer: Ensures strict Firestore compliance by converting
  /// local camelCase model fields to required snake_case database keys, preventing
  /// data corruption and ensuring synchronization integrity.
  ///
  /// Enforces conversion to exactly:
  /// `boredom_befriended`, `delayed_gratification_count`, `body_activated`.
  /// Snake_case values take precedence when both key formats are present.
  Map<String, dynamic> _toFirestorePayload(Map<String, dynamic> localData) {
    final boredom = _readBool(
      localData,
      snakeKey: _keyBoredomSnake,
      camelKey: DiagnosticModelJsonKeys.boredomBefriendedCamel,
    );
    final delayed = _readInt(
      localData,
      snakeKey: _keyDelayedSnake,
      camelKey: DiagnosticModelJsonKeys.delayedGratificationCountCamel,
    );
    final body = _readBool(
      localData,
      snakeKey: _keyBodySnake,
      camelKey: DiagnosticModelJsonKeys.bodyActivatedCamel,
    );

    final payload = <String, dynamic>{
      _keyBoredomSnake: boredom,
      _keyDelayedSnake: delayed,
      _keyBodySnake: body,
    };
    DetoxFirestorePayload.assertSnakeCaseOnly(payload);
    return payload;
  }

  /// Atomic upsert — [payload] is always transformed before Firestore write.
  Future<void> upsertSnakeCasePayload(Map<String, dynamic> payload) async {
    final firestorePayload = _toFirestorePayload(payload);

    try {
      final client = _client;
      if (client == null) return;

      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      await client.from(table).upsert({
        'user_id': userId,
        ...firestorePayload,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DetoxProtocolSyncException(
        'Could not save detox check-ins. Please try again.',
      );
    }
  }

  /// Upserts today's habit check-ins — transforms local camelCase to snake_case first.
  Future<void> upsert(DetoxProtocolState state) async {
    await upsertSnakeCasePayload({
      DiagnosticModelJsonKeys.boredomBefriendedCamel: state.boredomBefriended,
      DiagnosticModelJsonKeys.delayedGratificationCountCamel:
          state.delayedGratificationCount,
      DiagnosticModelJsonKeys.bodyActivatedCamel: state.bodyActivated,
    });
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

  bool _readBool(
    Map<String, dynamic> source, {
    required String snakeKey,
    required String camelKey,
  }) {
    if (source.containsKey(snakeKey)) return source[snakeKey] as bool;
    if (source.containsKey(camelKey)) return source[camelKey] as bool;
    return false;
  }

  int _readInt(
    Map<String, dynamic> source, {
    required String snakeKey,
    required String camelKey,
  }) {
    if (source.containsKey(snakeKey)) {
      return (source[snakeKey] as num).toInt();
    }
    if (source.containsKey(camelKey)) {
      return (source[camelKey] as num).toInt();
    }
    return 0;
  }
}

class DetoxProtocolSyncException implements Exception {
  DetoxProtocolSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
