import '../../weekly_review/domain/weekly_review_enums.dart';
import '../../weekly_review/domain/weekly_review_summary.dart';
import 'progress_experience_enums.dart';
import 'progress_statistics.dart';
import 'progress_timeline.dart';

/// Immutable read-only Progress experience surface model (Slice 8.1).
class ProgressViewModel {
  const ProgressViewModel({
    required this.hasHistory,
    required this.totalCompletedSessions,
    required this.completedDays,
    required this.minimumPathCount,
    required this.standardPathCount,
    required this.completionRatePercent,
    required this.currentRhythmDays,
    required this.longestRhythmDays,
    required this.firstCompletedDayKey,
    required this.lastCompletedDayKey,
    required this.recentTimeline,
    required this.evidenceDepth,
    required this.proofHeadline,
    required this.planId,
    required this.profilePackId,
    required this.scoreModelVersion,
    required this.scoreDisplayValue,
    required this.scoreBandWire,
    required this.scoreMeasuredDayKey,
    required this.showScoreRow,
    required this.weeklyReviewCardState,
    required this.weeklyPeriodId,
    required this.weeklyPeriodStartDayKey,
    required this.weeklyPeriodEndDayKey,
    required this.weeklySummaryPreview,
    required this.primaryDestination,
    required this.snapshotId,
    required this.asOfDayKey,
  });

  final bool hasHistory;
  final int totalCompletedSessions;
  final int completedDays;
  final int minimumPathCount;
  final int standardPathCount;

  /// Integer percent 0–100; never fake decimals.
  final int completionRatePercent;
  final int currentRhythmDays;
  final int longestRhythmDays;
  final String? firstCompletedDayKey;
  final String? lastCompletedDayKey;
  final List<ProgressTimelineEntry> recentTimeline;
  final ProgressEvidenceDepth evidenceDepth;
  final ProgressProofHeadline proofHeadline;
  final String? planId;
  final String? profilePackId;
  final String? scoreModelVersion;
  final int? scoreDisplayValue;
  final String? scoreBandWire;
  final String? scoreMeasuredDayKey;
  final bool showScoreRow;
  final ProgressWeeklyReviewCardState weeklyReviewCardState;
  final String? weeklyPeriodId;
  final String? weeklyPeriodStartDayKey;
  final String? weeklyPeriodEndDayKey;
  final WeeklyReviewSummary? weeklySummaryPreview;
  final ProgressNextDestination primaryDestination;
  final String? snapshotId;
  final String? asOfDayKey;

  bool get isEmpty => !hasHistory;

  PathMixLabel? get pathMixHint {
    if (!hasHistory) return null;
    if (totalCompletedSessions == 1) return PathMixLabel.singleSessionOnly;
    if (minimumPathCount > 0 && standardPathCount == 0) {
      return PathMixLabel.mostlyMinimum;
    }
    if (standardPathCount > 0 && minimumPathCount == 0) {
      return PathMixLabel.mostlyStandard;
    }
    return PathMixLabel.balanced;
  }

  factory ProgressViewModel.empty() {
    return const ProgressViewModel(
      hasHistory: false,
      totalCompletedSessions: 0,
      completedDays: 0,
      minimumPathCount: 0,
      standardPathCount: 0,
      completionRatePercent: 0,
      currentRhythmDays: 0,
      longestRhythmDays: 0,
      firstCompletedDayKey: null,
      lastCompletedDayKey: null,
      recentTimeline: [],
      evidenceDepth: ProgressEvidenceDepth.empty,
      proofHeadline: ProgressProofHeadline.empty,
      planId: null,
      profilePackId: null,
      scoreModelVersion: null,
      scoreDisplayValue: null,
      scoreBandWire: null,
      scoreMeasuredDayKey: null,
      showScoreRow: false,
      weeklyReviewCardState: ProgressWeeklyReviewCardState.notEnoughActivity,
      weeklyPeriodId: null,
      weeklyPeriodStartDayKey: null,
      weeklyPeriodEndDayKey: null,
      weeklySummaryPreview: null,
      primaryDestination: ProgressNextDestination.today,
      snapshotId: null,
      asOfDayKey: null,
    );
  }

