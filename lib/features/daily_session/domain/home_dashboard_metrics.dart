import '../../brain_check/data/brain_check_local_repository.dart';
import '../../brain_check/domain/brain_check_result.dart';
import '../../brain_profile/data/brain_profile_repository.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../progress/data/progress_repository.dart';
import '../../progress/domain/progress_experience_builder.dart';
import '../../progress/domain/progress_statistics.dart';
import '../../quick_tests/domain/quick_test_result.dart';
import '../../weekly_review/data/weekly_review_repository.dart';
import '../../weekly_review/domain/weekly_review_record.dart';
import '../data/daily_session_repository.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';

/// Recovery program length shown on Home (Pro mock).
const int kHomeProgramTotalDays = 30;

/// Dashboard metrics for the V2 Home tab.
class HomeDashboardMetrics {
  const HomeDashboardMetrics({
    required this.focusPercent,
    required this.focusImprovementPercent,
    required this.streakDays,
    required this.exercisesToday,
    required this.programDay,
    required this.programTotalDays,
    this.brainCheckCompleted = false,
    this.brainCheckScore,
    this.daysUntilWeeklyTest,
    this.daysUntilWeeklyReport,
    this.weeklyTestUnlocked = false,
    this.weeklyReportUnlocked = false,
  });

  /// Recovery percentage (0–100). Kept as [focusPercent] for call-site compat.
  final int focusPercent;
  final int focusImprovementPercent;
  final int streakDays;
  final int exercisesToday;
  final int programDay;
  final int programTotalDays;
  final bool brainCheckCompleted;
  final int? brainCheckScore;

  /// Null when unlocked / never locked; otherwise days remaining.
  final int? daysUntilWeeklyTest;
  final int? daysUntilWeeklyReport;
  final bool weeklyTestUnlocked;
  final bool weeklyReportUnlocked;

  int get recoveryPercent => focusPercent.clamp(0, 100);

  double get focusProgress => recoveryPercent / 100;

  double get programProgress =>
      programDay.clamp(0, programTotalDays) / programTotalDays;

  static const empty = HomeDashboardMetrics(
    focusPercent: 0,
    focusImprovementPercent: 0,
    streakDays: 0,
    exercisesToday: 0,
    programDay: 1,
    programTotalDays: kHomeProgramTotalDays,
    brainCheckCompleted: false,
    brainCheckScore: null,
    daysUntilWeeklyTest: null,
    daysUntilWeeklyReport: null,
    weeklyTestUnlocked: true,
    weeklyReportUnlocked: true,
  );
}

/// Loads Home dashboard metrics from local stores (no invented medical claims).
abstract final class HomeDashboardMetricsLoader {
  static Future<HomeDashboardMetrics> load({
    required BrainProfileRepository profiles,
    required ProgressRepository progress,
    required DailySessionRepository sessions,
    required String todayDayKey,
    BrainCheckLocalRepository? brainCheck,
    WeeklyReviewRepository? weeklyReviews,
    QuickTestResult? digitalBrainRotResult,
    DateTime? localNow,
    int programCompletionPercent = 0,
  }) async {
    try {
      final now = localNow ?? DateTime.now();
      final profile = await profiles.latest();
      final snapshot = await progress.latest();
      final sessionHistory = await sessions.history();
      final profileHistory = await profiles.history();
      final checkResult =
          brainCheck == null ? null : await brainCheck.loadResult();
      final latestReview = weeklyReviews == null
          ? null
          : await _latestCompletedReview(weeklyReviews);

      final stats = snapshot?.statistics ?? ProgressStatistics.empty;
      final focusPercent = _resolveFocusPercent(
        profile: profile,
        stats: stats,
        weeklyCheck: checkResult,
        digitalBrainRot: digitalBrainRotResult,
        localNow: now,
        programCompletionPercent: programCompletionPercent,
      );
      final improvement = _resolveImprovement(profileHistory, focusPercent);
      final exercisesToday = _exercisesCompletedToday(
        sessionHistory,
        todayDayKey,
      );
      final programDay =
          (stats.completedDays + 1).clamp(1, kHomeProgramTotalDays);
      final checkScore = checkResult?.scorePlaceholder.recoveryScore?.round() ??
          profile?.recoveryScore.value;

      final daysUntilTest = _daysUntilCooldown(
        localNow: now,
        lastAt: checkResult?.completedAt,
      );
      final daysUntilReport =
          ProgressExperienceBuilder.daysUntilWeeklyReviewUnlock(
        localNow: now,
        latestCompleted: latestReview,
      );

      return HomeDashboardMetrics(
        focusPercent: focusPercent,
        focusImprovementPercent: improvement,
        streakDays: stats.currentStreak,
        exercisesToday: exercisesToday,
        programDay: programDay,
        programTotalDays: kHomeProgramTotalDays,
        brainCheckCompleted: checkResult != null || profile != null,
        brainCheckScore: checkScore?.clamp(0, 100),
        daysUntilWeeklyTest: daysUntilTest,
        daysUntilWeeklyReport: daysUntilReport,
        weeklyTestUnlocked: daysUntilTest == null,
        weeklyReportUnlocked: daysUntilReport == null,
      );
    } catch (_) {
      return HomeDashboardMetrics.empty;
    }
  }

