import '../../diagnostic/domain/diagnostic_model.dart';
import 'detox_protocol_state.dart';

/// Firestore serialization for detox habit metrics.
extension DetoxProtocolFirestore on DetoxProtocolState {
  /// Maps local habit fields to [DiagnosticModelJsonKeys] snake_case payload.
  ///
  /// Used by [DetoxProtocolController.processDailyCheckIn] before atomic upsert.
  Map<String, dynamic> toFirestoreHabitPayload() => {
        DiagnosticModelJsonKeys.boredomBefriendedSnake: boredomBefriended,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake:
            delayedGratificationCount,
        DiagnosticModelJsonKeys.bodyActivatedSnake: bodyActivated,
      };
}
