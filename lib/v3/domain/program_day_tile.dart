import '../data/day_progress.dart';
import 'program_engine.dart';

/// Visual / interaction state for a Program-tab day tile (§4.9).
enum ProgramDayTileState { done, today, future, proLocked }

abstract final class ProgramDayTile {
  ProgramDayTile._();

  static DayProgress? _progressFor(List<DayProgress> progress, int day) {
    for (final p in progress) {
      if (p.day == day) return p;
    }
    return null;
  }

  static ProgramDayTileState state({
    required int day,
    required List<DayProgress> progress,
    required DateTime now,
    required bool isPro,
  }) {
    final existing = _progressFor(progress, day);
    if (existing != null && ProgramEngine.isDayCompleted(existing)) {
      return ProgramDayTileState.done;
    }
    if (ProgramEngine.isProLocked(day: day, isPro: isPro)) {
      return ProgramDayTileState.proLocked;
    }
    final unlocked = ProgramEngine.isDayUnlocked(
      day: day,
      now: now,
      progress: progress,
    );
    final current = ProgramEngine.currentDay(progress);
    if (day == current && unlocked) {
      return ProgramDayTileState.today;
    }
    return ProgramDayTileState.future;
  }
}
