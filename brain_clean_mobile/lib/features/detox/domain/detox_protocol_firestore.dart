import '../../diagnostic/domain/diagnostic_model.dart';
import 'detox_protocol_state.dart';

/// Firestore habit payload contract — snake_case keys only.
abstract final class DetoxFirestorePayload {
  DetoxFirestorePayload._();

  /// Literal snake_case keys required by Firestore / [DiagnosticModel].
  static const boredomBefriended = 'boredom_befriended';
  static const delayedGratificationCount = 'delayed_gratification_count';
  static const bodyActivated = 'body_activated';

  /// Canonical keys aligned with [DiagnosticModelJsonKeys].
  static const boredomBefriendedKey = DiagnosticModelJsonKeys.boredomBefriendedSnake;
  static const delayedGratificationCountKey =
      DiagnosticModelJsonKeys.delayedGratificationCountSnake;
  static const bodyActivatedKey = DiagnosticModelJsonKeys.bodyActivatedSnake;

  static const allowedHabitKeys = {
    boredomBefriended,
    delayedGratificationCount,
    bodyActivated,
  };

  /// Transformation Layer — maps local [DetoxProtocolState] fields (Dart
  /// camelCase property names) to a Firestore `Map<String, dynamic>` using
  /// strictly snake_case keys.
  ///
  /// Any camelCase key present in [metrics] is normalized to its snake_case
  /// equivalent during this phase.
  static Map<String, dynamic> transformToSnakeCase({
    required DetoxProtocolState state,
    Map<String, dynamic>? metrics,
  }) {
    final source = metrics ?? const <String, dynamic>{};

    final boredom = _readBool(
      source,
      snakeKey: boredomBefriended,
      camelKey: DiagnosticModelJsonKeys.boredomBefriendedCamel,
      fallback: state.boredomBefriended,
    );
    final delayed = _readInt(
      source,
      snakeKey: delayedGratificationCount,
      camelKey: DiagnosticModelJsonKeys.delayedGratificationCountCamel,
      fallback: state.delayedGratificationCount,
    );
    final body = _readBool(
      source,
      snakeKey: bodyActivated,
      camelKey: DiagnosticModelJsonKeys.bodyActivatedCamel,
      fallback: state.bodyActivated,
    );

    final payload = <String, dynamic>{
      boredomBefriended: boredom,
      delayedGratificationCount: delayed,
      bodyActivated: body,
    };
    assertSnakeCaseOnly(payload);
    return payload;
  }

  /// Builds a Firestore-ready payload from a [DetoxHabitScorer]-scored state.
  static Map<String, dynamic> fromScoredState(DetoxProtocolState scored) =>
      transformToSnakeCase(state: scored);

  /// Guards against accidental camelCase or unknown keys in remote writes.
  static void assertSnakeCaseOnly(Map<String, dynamic> payload) {
    for (final key in payload.keys) {
      if (!allowedHabitKeys.contains(key)) {
        throw ArgumentError(
          'Firestore payload must use snake_case habit keys only. Found: $key',
        );
      }
    }
  }

  static bool _readBool(
    Map<String, dynamic> source, {
    required String snakeKey,
    required String camelKey,
    required bool fallback,
  }) {
    if (source.containsKey(snakeKey)) return source[snakeKey] as bool;
    if (source.containsKey(camelKey)) return source[camelKey] as bool;
    return fallback;
  }

  static int _readInt(
    Map<String, dynamic> source, {
    required String snakeKey,
    required String camelKey,
    required int fallback,
  }) {
    if (source.containsKey(snakeKey)) {
      return (source[snakeKey] as num).toInt();
    }
    if (source.containsKey(camelKey)) {
      return (source[camelKey] as num).toInt();
    }
    return fallback;
  }
}

/// Firestore serialization for detox habit metrics.
extension DetoxProtocolFirestore on DetoxProtocolState {
  /// Maps scored habit fields to [DetoxFirestorePayload] snake_case keys.
  Map<String, dynamic> toFirestoreHabitPayload() =>
      DetoxFirestorePayload.fromScoredState(this);
}