  static ProgressViewModel fromStatistics({
    required ProgressStatistics stats,
    required bool hasHistory,
    required String? firstDay,
    required String? lastDay,
    required List<ProgressTimelineEntry> recentTimeline,
    required String? planId,
    required String? profilePackId,
    required String? scoreModelVersion,
    required int? scoreDisplayValue,
    required String? scoreBandWire,
    required String? scoreMeasuredDayKey,
    required bool showScoreRow,
    required ProgressWeeklyReviewCardState weeklyState,
    required String? weeklyPeriodId,
    required String? weeklyStart,
    required String? weeklyEnd,
    required WeeklyReviewSummary? weeklyPreview,
    required ProgressNextDestination primary,
    required String? snapshotId,
    required String? asOfDayKey,
    required bool hasCompletedWeeklyArtifact,
  }) {
    final evidence = _evidence(stats.totalSessions);
    final headline = _headline(
      sessions: stats.totalSessions,
      days: stats.completedDays,
      rhythm: stats.currentStreak,
      hasWeeklyArtifact: hasCompletedWeeklyArtifact,
    );
    final rate = (stats.completionRate * 100).round().clamp(0, 100);
    return ProgressViewModel(
      hasHistory: hasHistory,
      totalCompletedSessions: stats.totalSessions,
      completedDays: stats.completedDays,
      minimumPathCount: stats.minimumPathCount,
      standardPathCount: stats.standardPathCount,
      completionRatePercent: rate,
      currentRhythmDays: stats.currentStreak,
      longestRhythmDays: stats.longestStreak,
      firstCompletedDayKey: firstDay,
      lastCompletedDayKey: lastDay,
      recentTimeline: List.unmodifiable(recentTimeline),
      evidenceDepth: evidence,
      proofHeadline: headline,
      planId: planId,
      profilePackId: profilePackId,
      scoreModelVersion: scoreModelVersion,
      scoreDisplayValue: scoreDisplayValue,
      scoreBandWire: scoreBandWire,
      scoreMeasuredDayKey: scoreMeasuredDayKey,
      showScoreRow: showScoreRow,
      weeklyReviewCardState: weeklyState,
      weeklyPeriodId: weeklyPeriodId,
      weeklyPeriodStartDayKey: weeklyStart,
      weeklyPeriodEndDayKey: weeklyEnd,
      weeklySummaryPreview: weeklyPreview,
      primaryDestination: primary,
      snapshotId: snapshotId,
      asOfDayKey: asOfDayKey,
    );
  }

  static ProgressEvidenceDepth _evidence(int sessions) {
    if (sessions <= 0) return ProgressEvidenceDepth.empty;
    if (sessions == 1) return ProgressEvidenceDepth.limited;
    if (sessions <= 3) return ProgressEvidenceDepth.developing;
    return ProgressEvidenceDepth.sufficient;
  }

  static ProgressProofHeadline _headline({
    required int sessions,
    required int days,
    required int rhythm,
    required bool hasWeeklyArtifact,
  }) {
    if (sessions <= 0) return ProgressProofHeadline.empty;
    if (hasWeeklyArtifact) {
      return ProgressProofHeadline.weeklyEvidenceAvailable;
    }
    if (sessions == 1) return ProgressProofHeadline.firstSession;
    if (days <= 2) return ProgressProofHeadline.fewDays;
    if (rhythm >= 5 || days >= 5) {
      return ProgressProofHeadline.steadierPattern;
    }
    if (days >= 3) return ProgressProofHeadline.rhythmBeginning;
    return ProgressProofHeadline.limitedHistory;
  }
}
