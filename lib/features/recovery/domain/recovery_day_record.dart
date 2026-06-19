import 'recovery_daily_task.dart';
import 'recovery_protocol_constants.dart';
import 'recovery_protocol_json_keys.dart';

/// Check-in state for one protocol day (1–30).
class RecoveryDayRecord {
  RecoveryDayRecord({
    required this.dayIndex,
    List<bool>? taskCompleted,
    this.penaltyApplied = false,
    this.sleepCompleted = false, // 🌟 [NEW] متغير النوم
    this.waterCompleted = false, // 🌟 [NEW] متغير الماء
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

  // 🌟 [NEW] خصائص الميزات الجديدة
  final bool sleepCompleted;
  final bool waterCompleted;

  int get completedCount => taskCompleted.where((t) => t).length;

  // تم تحديثها لتشمل اكتمال المهام والنوم والماء معاً
  bool get allTasksComplete =>
      completedCount == RecoveryProtocolConstants.mandatoryTaskCount &&
      sleepCompleted &&
      waterCompleted;

  bool get hasMissedHabit =>
      completedCount > 0 &&
      completedCount < RecoveryProtocolConstants.mandatoryTaskCount;

  // ---------------------------------------------------------------------------
  // 🌟 [NEW] معادلة الـ BCS (Brain Clean Score)
  // ---------------------------------------------------------------------------
  double get dailyBcsScore {
    // 1. العادات الأساسية والمحفزات (تمثل 60% من التقييم الإجمالي)
    final double habitsRatio = RecoveryProtocolConstants.mandatoryTaskCount > 0 
        ? (completedCount / RecoveryProtocolConstants.mandatoryTaskCount) 
        : 0.0;
    final double habitsScore = habitsRatio * 60.0;

    // 2. جودة النوم (تمثل 20%)
    final double sleepScore = sleepCompleted ? 20.0 : 0.0;

    // 3. شرب الماء (يمثل 20%)
    final double waterScore = waterCompleted ? 20.0 : 0.0;

    // الإجمالي من 100
    return habitsScore + sleepScore + waterScore;
  }
  // ---------------------------------------------------------------------------

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

  // 🌟 [NEW] دوال للتحكم في مفاتيح النوم والماء من واجهة المستخدم
  RecoveryDayRecord toggleSleep(bool value) => copyWith(sleepCompleted: value);
  RecoveryDayRecord toggleWater(bool value) => copyWith(waterCompleted: value);

  /// camelCase JSON for Hive persistence (write path).
  Map<String, dynamic> toJson() => {
        RecoveryProtocolJsonKeys.dayIndex: dayIndex,
        RecoveryProtocolJsonKeys.taskCompleted: List<bool>.from(taskCompleted),
        RecoveryProtocolJsonKeys.penaltyApplied: penaltyApplied,
        // حفظ القيم الجديدة (تم استخدام نصوص مباشرة لسهولة الدمج)
        'sleepCompleted': sleepCompleted,
        'waterCompleted': waterCompleted,
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
      
      // 🌟 [NEW] استرجاع القيم الجديدة بأمان للمستخدمين القدامى والجدد
      sleepCompleted: json['sleepCompleted'] == true,
      waterCompleted: json['waterCompleted'] == true,
    );
  }
}