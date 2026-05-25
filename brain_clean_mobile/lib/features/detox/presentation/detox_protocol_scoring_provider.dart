import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/detox_protocol_scoring.dart';
import 'detox_protocol_controller.dart';

part 'detox_protocol_scoring_provider.g.dart';

/// Live detox habit score (0–100) — recomputes when check-ins change.
@riverpod
double detoxHabitScore(DetoxHabitScoreRef ref) {
  return ref.watch(detoxProtocolDataProvider).detoxHabitScore;
}

/// Sub-component score breakdown for the 7-Day Dopamine Detox card.
@riverpod
DetoxHabitSubScores detoxHabitSubScores(DetoxHabitSubScoresRef ref) {
  return ref.watch(detoxProtocolDataProvider).subScores;
}
