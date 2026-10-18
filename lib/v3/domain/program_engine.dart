import '../data/day_progress.dart';

/// Program progression rules from spec §5.4.
abstract final class ProgramEngine {
  ProgramEngine._();

  static const int programLength = 30;
  static const int freeDays = 7;

  static bool isDayCompleted(DayProgress progress) {
    return progress.lessonDone &&
        (progress.practiceDone || progress.usedEasy) &&
        progress.completedAt != null;
  }

  static int completedDayCount(List<DayProgress> progress) {
    return progress.where(isDayCompleted).length;
  }

  /// Completed days + 1, capped at 30.
  static int currentDay(List<DayProgress> progress) {
    final completed = completedDayCount(progress);
    if (completed >= programLength) return programLength;
    return completed + 1;
  }

  static bool isProgramFinished(List<DayProgress> progress) {
    return completedDayCount(progress) >= programLength;
  }

  static DateTime startOfLocalDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime unlockInstantForNextDay(DateTime previousDayCompletedAt) {
    return startOfLocalDay(previousDayCompletedAt)
        .add(const Duration(days: 1));
  }

  /// Next calendar day unlocks at local midnight after the previous day completes.
  static bool isDayUnlocked({
    required int day,
    required DateTime now,
    required List<DayProgress> progress,
  }) {
    if (day < 1 || day > programLength) return false;

    final completedDays = progress.where(isDayCompleted).toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    for (final p in completedDays) {
      if (p.day == day) return true;
    }

    final completedCount = completedDays.length;
    if (day == 1 && completedCount == 0) return true;
    if (day > completedCount + 1) return false;
    if (day < completedCount + 1) return true;

    final previous = completedDays.firstWhere((p) => p.day == day - 1);
    final completedAt = previous.completedAt;
    if (completedAt == null) return false;
    final unlockAt = unlockInstantForNextDay(completedAt);
    return !now.isBefore(unlockAt);
  }

  static bool isProLocked({required int day, required bool isPro}) {
    return day >= freeDays + 1 && !isPro;
  }

  /// SOS is always free — never Pro-gated.
  static bool isSosLocked({required bool isPro}) => false;

  /// First scheduled check (e.g. 1, 7, 14…) without a saved result yet.
  static int? nextClarityCheckDay({
    required List<int> schedule,
    required Set<int> clarityTakenOnProgramDays,
  }) {
    for (final day in schedule) {
      if (!clarityTakenOnProgramDays.contains(day)) return day;
    }
    return null;
  }

  /// Calendar days with a completed program day, walking backward from [now].
  static int currentStreak({
    required List<DayProgress> progress,
    required DateTime now,
  }) {
    final completionDays = _completionCalendarDays(progress);
    if (completionDays.isEmpty) return 0;
    return _streakEndingOn(
      completionDays: completionDays,
      end: startOfLocalDay(now),
    );
  }

  /// Longest streak found across the user's completion history.
  static int bestStreak({
    required List<DayProgress> progress,
  }) {
    final completionDays = _completionCalendarDays(progress);
    if (completionDays.isEmpty) return 0;

    final sorted = completionDays.toList()..sort();
    var best = 0;
    for (final day in sorted) {
      final streak = _streakEndingOn(
        completionDays: completionDays,
        end: day,
      );
      if (streak > best) best = streak;
    }
    return best;
  }

  static Set<DateTime> _completionCalendarDays(List<DayProgress> progress) {
    final completionDays = <DateTime>{};
    for (final p in progress) {
      if (!isDayCompleted(p)) continue;
      final at = p.completedAt;
      if (at == null) continue;
      completionDays.add(startOfLocalDay(at));
    }
    return completionDays;
  }

  static int _streakEndingOn({
    required Set<DateTime> completionDays,
    required DateTime end,
  }) {
    var cursor = startOfLocalDay(end);
    if (!completionDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (!completionDays.contains(cursor)) return 0;

    var streak = 0;
    var restDaysUsedInWindow = 0;
    var daysWalkedInWindow = 0;

    while (true) {
      if (completionDays.contains(cursor)) {
        streak++;
      } else {
        if (restDaysUsedInWindow >= 1) break;
        restDaysUsedInWindow++;
      }

      daysWalkedInWindow++;
      if (daysWalkedInWindow >= 7) {
        restDaysUsedInWindow = 0;
        daysWalkedInWindow = 0;
      }

      cursor = cursor.subtract(const Duration(days: 1));
      if (cursor.year < 2000) break;
    }

    return streak;
  }
}
