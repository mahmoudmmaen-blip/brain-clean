/// Local calendar day key — locale-independent (`YYYY-MM-DD`).
abstract final class DailyDayKey {
  /// Builds a day key from a **local** wall-clock [DateTime].
  static String fromLocal(DateTime local) {
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Converts a UTC instant into a day key in [timeZoneOffset].
  static String fromUtc(
    DateTime utc, {
    required Duration timeZoneOffset,
  }) {
    final local = utc.toUtc().add(timeZoneOffset);
    return fromLocal(local);
  }
}

/// Testable clock for daily identity (does not change unrelated timing).
typedef SessionClock = DateTime Function();

DateTime systemSessionClock() => DateTime.now();
