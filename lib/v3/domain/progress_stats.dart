import '../data/clarity_result.dart';
import '../data/day_progress.dart';
import '../data/focus_log.dart';
import '../data/sos_log.dart';
import 'program_engine.dart';

/// Aggregates for the Progress tab (§4.11).
class ProgressStats {
  const ProgressStats({
    required this.daysPracticed,
    required this.currentStreak,
    required this.bestStreak,
    required this.challengesDone,
    required this.focusMinutes,
    required this.urgesBeaten,
    this.clarityLatest,
    this.clarityFirst,
    this.phoneHoursFirst,
    this.phoneHoursLatest,
  });

  final int daysPracticed;
  final int currentStreak;
  final int bestStreak;
  final int challengesDone;
  final int focusMinutes;
  final int urgesBeaten;
  final int? clarityLatest;
  final int? clarityFirst;
  final double? phoneHoursFirst;
  final double? phoneHoursLatest;

  bool get hasClarityTrend =>
      clarityFirst != null && clarityLatest != null;

  bool get hasPhoneHours =>
      phoneHoursFirst != null && phoneHoursLatest != null;

  static ProgressStats fromState({
    required List<DayProgress> dayProgress,
    required List<ClarityResult> clarityResults,
    required List<FocusLog> focusLogs,
    required List<SosLog> sosLogs,
    required DateTime now,
  }) {
    final challenges = dayProgress.where((p) => p.challengeDone == true).length;
    final focusMins = focusLogs
        .where((f) => f.completed)
        .fold<int>(0, (sum, f) => sum + f.minutes);

    var urges = 0;
    for (final log in sosLogs) {
      final before = log.before;
      final after = log.after;
      if (before != null && after != null && after < before) {
        urges++;
      }
    }

    int? clarityFirst;
    int? clarityLatest;
    double? hoursFirst;
    double? hoursLatest;
    if (clarityResults.isNotEmpty) {
      clarityFirst = clarityResults.first.score;
      clarityLatest = clarityResults.last.score;
      hoursFirst = clarityResults.first.hoursEstimate;
      hoursLatest = clarityResults.last.hoursEstimate;
    }

    return ProgressStats(
      daysPracticed: ProgramEngine.completedDayCount(dayProgress),
      currentStreak: ProgramEngine.currentStreak(
        progress: dayProgress,
        now: now,
      ),
      bestStreak: ProgramEngine.bestStreak(progress: dayProgress),
      challengesDone: challenges,
      focusMinutes: focusMins,
      urgesBeaten: urges,
      clarityFirst: clarityFirst,
      clarityLatest: clarityLatest,
      phoneHoursFirst: hoursFirst,
      phoneHoursLatest: hoursLatest,
    );
  }
}
