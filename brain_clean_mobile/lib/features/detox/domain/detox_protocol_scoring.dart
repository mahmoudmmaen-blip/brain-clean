import 'detox_habit_scorer.dart';
import 'detox_protocol_state.dart';

/// Detox habit sub-component breakdown derived from [DetoxProtocolState].
extension DetoxProtocolScoring on DetoxProtocolState {
  /// Per sub-component scores for breakdown UI.
  DetoxHabitSubScores get subScores => DetoxHabitSubScores(
        boredomSilence: DetoxHabitScorer.boredomSilenceSubScore(boredomBefriended),
        delayedGratification: DetoxHabitScorer.delayedGratificationSubScore(
          delayedGratificationCount,
        ),
        bodyActivation: DetoxHabitScorer.bodyActivationSubScore(bodyActivated),
      );
}

/// Snapshot of the three detox habit sub-component scores (each 0–100).
class DetoxHabitSubScores {
  const DetoxHabitSubScores({
    required this.boredomSilence,
    required this.delayedGratification,
    required this.bodyActivation,
  });

  final double boredomSilence;
  final double delayedGratification;
  final double bodyActivation;
}
