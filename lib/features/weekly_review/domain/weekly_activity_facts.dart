import '../../daily_session/domain/daily_session.dart';
import '../../progress/domain/progress_engine.dart';
import '../../progress/domain/progress_snapshot.dart';
import 'weekly_period.dart';
import 'weekly_review_eligibility.dart';

/// Read-only 7-day slice of existing Progress / session history.
///
/// Not persisted. Does not invent sessions, streaks, or plan changes.
class WeeklyActivityFacts {
  const WeeklyActivityFacts({
    required this.periodId,
    required this.startDayKey,
    required this.endDayKey,
    required this.completedSessions,
    required this.completedDays,
    required this.requiredStepsCompleted,
    required this.weekStreak,
    required this.longestWeekStreak,
    required this.currentStreak,
    required this.longestStreak,
    required this.adherencePercent,
  });

  static const periodLengthDays = 7;

  final String periodId;
  final String startDayKey;
  final String endDayKey;

  /// Completed DailySession count inside the period.
  final int completedSessions;

  /// Distinct completed day keys inside the period.
  final int completedDays;

  /// Required (non-optional) completed steps inside the period.
  final int requiredStepsCompleted;

  /// Consecutive completed days ending on the period’s last day (grace: day before).
  final int weekStreak;

  /// Longest consecutive run inside the period.
  final int longestWeekStreak;

  /// All-time current streak from [ProgressStatistics] when a snapshot exists.
  final int currentStreak;

  /// All-time longest streak from [ProgressStatistics] when a snapshot exists.
  final int longestStreak;

  /// Completed days / 7, rounded 0–100. Honest empty week → 0.
  final int adherencePercent;

  bool get isEmpty => completedSessions == 0;

  static WeeklyActivityFacts empty(WeeklyPeriod period) {
    return WeeklyActivityFacts(
      periodId: period.periodId,
      startDayKey: period.startDayKey,
      endDayKey: period.endDayKey,
      completedSessions: 0,
      completedDays: 0,
      requiredStepsCompleted: 0,
      weekStreak: 0,
      longestWeekStreak: 0,
      currentStreak: 0,
      longestStreak: 0,
      adherencePercent: 0,
    );
  }

  /// Derives facts from existing [DailySession] history + optional Progress snapshot.
  static WeeklyActivityFacts fromHistory({
    required WeeklyPeriod period,
    required List<DailySession> history,
    ProgressSnapshot? snapshot,
  }) {
    final inPeriod =
        WeeklyReviewEligibilityEngine.sessionsInPeriod(history, period);
    final window = ProgressEngine.build(
      sessions: inPeriod,
      nowUtc: period.materializedAt,
      asOfDayKey: period.endDayKey,
    );
    final stats = window.statistics;
    final adherence = ((stats.completedDays / periodLengthDays) * 100)
        .round()
        .clamp(0, 100);
    return WeeklyActivityFacts(
      periodId: period.periodId,
      startDayKey: period.startDayKey,
      endDayKey: period.endDayKey,
      completedSessions: stats.totalSessions,
      completedDays: stats.completedDays,
      requiredStepsCompleted: stats.requiredStepsCompleted,
      weekStreak: stats.currentStreak,
      longestWeekStreak: stats.longestStreak,
      currentStreak: snapshot?.statistics.currentStreak ?? stats.currentStreak,
      longestStreak: snapshot?.statistics.longestStreak ?? stats.longestStreak,
      adherencePercent: adherence,
    );
  }
}
