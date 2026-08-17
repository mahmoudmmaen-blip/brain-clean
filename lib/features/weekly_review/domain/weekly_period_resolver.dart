import '../../daily_session/domain/daily_day_key.dart';
import 'weekly_period.dart';

/// Resolves local ISO calendar weeks. Product convention — not clinical.
abstract final class WeeklyPeriodResolver {
  /// Materializes the ISO week containing [localNow].
  static WeeklyPeriod periodContaining({
    required DateTime localNow,
    required Duration timezoneOffset,
    DateTime? materializedAtUtc,
  }) {
    final date = DateTime(localNow.year, localNow.month, localNow.day);
    final monday = date.subtract(Duration(days: date.weekday - DateTime.monday));
    final sunday = monday.add(const Duration(days: 6));
    final iso = isoWeekOf(monday);
    return WeeklyPeriod(
      periodId: WeeklyPeriodId.format(iso.year, iso.week),
      startDayKey: DailyDayKey.fromLocal(monday),
      endDayKey: DailyDayKey.fromLocal(sunday),
      timezoneOffsetMinutes: timezoneOffset.inMinutes,
      materializedAt: (materializedAtUtc ?? DateTime.now()).toUtc(),
    );
  }

  /// Immediately previous local ISO week (never the current incomplete week).
  static WeeklyPeriod previousCompletedWeek({
    required DateTime localNow,
    required Duration timezoneOffset,
    DateTime? materializedAtUtc,
  }) {
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final currentMonday =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    final previousSunday = currentMonday.subtract(const Duration(days: 1));
    return periodContaining(
      localNow: previousSunday,
      timezoneOffset: timezoneOffset,
      materializedAtUtc: materializedAtUtc,
    );
  }

  static bool isCurrentWeek({
    required WeeklyPeriod period,
    required DateTime localNow,
    required Duration timezoneOffset,
  }) {
    final current = periodContaining(
      localNow: localNow,
      timezoneOffset: timezoneOffset,
    );
    return current.periodId == period.periodId;
  }

  /// ISO-8601 week-year and week number for a local calendar date.
  static ({int year, int week}) isoWeekOf(DateTime localDate) {
    final d = DateTime(localDate.year, localDate.month, localDate.day);
    final thursday = d.add(Duration(days: DateTime.thursday - d.weekday));
    final isoYear = thursday.year;
    final jan4 = DateTime(isoYear, 1, 4);
    final week1Monday =
        jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
    final monday = d.subtract(Duration(days: d.weekday - DateTime.monday));
    final week = monday.difference(week1Monday).inDays ~/ 7 + 1;
    return (year: isoYear, week: week);
  }
}