  static Future<WeeklyReviewRecord?> _latestCompletedReview(
    WeeklyReviewRepository repo,
  ) async {
    try {
      final all = await repo.history();
      WeeklyReviewRecord? latest;
      for (final r in all) {
        if (!r.isCompleted) continue;
        if (latest == null || r.completedAt!.isAfter(latest.completedAt!)) {
          latest = r;
        }
      }
      return latest;
    } catch (_) {
      return null;
    }
  }

  /// 7-day cooldown after last brain/weekly test.
  static int? _daysUntilCooldown({
    required DateTime localNow,
    required DateTime? lastAt,
  }) {
    if (lastAt == null) return null;
    final lastLocal = lastAt.toLocal();
    final lastDay = DateTime(lastLocal.year, lastLocal.month, lastLocal.day);
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final elapsed = today.difference(lastDay).inDays;
    const cooldown = ProgressExperienceBuilder.weeklyReviewCooldownDays;
    if (elapsed >= cooldown) return null;
    return cooldown - elapsed;
  }

  /// Recovery %:
  /// 40% daily program completion + 35% baseline brain check + 25% weekly test.
  static int _resolveFocusPercent({
    required ProfilePack? profile,
    required ProgressStatistics stats,
    required BrainCheckResult? weeklyCheck,
    QuickTestResult? digitalBrainRot,
    DateTime? localNow,
    int programCompletionPercent = 0,
  }) {
    final baselineScore = weeklyCheck?.scorePlaceholder.recoveryScore?.round() ??
        profile?.recoveryScore.value;
    // Baseline = brain check / profile; weekly pulse prefers latest check age.
    final baseline = (baselineScore ?? 0).clamp(0, 100);

    var weeklyScore = weeklyCheck?.scorePlaceholder.recoveryScore?.round();
    final dbr =
        _recentDigitalClarity(digitalBrainRot, localNow ?? DateTime.now());
    if (weeklyScore != null && dbr != null) {
      weeklyScore = ((weeklyScore * 0.75) + (dbr * 0.25)).round();
    } else if (weeklyScore == null && dbr != null) {
      weeklyScore = dbr;
    }
    final weekly = (weeklyScore ?? 0).clamp(0, 100);
    final program = programCompletionPercent.clamp(0, 100);

    final blended =
        (program * 0.40) + (baseline * 0.35) + (weekly * 0.25);
    if (program == 0 && baseline == 0 && weekly == 0) {
      if (stats.totalSessions > 0) {
        return (stats.completionRate * 100).round().clamp(0, 100);
      }
      return 0;
    }
    return blended.round().clamp(0, 100);
  }

  static int? _recentDigitalClarity(QuickTestResult? result, DateTime localNow) {
    if (result == null) return null;
    final completed = result.completedAt.toLocal();
    final age = localNow.difference(completed).inDays;
    if (age > 14) return null;
    return result.scorePercent.clamp(0, 100);
  }

  static int _resolveImprovement(
    List<ProfilePack> history,
    int currentFocus,
  ) {
    if (history.length < 2 || currentFocus <= 0) return 0;
    final first = history.first.recoveryScore.value;
    final latest = history.last.recoveryScore.value ?? currentFocus;
    if (first == null) return 0;
    return (latest - first).clamp(0, 100);
  }

  static int _exercisesCompletedToday(
    List<DailySession> sessionHistory,
    String todayDayKey,
  ) {
    var count = 0;
    for (final raw in sessionHistory) {
      if (raw.dayKey != todayDayKey) continue;
      if (raw.status == DailySessionStatus.completed ||
          raw.status == DailySessionStatus.partial) {
        count++;
      }
    }
    return count;
  }
}
