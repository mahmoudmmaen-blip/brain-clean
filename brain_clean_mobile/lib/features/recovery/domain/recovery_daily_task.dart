/// Five official daily habits in Dr. Moneam's 30-day recovery protocol.
enum RecoveryDailyTask {
  regulatedSleep,
  antiInflammatoryNutrition,
  movementTwentyMinutes,
  distractionManagement,
  mentalSupport,
}

/// Tasks that contribute to [RecoveryDayRecord.dailyBcsScore].
/// [RecoveryDailyTask.regulatedSleep] is legacy Hive slot only — sleep uses [RecoveryDayRecord.sleepCompleted].
const List<RecoveryDailyTask> recoveryScoredDailyTasks = [
  RecoveryDailyTask.antiInflammatoryNutrition,
  RecoveryDailyTask.movementTwentyMinutes,
  RecoveryDailyTask.distractionManagement,
  RecoveryDailyTask.mentalSupport,
];

extension RecoveryDailyTaskIndex on RecoveryDailyTask {
  int get index => RecoveryDailyTask.values.indexOf(this);

  static RecoveryDailyTask fromIndex(int index) =>
      RecoveryDailyTask.values[index.clamp(0, RecoveryDailyTask.values.length - 1)];

  bool get countsTowardBcs => recoveryScoredDailyTasks.contains(this);
}
