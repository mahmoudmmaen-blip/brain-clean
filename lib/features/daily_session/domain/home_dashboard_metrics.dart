import '../../brain_check/data/brain_check_local_repository.dart';
import '../../brain_profile/data/brain_profile_repository.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../progress/data/progress_repository.dart';
import '../../progress/domain/progress_statistics.dart';
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
  }) async {
    try {
      final profile = await profiles.latest();
      final snapshot = await progress.latest();
      final sessionHistory = await sessions.history();
      final profileHistory = await profiles.history();
      final checkResult = brainCheck == null ? null : await brainCheck.loadResult();

      final stats = snapshot?.statistics ?? ProgressStatistics.empty;
      final focusPercent = _resolveFocusPercent(profile, stats);
      final improvement = _resolveImprovement(profileHistory, focusPercent);
      final exercisesToday = _exercisesCompletedToday(
        sessionHistory,
        todayDayKey,
      );
      final programDay = (stats.completedDays + 1).clamp(1, kHomeProgramTotalDays);
      final checkScore = checkResult?.scorePlaceholder.recoveryScore?.round() ??
          profile?.recoveryScore.value;

      return HomeDashboardMetrics(
        focusPercent: focusPercent,
        focusImprovementPercent: improvement,
        streakDays: stats.currentStreak,
        exercisesToday: exercisesToday,
        programDay: programDay,
        programTotalDays: kHomeProgramTotalDays,
        brainCheckCompleted: checkResult != null || profile != null,
        brainCheckScore: checkScore?.clamp(0, 100),
      );
    } catch (_) {
      return HomeDashboardMetrics.empty;
    }
  }

  static int _resolveFocusPercent(
    ProfilePack? profile,
    ProgressStatistics stats,
  ) {
    final score = profile?.recoveryScore.value;
    if (score != null) return score.clamp(0, 100);
    if (stats.totalSessions > 0) {
      return (stats.completionRate * 100).round().clamp(0, 100);
    }
    return 0;
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
