/// Selected path for the daily session.
enum DailySessionPath {
  minimum,
  standard,
}

extension DailySessionPathX on DailySessionPath {
  String get wireName => name;

  static DailySessionPath fromWire(String? raw) {
    switch (raw) {
      case 'minimum':
        return DailySessionPath.minimum;
      case 'standard':
      default:
        return DailySessionPath.standard;
    }
  }
}
