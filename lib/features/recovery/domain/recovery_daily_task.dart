/// Five official daily habits in Dr. Moneam's 30-day recovery protocol.
enum RecoveryDailyTask {
  regulatedSleep,
  antiInflammatoryNutrition,
  movementTwentyMinutes,
  distractionManagement,
  mentalSupport,
}

extension RecoveryDailyTaskIndex on RecoveryDailyTask {
  int get index => RecoveryDailyTask.values.indexOf(this);

  static RecoveryDailyTask fromIndex(int index) =>
      RecoveryDailyTask.values[index.clamp(0, RecoveryDailyTask.values.length - 1)];
}
