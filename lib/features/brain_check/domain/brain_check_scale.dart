/// Answer scale for a Brain Check item (Assessment Bible placeholder).
enum BrainCheckScale {
  /// 1–5 agreement scale.
  likert5,

  /// Binary yes/no (stored as 1 / 0).
  yesNo,

  /// 1–5 frequency scale.
  frequency,
}

extension BrainCheckScaleX on BrainCheckScale {
  int get minValue {
    switch (this) {
      case BrainCheckScale.likert5:
      case BrainCheckScale.frequency:
        return 1;
      case BrainCheckScale.yesNo:
        return 0;
    }
  }

  int get maxValue {
    switch (this) {
      case BrainCheckScale.likert5:
      case BrainCheckScale.frequency:
        return 5;
      case BrainCheckScale.yesNo:
        return 1;
    }
  }

  String get wireName => name;

  static BrainCheckScale fromWire(String? raw) {
    switch (raw) {
      case 'yesNo':
        return BrainCheckScale.yesNo;
      case 'frequency':
        return BrainCheckScale.frequency;
      case 'likert5':
      default:
        return BrainCheckScale.likert5;
    }
  }
}
