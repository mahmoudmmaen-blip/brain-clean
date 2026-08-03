import '../../daily_session/domain/daily_session.dart';
import '../../daily_session/domain/daily_session_path.dart';
import 'weekly_period.dart';
import 'weekly_review_enums.dart';
import 'weekly_review_question.dart';
import 'weekly_review_response.dart';
import 'weekly_review_summary.dart';
import 'weekly_review_version.dart';

/// Pure deterministic summary builder.
abstract final class WeeklyReviewSummaryEngine {
  static WeeklyReviewSummary? build({
    required WeeklyPeriod period,
    required List<DailySession> completedInPeriod,
    required Map<String, WeeklyReviewResponse> responses,
    required DateTime generatedAtUtc,
  }) {
    if (completedInPeriod.isEmpty) return null;
    if (!WeeklyReviewResponseValidator.requiredAnswersComplete(responses)) {
      return null;
    }

    final manageability =
        responses[WeeklyReviewQuestionCatalog.manageability]!.singleChoice!;
    final pauseFocus =
        responses[WeeklyReviewQuestionCatalog.pauseFocus]!.scaleValue!;
    final obstacle =
        responses[WeeklyReviewQuestionCatalog.obstacle]!.singleChoice!;
    final support =
        responses[WeeklyReviewQuestionCatalog.support]?.multiSelect ??
            const <String>[];
    final access = responses[WeeklyReviewQuestionCatalog.accessibilityUsed]
        ?.booleanValue;

    var minimumPathCount = 0;
    var standardPathCount = 0;
    final days = <String>{};
    for (final s in completedInPeriod) {
      days.add(s.dayKey);
      if (s.path == DailySessionPath.minimum) {
        minimumPathCount += 1;
      } else {
        standardPathCount += 1;
      }
    }

    final sessionCount = completedInPeriod.length;
    final dayCount = days.length;
    final pathMix = _pathMix(sessionCount, minimumPathCount, standardPathCount);
    final rhythm = _rhythm(sessionCount, dayCount);
    final evidence = _evidence(sessionCount);

    return WeeklyReviewSummary(
      periodId: period.periodId,
      periodStartDayKey: period.startDayKey,
      periodEndDayKey: period.endDayKey,
      completedSessionCount: sessionCount,
      completedDayCount: dayCount,
      minimumPathCount: minimumPathCount,
      standardPathCount: standardPathCount,
      pathMixLabel: pathMix,
      rhythmLabel: rhythm,
      evidenceDepth: evidence,
      manageabilityResponse: manageability,
      pauseFocusResponse: pauseFocus,
      obstacleResponse: obstacle,
      supportResponses: List<String>.from(support),
      accessibilityUsed: access,
      strongestObservedPattern: _strongest(sessionCount, pathMix),
      attentionNext: _attention(manageability, obstacle, pauseFocus),
      planUnchangedNotice: true,
      confidenceQualifier: _confidence(evidence),
      generatedAt: generatedAtUtc.toUtc(),
      modelVersion: WeeklyReviewVersion.reviewModel,
    );
  }

  static PathMixLabel _pathMix(int sessions, int min, int std) {
    if (sessions == 1) return PathMixLabel.singleSessionOnly;
    if (min > 0 && std == 0) return PathMixLabel.mostlyMinimum;
    if (std > 0 && min == 0) return PathMixLabel.mostlyStandard;
    return PathMixLabel.balanced;
  }

  static RhythmLabel _rhythm(int sessions, int days) {
    if (sessions == 1 || days <= 1) return RhythmLabel.limitedHistory;
    if (days >= 5) return RhythmLabel.steady;
    return RhythmLabel.intermittent;
  }

  static EvidenceDepth _evidence(int sessions) {
    if (sessions == 1) return EvidenceDepth.limited;
    if (sessions <= 3) return EvidenceDepth.developing;
    return EvidenceDepth.sufficientForWeeklySummary;
  }

  static String _strongest(int sessions, PathMixLabel mix) {
    if (sessions == 1) return 'single_completion_observed';
    switch (mix) {
      case PathMixLabel.mostlyMinimum:
        return 'minimum_path_majority';
      case PathMixLabel.mostlyStandard:
        return 'standard_path_majority';
      case PathMixLabel.balanced:
        return 'mixed_paths';
      case PathMixLabel.singleSessionOnly:
        return 'single_completion_observed';
    }
  }

  static String _attention(String manageability, String obstacle, int pause) {
    if (manageability == 'too_demanding') return 'consider_load';
    if (manageability == 'too_light') return 'consider_support_depth';
    if (obstacle != 'no_major_obstacle') return 'obstacle_$obstacle';
    if (pause <= 2) return 'pause_focus_low';
    return 'maintain_observation';
  }

  static String _confidence(EvidenceDepth depth) {
    switch (depth) {
      case EvidenceDepth.limited:
        return 'limited_evidence';
      case EvidenceDepth.developing:
        return 'early_evidence';
      case EvidenceDepth.sufficientForWeeklySummary:
        return 'summary_only_not_causal';
    }
  }
}
