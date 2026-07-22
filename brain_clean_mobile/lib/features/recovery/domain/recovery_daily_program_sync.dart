import '../../daily_program/domain/daily_step.dart';
import 'recovery_daily_task.dart';
import 'recovery_day_record.dart';

/// Recovery flags that can be auto-set from Daily Program completion.
enum RecoveryDailyProgramAutoMark {
  water,
  movement,
  mentalSupport,
}

/// Maps a completed Daily Program step to a recovery auto-mark, if any.
///
/// Sleep and nutrition have no Daily Program signal — returns null for those.
RecoveryDailyProgramAutoMark? recoveryAutoMarkForDailyStep(DailyStep step) {
  return switch (step) {
    DailyStep.water => RecoveryDailyProgramAutoMark.water,
    DailyStep.movement => RecoveryDailyProgramAutoMark.movement,
    DailyStep.sukoon => RecoveryDailyProgramAutoMark.mentalSupport,
    _ => null,
  };
}

/// Applies an auto-mark as `true` only (never forces a false → true on rebuild).
///
/// Manual un-check stays respected until Daily Program completes that step again.
RecoveryDayRecord applyRecoveryDailyProgramAutoMark(
  RecoveryDayRecord record,
  RecoveryDailyProgramAutoMark mark,
) {
  return switch (mark) {
    RecoveryDailyProgramAutoMark.water =>
      record.toggleWater(true),
    RecoveryDailyProgramAutoMark.movement => record.toggleTask(
        RecoveryDailyTask.movementTwentyMinutes,
        true,
      ),
    RecoveryDailyProgramAutoMark.mentalSupport => record.toggleTask(
        RecoveryDailyTask.mentalSupport,
        true,
      ),
  };
}
