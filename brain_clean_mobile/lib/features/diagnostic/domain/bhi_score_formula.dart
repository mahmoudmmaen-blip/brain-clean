import '../../../core/constants/bc_score_constants.dart';

/// Shared BC_score formula for frozen pillars (no model-layer imports).
abstract final class BhiScoreFormula {
  static double compute({
    required double brainPerformance,
    required double digitalDiscipline,
    required double healthyHabits,
    required double consistency,
  }) {
    final raw = (brainPerformance * BcScoreConstants.brainPerformanceWeight) +
        (digitalDiscipline * BcScoreConstants.digitalDisciplineWeight) +
        (healthyHabits * BcScoreConstants.healthyHabitsWeight) +
        (consistency * BcScoreConstants.consistencyWeight);

    if (raw < BcScoreConstants.bhiScoreFloor) {
      return BcScoreConstants.bhiScoreFloor;
    }
    return raw.clamp(0.0, 100.0);
  }
}
