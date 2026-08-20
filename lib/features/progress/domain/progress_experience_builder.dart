import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/recovery_score.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../daily_session/domain/daily_session.dart';
import '../../weekly_review/domain/weekly_period.dart';
import '../../weekly_review/domain/weekly_period_resolver.dart';
import '../../weekly_review/domain/weekly_review_eligibility.dart';
import '../../weekly_review/domain/weekly_review_enums.dart';
import '../../weekly_review/domain/weekly_review_record.dart';
import '../../weekly_review/domain/weekly_review_summary.dart';
import 'progress_engine.dart';
import 'progress_experience_enums.dart';
import 'progress_snapshot.dart';
import 'progress_timeline.dart';
import 'progress_view_model.dart';
import 'progress_weekly_bar_day.dart';

/// Pure deterministic builder — no network, no Plan/Score mutation.
abstract final class ProgressExperienceBuilder {
  static const recentTimelineLimit = 7;
  static const weeklyReviewCooldownDays = 7;

  static ProgressViewModel build({
    required ProgressSnapshot? snapshot,
    required List<DailySession> sessionHistory,
    required ProfilePack? profilePack,
    required WeeklyPeriod previousPeriod,
    required DateTime localNow,
    required Duration timezoneOffset,
    required WeeklyReviewRecord? reviewForPeriod,
    required WeeklyReviewSummary? artifactSummary,
    required bool schemasSupported,
    WeeklyReviewRecord? latestCompletedReview,
  }) {
    final completed = ProgressEngine.completedSessions(sessionHistory);

    // Prefer persisted snapshot; fall back to ephemeral build for display.
    final effective = snapshot ??
        ProgressEngine.build(
          sessions: sessionHistory,
          nowUtc: DateTime.now().toUtc(),
          asOfDayKey: DailyDayKey.fromLocal(localNow),
        );

    final recent = _recent(effective.timeline.entries);
    final weeklyBars = buildWeeklyBars(
      localNow: localNow,
      timeline: effective.timeline.entries,
    );
    final cooldownDays = daysUntilWeeklyReviewUnlock(
      localNow: localNow,
      latestCompleted: latestCompletedReview,
    );

    final weeklyState = _weeklyState(
      period: previousPeriod,
      localNow: localNow,
      timezoneOffset: timezoneOffset,
      history: sessionHistory,
      snapshot: effective,
      review: reviewForPeriod,
      schemasSupported: schemasSupported,
      cooldownDaysRemaining: cooldownDays,
    );

    final primary = _primary(
      hasHistory: effective.summary.hasHistory,
      weeklyState: weeklyState,
    );

    final score = profilePack?.recoveryScore;
    final showScore = score != null &&
        (score.isValid || score.isPending || score.isUnavailable);

    return ProgressViewModel.fromStatistics(
      stats: effective.statistics,
      hasHistory: effective.summary.hasHistory,
      firstDay: effective.summary.firstCompletedDayKey,
      lastDay: effective.summary.lastCompletedDayKey,
      recentTimeline: recent,
      weeklyBars: weeklyBars,
      planId: effective.summary.activePlanId ??
          (completed.isNotEmpty ? completed.last.source.planId : null),
      profilePackId: effective.summary.profilePackId ?? profilePack?.id,
      scoreModelVersion: score?.modelVersion ??
          effective.summary.recoveryScoreModelVersion,
      scoreDisplayValue: score?.isValid == true ? score!.value : null,
      scoreBandWire: score?.band.wireName,
      scoreMeasuredDayKey: profilePack != null
          ? DailyDayKey.fromUtc(
              profilePack.createdAt.toUtc(),
              timeZoneOffset: Duration.zero,
            )
          : null,
      showScoreRow: showScore,
      weeklyState: weeklyState,
      weeklyPeriodId: previousPeriod.periodId,
      weeklyStart: previousPeriod.startDayKey,
      weeklyEnd: previousPeriod.endDayKey,
      weeklyPreview: artifactSummary,
      daysUntilWeeklyReviewUnlock: cooldownDays,
      primary: primary,
      snapshotId: effective.id,
      asOfDayKey: effective.asOfDayKey,
      hasCompletedWeeklyArtifact: artifactSummary != null,
    );
  }

