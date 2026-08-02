/// Confidence in the measurement snapshot — separate from any score value.
enum MeasurementConfidence {
  /// Few items or Lite path — provisional snapshot.
  provisional,

  /// Most required items answered on a fuller path.
  moderate,

  /// Full path with complete answers.
  solid,
}

extension MeasurementConfidenceX on MeasurementConfidence {
  String get wireName => name;

  static MeasurementConfidence fromWire(String? raw) {
    switch (raw) {
      case 'solid':
        return MeasurementConfidence.solid;
      case 'moderate':
        return MeasurementConfidence.moderate;
      case 'provisional':
      default:
        return MeasurementConfidence.provisional;
    }
  }
}
