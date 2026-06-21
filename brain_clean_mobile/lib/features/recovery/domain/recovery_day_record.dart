import 'recovery_daily_task.dart';
import 'recovery_protocol_constants.dart';
import 'recovery_protocol_json_keys.dart';

/// Check-in state for one protocol day (1–30).
class RecoveryDayRecord {
  RecoveryDayRecord({
    required this.dayIndex,
    List<bool>? taskCompleted,
    this.penaltyApplied = false,
  }) : taskCompleted = taskCompleted ??
            List<bool>.filled(
              RecoveryProtocolConstants.mandatoryTaskCount,
              false,
            ) {
    assert(
      this.taskCompleted.length ==
          RecoveryProtocolConstants.mandatoryTaskCount,
    );
  }

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

  /// camelCase JSON for Hive persistence (write path).
  Map<String, dynamic> toJson() => {
        RecoveryProtocolJsonKeys.dayIndex: dayIndex,
        RecoveryProtocolJsonKeys.taskCompleted: List<bool>.from(taskCompleted),
        RecoveryProtocolJsonKeys.penaltyApplied: penaltyApplied,
      };

  /// camelCase JSON after [RecoveryHivePayload] normalization (read path).
  factory RecoveryDayRecord.fromJson(Map<String, dynamic> json) {
    final rawTasks = json[RecoveryProtocolJsonKeys.taskCompleted];
    final tasks = List<bool>.filled(
      RecoveryProtocolConstants.mandatoryTaskCount,
      false,
    );
    if (rawTasks is List) {
      for (var i = 0; i < RecoveryProtocolConstants.mandatoryTaskCount; i++) {
        if (i < rawTasks.length) {
          tasks[i] = rawTasks[i] == true;
        }
      }
    }

    final index = json[RecoveryProtocolJsonKeys.dayIndex];
    return RecoveryDayRecord(
      dayIndex: index is int
          ? index.clamp(1, RecoveryProtocolConstants.dayCount)
          : (index is num ? index.round() : 1).clamp(
              1,
              RecoveryProtocolConstants.dayCount,
            ),
      taskCompleted: tasks,
      penaltyApplied:
          json[RecoveryProtocolJsonKeys.penaltyApplied] == true,
    );
  }

}
