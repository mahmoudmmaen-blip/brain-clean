import '../data/usage_day_total.dart';

/// Pure helpers for Progress / paywall usage summaries.
abstract final class UsageMath {
  UsageMath._();

  static String dayKey(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';

  static double? yesterdayHours(List<UsageDayTotal> days, DateTime now) {
    final key = dayKey(now.subtract(const Duration(days: 1)));
    for (final d in days) {
      if (d.date == key) return d.hours;
    }
    return null;
  }

  /// Average hours over the last [window] calendar days that exist in [days].
  static double? averageHours(
    List<UsageDayTotal> days, {
    required DateTime now,
    int window = 7,
  }) {
    if (days.isEmpty) return null;
    final byDate = {for (final d in days) d.date: d};
    var sum = 0;
    var count = 0;
    for (var i = 0; i < window; i++) {
      final key = dayKey(now.subtract(Duration(days: i)));
      final hit = byDate[key];
      if (hit != null) {
        sum += hit.minutes;
        count++;
      }
    }
    if (count == 0) return null;
    return sum / count / 60.0;
  }

  /// First-7-day average vs last-7-day average when ≥ [minDays] entries exist.
  static ({double from, double to})? firstVsLastWindow(
    List<UsageDayTotal> days, {
    int window = 7,
    int minDays = 3,
  }) {
    if (days.length < minDays) return null;
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.take(window).toList(growable: false);
    final last = sorted.length <= window
        ? sorted
        : sorted.sublist(sorted.length - window);
    if (first.isEmpty || last.isEmpty) return null;
    final from =
        first.fold<int>(0, (s, d) => s + d.minutes) / first.length / 60.0;
    final to =
        last.fold<int>(0, (s, d) => s + d.minutes) / last.length / 60.0;
    return (from: from, to: to);
  }
}

/// Ask gating (max 2 prompts per install).
enum UsageAskTrigger { progressOpen, sosWin }

abstract final class UsageAskGate {
  UsageAskGate._();

  static bool shouldShow({
    required UsageAskTrigger trigger,
    required int askCount,
    required bool ask1Declined,
    required bool hasAccess,
  }) {
    if (hasAccess || askCount >= 2) return false;
    return switch (trigger) {
      UsageAskTrigger.progressOpen => askCount == 0,
      UsageAskTrigger.sosWin => askCount == 1 && ask1Declined,
    };
  }
}