  /// Last 7 local calendar days — completed if any session finished that day.
  static List<ProgressWeeklyBarDay> buildWeeklyBars({
    required DateTime localNow,
    required List<ProgressTimelineEntry> timeline,
  }) {
    final completedKeys = <String>{
      for (final e in timeline)
        if (e.fullCompletions > 0 || e.requiredStepsCompleted > 0) e.dayKey,
    };
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final out = <ProgressWeeklyBarDay>[];
    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = DailyDayKey.fromLocal(day);
      out.add(
        ProgressWeeklyBarDay(
          dayKey: key,
          weekdayLabel: _weekdayLabel(day.weekday),
          completed: completedKeys.contains(key),
        ),
      );
    }
    return List.unmodifiable(out);
  }

  static String _weekdayLabel(int weekday) {
    // Mon=1 … Sun=7
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[(weekday - 1).clamp(0, 6)];
  }

  /// Days remaining before weekly review unlocks (null when unlocked).
  static int? daysUntilWeeklyReviewUnlock({
    required DateTime localNow,
    required WeeklyReviewRecord? latestCompleted,
  }) {
    final completedAt = latestCompleted?.completedAt;
    if (completedAt == null) return null;
    final lastLocal = completedAt.toLocal();
    final lastDay = DateTime(lastLocal.year, lastLocal.month, lastLocal.day);
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final elapsed = today.difference(lastDay).inDays;
    if (elapsed >= weeklyReviewCooldownDays) return null;
    return weeklyReviewCooldownDays - elapsed;
  }

  static List<ProgressTimelineEntry> _recent(
    List<ProgressTimelineEntry> ascending,
  ) {
    if (ascending.isEmpty) return const [];
    final copy = List<ProgressTimelineEntry>.from(ascending.reversed);
    if (copy.length > recentTimelineLimit) {
      return List.unmodifiable(copy.take(recentTimelineLimit));
    }
    return List.unmodifiable(copy);
  }

  static ProgressWeeklyReviewCardState _weeklyState({
    required WeeklyPeriod period,
    required DateTime localNow,
    required Duration timezoneOffset,
    required List<DailySession> history,
    required ProgressSnapshot snapshot,
    required WeeklyReviewRecord? review,
    required bool schemasSupported,
    required int? cooldownDaysRemaining,
  }) {
    if (!schemasSupported) {
      return ProgressWeeklyReviewCardState.unsupportedVersion;
    }
    if (review != null && review.isCompleted) {
      return ProgressWeeklyReviewCardState.summaryAvailable;
    }
    if (review != null && review.isDraft) {
      return ProgressWeeklyReviewCardState.draftInProgress;
    }

    // Explicit 7-day cooldown after last completed review.
    if (cooldownDaysRemaining != null && cooldownDaysRemaining > 0) {
      return ProgressWeeklyReviewCardState.currentWeekInProgress;
    }

    final planId = snapshot.summary.activePlanId;
    final profileId = snapshot.summary.profilePackId;
    final elig = WeeklyReviewEligibilityEngine.evaluate(
      period: period,
      localNow: localNow,
      timezoneOffset: timezoneOffset,
      history: history,
      progressSnapshot: snapshot,
      planId: planId,
      profilePackId: profileId,
      existingForPeriod: review,
      schemasSupported: schemasSupported,
    );

    if (elig.isEligible) {
      return ProgressWeeklyReviewCardState.available;
    }

    switch (elig.reason) {
      case WeeklyReviewNotEligibleReason.alreadyCompleted:
        return ProgressWeeklyReviewCardState.summaryAvailable;
      case WeeklyReviewNotEligibleReason.currentWeek:
        return ProgressWeeklyReviewCardState.currentWeekInProgress;
      case WeeklyReviewNotEligibleReason.zeroCompletedSessions:
        return ProgressWeeklyReviewCardState.notEnoughActivity;
      case WeeklyReviewNotEligibleReason.missingPlan:
      case WeeklyReviewNotEligibleReason.missingProfile:
      case WeeklyReviewNotEligibleReason.missingProgressSnapshot:
        return ProgressWeeklyReviewCardState.missingReferences;
      case WeeklyReviewNotEligibleReason.unsupportedSchema:
        return ProgressWeeklyReviewCardState.unsupportedVersion;
      case WeeklyReviewNotEligibleReason.periodUnresolved:
      case null:
        return ProgressWeeklyReviewCardState.error;
    }
  }

  /// Build Spec regression: REVIEW_DUE next priority; one primary CTA.
  static ProgressNextDestination _primary({
    required bool hasHistory,
    required ProgressWeeklyReviewCardState weeklyState,
  }) {
    switch (weeklyState) {
      case ProgressWeeklyReviewCardState.available:
      case ProgressWeeklyReviewCardState.draftInProgress:
        return ProgressNextDestination.weeklyReviewQuestions;
      case ProgressWeeklyReviewCardState.completed:
      case ProgressWeeklyReviewCardState.summaryAvailable:
        return ProgressNextDestination.weeklyReviewSummary;
      case ProgressWeeklyReviewCardState.notEnoughActivity:
      case ProgressWeeklyReviewCardState.currentWeekInProgress:
      case ProgressWeeklyReviewCardState.missingReferences:
      case ProgressWeeklyReviewCardState.unsupportedVersion:
      case ProgressWeeklyReviewCardState.error:
        return hasHistory
            ? ProgressNextDestination.today
            : ProgressNextDestination.today;
    }
  }

  /// Convenience for tests — previous ISO week only.
  static WeeklyPeriod resolveTargetPeriod({
    required DateTime localNow,
    required Duration timezoneOffset,
  }) {
    return WeeklyPeriodResolver.previousCompletedWeek(
      localNow: localNow,
      timezoneOffset: timezoneOffset,
    );
  }
}
