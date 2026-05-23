/// Neuro-scientific bounds for diagnostic → BC_score normalization.
abstract final class BcScoreConstants {
  static const double positiveWeight = 1.5;
  static const double negativeWeight = 0.8;
  static const double minRaw = -29.0;
  static const double maxRaw = 26.8;
  static const double rawSpan = maxRaw - minRaw;

  static const int metricMin = 1;
  static const int metricMax = 10;
}
