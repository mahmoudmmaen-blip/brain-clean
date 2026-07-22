import 'recovery_daily_task.dart';
import 'recovery_protocol_constants.dart';
import 'recovery_protocol_json_keys.dart';

/// Check-in state for one protocol day (1–30).
class RecoveryDayRecord {
  RecoveryDayRecord({
    required this.dayIndex,
    List<bool>? taskCompleted,
    this.penaltyApplied = false,
    this.sleepCompleted = false,
    this.waterCompleted = false,
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
  final bool sleepCompleted;
  final bool waterCompleted;

  /// Count of checked boxes in the legacy 5-slot [taskCompleted] list.
  int get completedCount => taskCompleted.where((t) => t).length;

  /// Count of habits that contribute to [dailyBcsScore] (6 equal components).
  int get scoredCompletedCount {
    var count = 0;
    for (final task in recoveryScoredDailyTasks) {
      if (taskCompleted[task.index]) count++;
    }
    if (sleepCompleted) count++;
    if (waterCompleted) count++;
    return count;
  }

  bool get allTasksComplete =>
      scoredCompletedCount == RecoveryProtocolConstants.scoredHabitCount;

  bool get hasMissedHabit =>
      scoredCompletedCount > 0 &&
      scoredCompletedCount < RecoveryProtocolConstants.scoredHabitCount;

  /// Daily adherence input for BCI — six equal, non-overlapping habits (≈16.67 each).
  double get dailyBcsScore {
    final points = RecoveryProtocolConstants.pointsPerScoredHabit;
    var total = 0.0;
    for (final task in recoveryScoredDailyTasks) {
      if (taskCompleted[task.index]) total += points;
    }
    if (sleepCompleted) total += points;
    if (waterCompleted) total += points;
    return total.clamp(0.0, 100.0);
  }

  RecoveryDayRecord copyWith({
    List<bool>? taskCompleted,
    bool? penaltyApplied,
    bool? sleepCompleted,
    bool? waterCompleted,
  }) {
    return RecoveryDayRecord(
      dayIndex: dayIndex,
      taskCompleted: taskCompleted ?? List<bool>.from(this.taskCompleted),
      penaltyApplied: penaltyApplied ?? this.penaltyApplied,
      sleepCompleted: sleepCompleted ?? this.sleepCompleted,
      waterCompleted: waterCompleted ?? this.waterCompleted,
    );
  }

  RecoveryDayRecord toggleTask(RecoveryDailyTask task, bool value) {
    final next = List<bool>.from(taskCompleted);
    next[task.index] = value;
    return copyWith(taskCompleted: next);
  }

  RecoveryDayRecord toggleSleep(bool value) => copyWith(sleepCompleted: value);
  RecoveryDayRecord toggleWater(bool value) => copyWith(waterCompleted: value);

  /// camelCase JSON for Hive persistence (write path).
  Map<String, dynamic> toJson() => {
        RecoveryProtocolJsonKeys.dayIndex: dayIndex,
        RecoveryProtocolJsonKeys.taskCompleted: List<bool>.from(taskCompleted),
        RecoveryProtocolJsonKeys.penaltyApplied: penaltyApplied,
        RecoveryProtocolJsonKeys.sleepCompleted: sleepCompleted,
        RecoveryProtocolJsonKeys.waterCompleted: waterCompleted,
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

    var sleepDone = json[RecoveryProtocolJsonKeys.sleepCompleted] == true;
    // Legacy: regulatedSleep task slot counted as sleep before sleepCompleted existed.
    if (!sleepDone &&
        tasks[RecoveryDailyTask.regulatedSleep.index]) {
      sleepDone = true;
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
      sleepCompleted: sleepDone,
      waterCompleted: json[RecoveryProtocolJsonKeys.waterCompleted] == true,
    );
  }
}
