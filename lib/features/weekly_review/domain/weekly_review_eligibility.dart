import '../../daily_session/domain/daily_session.dart';
import '../../progress/domain/progress_engine.dart';
import '../../progress/domain/progress_snapshot.dart';
import 'weekly_period.dart';
import 'weekly_period_resolver.dart';
import 'weekly_review_enums.dart';
import 'weekly_review_record.dart';

/// Eligibility decision for a target period.
class WeeklyReviewEligibility {
  const WeeklyReviewEligibility._({
    required this.isEligible,
    required this.period,
    this.reason,
    this.completedSessions = const [],
    this.existingCompleted,
  });

  factory WeeklyReviewEligibility.eligible({
    required WeeklyPeriod period,
    required List<DailySession> completedSessions,
  }) {
    return WeeklyReviewEligibility._(
      isEligible: true,
      period: period,
      completedSessions: completedSessions,
    );
  }

  factory WeeklyReviewEligibility.notEligible({
    required WeeklyPeriod period,
    required WeeklyReviewNotEligibleReason reason,
    List<DailySession> completedSessions = const [],
    WeeklyReviewRecord? existingCompleted,
  }) {
    return WeeklyReviewEligibility._(
      isEligible: false,
      period: period,
      reason: reason,
      completedSessions: completedSessions,
      existingCompleted: existingCompleted,
    );
  }

  final bool isEligible;
  final WeeklyPeriod period;
  final WeeklyReviewNotEligibleReason? reason;
  final List<DailySession> completedSessions;
  final WeeklyReviewRecord? existingCompleted;

  bool get alreadyCompleted =>
      reason == WeeklyReviewNotEligibleReason.alreadyCompleted ||
      existingCompleted?.isCompleted == true;
}

/// Pure eligibility evaluation (Contract §6).
abstract final class WeeklyReviewEligibilityEngine {
  static List<DailySession> sessionsInPeriod(
    Iterable<DailySession> history,
    WeeklyPeriod period,
  ) {
    return ProgressEngine.completedSessions(history)
        .where((s) => period.containsDayKey(s.dayKey))
        .toList(growable: false);
  }

  static WeeklyReviewEligibility evaluate({
    required WeeklyPeriod period,
    required DateTime localNow,
    required Duration timezoneOffset,
    required List<DailySession> history,
    required ProgressSnapshot? progressSnapshot,
    required String? planId,
    required String? profilePackId,
    required WeeklyReviewRecord? existingForPeriod,
    bool schemasSupported = true,
  }) {
    final inPeriod = sessionsInPeriod(history, period);

    if (existingForPeriod != null && existingForPeriod.isCompleted) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.alreadyCompleted,
        existingCompleted: existingForPeriod,
        completedSessions: inPeriod,
      );
    }

    if (!schemasSupported) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.unsupportedSchema,
      );
    }

    if (WeeklyPeriodResolver.isCurrentWeek(
      period: period,
      localNow: localNow,
      timezoneOffset: timezoneOffset,
    )) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.currentWeek,
      );
    }

    if (inPeriod.isEmpty) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.zeroCompletedSessions,
      );
    }

    if (progressSnapshot == null) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.missingProgressSnapshot,
        completedSessions: inPeriod,
      );
    }

    final resolvedPlan = (planId != null && planId.isNotEmpty)
        ? planId
        : inPeriod.first.source.planId;
    if (resolvedPlan.isEmpty) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.missingPlan,
        completedSessions: inPeriod,
      );
    }

    final resolvedProfile = (profilePackId != null && profilePackId.isNotEmpty)
        ? profilePackId
        : inPeriod.first.source.profilePackId;
    if (resolvedProfile.isEmpty) {
      return WeeklyReviewEligibility.notEligible(
        period: period,
        reason: WeeklyReviewNotEligibleReason.missingProfile,
        completedSessions: inPeriod,
      );
    }

    return WeeklyReviewEligibility.eligible(
      period: period,
      completedSessions: inPeriod,
    );
  }
}
