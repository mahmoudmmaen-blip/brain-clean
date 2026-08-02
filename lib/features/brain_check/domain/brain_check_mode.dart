/// Brain Check assessment modes (CHK-01).
enum BrainCheckMode {
  /// Short onboarding path (default).
  lite,

  /// Full multi-section path with chapter micro-breaks.
  full,

  /// Short recheck / pulse path.
  pulse,
}

extension BrainCheckModeX on BrainCheckMode {
  String get wireName => name;

  static BrainCheckMode fromWire(String? raw) {
    switch (raw) {
      case 'full':
        return BrainCheckMode.full;
      case 'pulse':
        return BrainCheckMode.pulse;
      case 'lite':
      default:
        return BrainCheckMode.lite;
    }
  }
}
