/// Neuro-scientific bounds and BHI weights for BC_score calculation.
abstract final class BcScoreConstants {
  // Legacy 6-point engine (raw formula normalization)
  static const double positiveWeight = 1.5;
  static const double negativeWeight = 0.8;
  static const double minRaw = -29.0;
  static const double maxRaw = 26.8;
  static const double rawSpan = maxRaw - minRaw;

  static const int metricMin = 1;
  static const int metricMax = 10;

  // BHI pillar weights (DiagnosticModel)
  static const double brainPerformanceWeight = 0.35;
  static const double digitalDisciplineWeight = 0.30;
  static const double healthyHabitsWeight = 0.25;
  static const double consistencyWeight = 0.10;

  /// Minimum BC_score floor for behavioral gradient stability.
  static const double bhiScoreFloor = 26.8;
}
