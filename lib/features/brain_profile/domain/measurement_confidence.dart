/// Confidence in the measurement snapshot — separate from any score value.
enum MeasurementConfidence {
  /// Few items or incomplete / corrupt path.
  provisional,

  /// Useful estimate with normal uncertainty (Lite/Pulse complete).
  moderate,

  /// Full path complete under recovery_score_v1 (user label: Strong).
  strong,
}

extension MeasurementConfidenceX on MeasurementConfidence {
  String get wireName => name;

  static MeasurementConfidence fromWire(String? raw) {
    switch (raw) {
      case 'strong':
      case 'solid': // legacy Slice 3 wire name
        return MeasurementConfidence.strong;
      case 'moderate':
        return MeasurementConfidence.moderate;
      case 'provisional':
      default:
        return MeasurementConfidence.provisional;
    }
  }
}
