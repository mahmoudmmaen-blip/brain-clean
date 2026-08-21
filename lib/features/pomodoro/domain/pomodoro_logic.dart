/// Pomodoro timer phases.
enum PomodoroPhase {
  focus,
  shortBreak,
  longBreak,
}

/// Default focus durations offered on Home (minutes).
const int kPomodoroFocusMinutesShort = 25;
const int kPomodoroFocusMinutesLong = 50;
const int kPomodoroFocusMinutesMin = 5;
const int kPomodoroFocusMinutesMax = 120;
const int kPomodoroFocusMinutesStep = 5;

/// Clamps focus length to 5–120 in 5-minute steps.
int clampPomodoroFocusMinutes(int minutes) {
  final stepped =
      ((minutes / kPomodoroFocusMinutesStep).round()) * kPomodoroFocusMinutesStep;
  return stepped.clamp(kPomodoroFocusMinutesMin, kPomodoroFocusMinutesMax);
}

/// Duration in seconds for each phase.
///
/// [focusMinutes] overrides the default 25-minute focus block when provided.
int pomodoroPhaseDurationSeconds(
  PomodoroPhase phase, {
  int focusMinutes = kPomodoroFocusMinutesShort,
}) {
  switch (phase) {
    case PomodoroPhase.focus:
      return clampPomodoroFocusMinutes(focusMinutes) * 60;
    case PomodoroPhase.shortBreak:
      return 5 * 60;
    case PomodoroPhase.longBreak:
      return 15 * 60;
  }
}

/// BCS bonus granted when a focus phase completes.
double pomodoroFocusBonus(int completedRoundsAfterFocus) =>
    completedRoundsAfterFocus <= 4 ? 5.0 : 3.0;

/// BCS bonus when a long break completes.
const double pomodoroLongBreakBonus = 2.0;

/// Result of completing the current phase.
class PomodoroAdvanceResult {
  const PomodoroAdvanceResult({
    required this.nextPhase,
    required this.completedRounds,
    this.focusBonus,
    this.longBreakBonus,
  });

  final PomodoroPhase nextPhase;
  final int completedRounds;
  final double? focusBonus;
  final double? longBreakBonus;
}

/// Computes next phase and round count after [completedPhase] ends.
PomodoroAdvanceResult advancePomodoro({
  required PomodoroPhase completedPhase,
  required int completedRounds,
}) {
  switch (completedPhase) {
    case PomodoroPhase.focus:
      final rounds = completedRounds + 1;
      final next = rounds >= 4
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
      return PomodoroAdvanceResult(
        nextPhase: next,
        completedRounds: rounds,
        focusBonus: pomodoroFocusBonus(rounds),
      );
    case PomodoroPhase.shortBreak:
      return PomodoroAdvanceResult(
        nextPhase: PomodoroPhase.focus,
        completedRounds: completedRounds,
      );
    case PomodoroPhase.longBreak:
      return PomodoroAdvanceResult(
        nextPhase: PomodoroPhase.focus,
        completedRounds: 0,
        longBreakBonus: pomodoroLongBreakBonus,
      );
  }
}

/// Ring color hex for the active phase.
int pomodoroRingColor(PomodoroPhase phase) =>
    phase == PomodoroPhase.focus ? 0xFF1D9E75 : 0xFF3B82F6;
