import '../data/day_progress.dart';
import 'program_engine.dart';

/// Cell state for the Progress 30-day program grid (§4.11).
enum ProgressCalendarCell { done, partial, missed, today, future }

abstract final class ProgressCalendar {
  ProgressCalendar._();

  /// Weekday index 0..6 where 0 is the first column of the grid.
  /// Arabic locales start on Saturday; others on Monday.
  static int weekStartWeekday({required bool arabicLocale}) {
    // DateTime.weekday: Mon=1 … Sun=7
    return arabicLocale ? DateTime.saturday : DateTime.monday;
  }

  static List<int> weekdayHeaders({required bool arabicLocale}) {
    final start = weekStartWeekday(arabicLocale: arabicLocale);
    return List.generate(7, (i) {
      var day = start + i;
      if (day > 7) day -= 7;
      return day;
    });
  }

  static ProgressCalendarCell cellState({
    required int day,
    required List<DayProgress> progress,
    required DateTime now,
  }) {
    DayProgress? existing;
    for (final p in progress) {
      if (p.day == day) {
        existing = p;
        break;
      }
    }

    if (existing != null && ProgramEngine.isDayCompleted(existing)) {
      return ProgressCalendarCell.done;
    }

    final unlocked = ProgramEngine.isDayUnlocked(
      day: day,
      now: now,
      progress: progress,
    );
    final current = ProgramEngine.currentDay(progress);

    if (day == current && unlocked) {
      if (existing != null &&
          (existing.startedAt != null ||
              existing.lessonDone ||
              existing.practiceDone ||
              existing.usedEasy)) {
        return ProgressCalendarCell.partial;
      }
      return ProgressCalendarCell.today;
    }

    if (day > current || !unlocked) {
      return ProgressCalendarCell.future;
    }

    // Behind current day and not completed.
    if (existing != null &&
        (existing.startedAt != null ||
            existing.lessonDone ||
            existing.practiceDone ||
            existing.usedEasy)) {
      return ProgressCalendarCell.partial;
    }
    return ProgressCalendarCell.missed;
  }
}
