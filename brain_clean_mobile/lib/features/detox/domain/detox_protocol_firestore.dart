import '../../diagnostic/domain/diagnostic_model.dart';
import 'detox_protocol_state.dart';

/// Firestore habit payload contract — snake_case keys only.
abstract final class DetoxFirestorePayload {
  DetoxFirestorePayload._();

  /// Canonical snake_case keys aligned with [DiagnosticModelJsonKeys].
  static const boredomBefriended = DiagnosticModelJsonKeys.boredomBefriendedSnake;
  static const delayedGratificationCount =
      DiagnosticModelJsonKeys.delayedGratificationCountSnake;
  static const bodyActivated = DiagnosticModelJsonKeys.bodyActivatedSnake;

  static const allowedHabitKeys = {
    boredomBefriended,
    delayedGratificationCount,
    bodyActivated,
  };

  /// Builds a Firestore-ready payload from a [DetoxHabitScorer]-scored state.
  ///
  /// Enforces [DiagnosticModelJsonKeys] snake_case keys exclusively —
  /// no camelCase aliases are emitted.
  static Map<String, dynamic> fromScoredState(DetoxProtocolState scored) {
    final payload = <String, dynamic>{
      boredomBefriended: scored.boredomBefriended,
      delayedGratificationCount: scored.delayedGratificationCount,
      bodyActivated: scored.bodyActivated,
    };
    assertSnakeCaseOnly(payload);
    return payload;
  }

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
}

/// Firestore serialization for detox habit metrics.
extension DetoxProtocolFirestore on DetoxProtocolState {
  /// Maps scored habit fields to [DetoxFirestorePayload] snake_case keys.
  Map<String, dynamic> toFirestoreHabitPayload() =>
      DetoxFirestorePayload.fromScoredState(this);
}
