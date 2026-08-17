/// Aggregate counts derived only from completed DailySession history.
class ProgressStatistics {
  const ProgressStatistics({
    required this.totalSessions,
    required this.minimumPathCount,
    required this.standardPathCount,
    required this.completedDays,
    required this.skippedOptionalSteps,
    required this.requiredStepsCompleted,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int totalSessions;
  final int minimumPathCount;
  final int standardPathCount;
  final int completedDays;
  final int skippedOptionalSteps;
  final int requiredStepsCompleted;

  /// 0.0–1.0 — completed days / calendar span from first→last completion.
  /// Empty history → 0.0 (honest empty; not invented).
  final double completionRate;

  final int currentStreak;
  final int longestStreak;

  bool get isEmpty => totalSessions == 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalSessions': totalSessions,
        'minimumPathCount': minimumPathCount,
        'standardPathCount': standardPathCount,
        'completedDays': completedDays,
        'skippedOptionalSteps': skippedOptionalSteps,
        'requiredStepsCompleted': requiredStepsCompleted,
        'completionRate': completionRate,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };

  factory ProgressStatistics.fromJson(Map<String, dynamic> json) {
    return ProgressStatistics(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      minimumPathCount: (json['minimumPathCount'] as num?)?.toInt() ?? 0,
      standardPathCount: (json['standardPathCount'] as num?)?.toInt() ?? 0,
      completedDays: (json['completedDays'] as num?)?.toInt() ?? 0,
      skippedOptionalSteps:
          (json['skippedOptionalSteps'] as num?)?.toInt() ?? 0,
      requiredStepsCompleted:
          (json['requiredStepsCompleted'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = ProgressStatistics(
    totalSessions: 0,
    minimumPathCount: 0,
    standardPathCount: 0,
    completedDays: 0,
    skippedOptionalSteps: 0,
    requiredStepsCompleted: 0,
    completionRate: 0,
    currentStreak: 0,
    longestStreak: 0,
  );
}
