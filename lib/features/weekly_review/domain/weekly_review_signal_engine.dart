import 'weekly_review_enums.dart';
import 'weekly_review_question.dart';
import 'weekly_review_response.dart';
import 'weekly_review_signal.dart';
import 'weekly_review_summary.dart';
import 'weekly_review_version.dart';

/// Pure deterministic Contract §13 mapping.
abstract final class WeeklyReviewSignalEngine {
  static WeeklyReviewSignal build({
    required String periodId,
    required String artifactId,
    required WeeklyReviewSummary summary,
    required Map<String, WeeklyReviewResponse> responses,
    required DateTime createdAtUtc,
  }) {
    final q1 = responses[WeeklyReviewQuestionCatalog.manageability]?.singleChoice;
    final q3 = responses[WeeklyReviewQuestionCatalog.obstacle]?.singleChoice;
    final q5 =
        responses[WeeklyReviewQuestionCatalog.accessibilityUsed]?.booleanValue;

    final load = _load(q1);
    final obstacle = _obstacle(q3);
    final access = _access(q5);

    final limited = summary.evidenceDepth == EvidenceDepth.limited ||
        summary.completedSessionCount == 1;

    final PlanFitSignal planFit;
    final SignalConfidence confidence;

    if (limited) {
      planFit = PlanFitSignal.insufficientEvidence;
      confidence = SignalConfidence.low;
    } else {
      planFit = _planFit(q1);
      confidence = summary.evidenceDepth == EvidenceDepth.developing
          ? SignalConfidence.moderate
          : SignalConfidence.adequateForSignal;
    }

    return WeeklyReviewSignal(
      signalId: 'wrsig_$periodId',
      periodId: periodId,
      sourceArtifactId: artifactId,
      planFitSignal: planFit,
      loadSignal: load,
      obstacleSignal: obstacle,
      accessibilitySignal: access,
      evidenceDepth: summary.evidenceDepth,
      confidence: confidence,
      createdAt: createdAtUtc.toUtc(),
      signalVersion: WeeklyReviewVersion.signalModel,
    );
  }

  static LoadSignal _load(String? q1) {
    switch (q1) {
      case 'too_light':
        return LoadSignal.light;
      case 'about_right':
        return LoadSignal.suitable;
      case 'too_demanding':
        return LoadSignal.heavy;
      default:
        return LoadSignal.unknown;
    }
  }

  static PlanFitSignal _planFit(String? q1) {
    switch (q1) {
      case 'too_demanding':
        return PlanFitSignal.considerLessLoad;
      case 'too_light':
        return PlanFitSignal.considerMoreSupport;
      case 'about_right':
        return PlanFitSignal.maintain;
      default:
        return PlanFitSignal.insufficientEvidence;
    }
  }

  static ObstacleSignal _obstacle(String? q3) {
    switch (q3) {
      case 'no_major_obstacle':
        return ObstacleSignal.none;
      case 'time':
        return ObstacleSignal.time;
      case 'forgetfulness':
        return ObstacleSignal.forgetfulness;
      case 'low_energy':
        return ObstacleSignal.lowEnergy;
      case 'interruptions':
        return ObstacleSignal.interruptions;
      case 'unclear_step':
        return ObstacleSignal.unclearStep;
      case 'access_or_environment':
        return ObstacleSignal.accessOrEnvironment;
      default:
        return ObstacleSignal.unknown;
    }
  }

  static AccessibilitySignal _access(bool? q5) {
    if (q5 == null) return AccessibilitySignal.unknown;
    return q5 ? AccessibilitySignal.used : AccessibilitySignal.notUsed;
  }
}
