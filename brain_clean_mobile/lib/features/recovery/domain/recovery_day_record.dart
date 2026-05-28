import 'recovery_daily_task.dart';
import 'recovery_protocol_constants.dart';

/// Check-in state for one protocol day (1–30).
class RecoveryDayRecord {
  const RecoveryDayRecord({
    required this.dayIndex,
    this.taskCompleted = const [false, false, false, false, false],
    this.penaltyApplied = false,
  }) : assert(taskCompleted.length == RecoveryProtocolConstants.mandatoryTaskCount);

  /// 1-based day number in the 30-day grid.
  final int dayIndex;
  final List<bool> taskCompleted;
  final bool penaltyApplied;

  int get completedCount => taskCompleted.where((t) => t).length;

  bool get allTasksComplete =>
      completedCount == RecoveryProtocolConstants.mandatoryTaskCount;

  bool get hasMissedHabit =>
      completedCount > 0 &&
      completedCount < RecoveryProtocolConstants.mandatoryTaskCount;

  RecoveryDayRecord copyWith({
    List<bool>? taskCompleted,
    bool? penaltyApplied,
  }) {
    return RecoveryDayRecord(
      dayIndex: dayIndex,
      taskCompleted: taskCompleted ?? List<bool>.from(this.taskCompleted),
      penaltyApplied: penaltyApplied ?? this.penaltyApplied,
    );
  }

  RecoveryDayRecord toggleTask(RecoveryDailyTask task, bool value) {
    final next = List<bool>.from(taskCompleted);
    next[task.index] = value;
    return copyWith(taskCompleted: next);
  }
}
