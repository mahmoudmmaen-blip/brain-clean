/// Five mandatory daily habits in the 30-day recovery grid.
enum RecoveryDailyTask {
  boredomSilence,
  delayedGratification,
  bodyActivation,
  digitalDiscipline,
  deepFocus,
}

extension RecoveryDailyTaskIndex on RecoveryDailyTask {
  int get index => RecoveryDailyTask.values.indexOf(this);

  static RecoveryDailyTask fromIndex(int index) =>
      RecoveryDailyTask.values[index.clamp(0, RecoveryDailyTask.values.length - 1)];
}
