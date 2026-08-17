enum WeeklyReviewStatus {
  draft,
  completed,
}

extension WeeklyReviewStatusX on WeeklyReviewStatus {
  String get wireName => name;

  static WeeklyReviewStatus fromWire(String? raw) {
    switch (raw) {
      case 'completed':
        return WeeklyReviewStatus.completed;
      case 'draft':
      default:
        return WeeklyReviewStatus.draft;
    }
  }
}

/// Explicit not-eligible reason codes (UI maps to calm copy).
enum WeeklyReviewNotEligibleReason {
  currentWeek,
  zeroCompletedSessions,
  missingProgressSnapshot,
  missingPlan,
  missingProfile,
  unsupportedSchema,
  periodUnresolved,
  /// Completed review already exists — open WRV-02, do not start a new draft.
  alreadyCompleted,
}

enum WeeklyReviewQuestionType {
  singleChoice,
  boundedScale,
  multiSelect,
  boolean_,
}

extension WeeklyReviewQuestionTypeX on WeeklyReviewQuestionType {
  String get wireName {
    switch (this) {
      case WeeklyReviewQuestionType.singleChoice:
        return 'single_choice';
      case WeeklyReviewQuestionType.boundedScale:
        return 'bounded_scale';
      case WeeklyReviewQuestionType.multiSelect:
        return 'multi_select';
      case WeeklyReviewQuestionType.boolean_:
        return 'boolean';
    }
  }

  static WeeklyReviewQuestionType fromWire(String? raw) {
    switch (raw) {
      case 'bounded_scale':
        return WeeklyReviewQuestionType.boundedScale;
      case 'multi_select':
        return WeeklyReviewQuestionType.multiSelect;
      case 'boolean':
        return WeeklyReviewQuestionType.boolean_;
      case 'single_choice':
      default:
        return WeeklyReviewQuestionType.singleChoice;
    }
  }
}

enum PathMixLabel {
  mostlyMinimum,
  mostlyStandard,
  balanced,
  singleSessionOnly,
}

extension PathMixLabelX on PathMixLabel {
  String get wireName {
    switch (this) {
      case PathMixLabel.mostlyMinimum:
        return 'mostly_minimum';
      case PathMixLabel.mostlyStandard:
        return 'mostly_standard';
      case PathMixLabel.balanced:
        return 'balanced';
      case PathMixLabel.singleSessionOnly:
        return 'single_session_only';
    }
  }

  static PathMixLabel fromWire(String? raw) {
    switch (raw) {
      case 'mostly_minimum':
        return PathMixLabel.mostlyMinimum;
      case 'mostly_standard':
        return PathMixLabel.mostlyStandard;
      case 'single_session_only':
        return PathMixLabel.singleSessionOnly;
      case 'balanced':
      default:
        return PathMixLabel.balanced;
    }
  }
}

enum RhythmLabel {
  steady,
  intermittent,
  limitedHistory,
}

extension RhythmLabelX on RhythmLabel {
  String get wireName {
    switch (this) {
      case RhythmLabel.steady:
        return 'steady';
      case RhythmLabel.intermittent:
        return 'intermittent';
      case RhythmLabel.limitedHistory:
        return 'limited_history';
    }
  }

  static RhythmLabel fromWire(String? raw) {
    switch (raw) {
      case 'steady':
        return RhythmLabel.steady;
      case 'limited_history':
        return RhythmLabel.limitedHistory;
      case 'intermittent':
      default:
        return RhythmLabel.intermittent;
    }
  }
}

enum EvidenceDepth {
  limited,
  developing,
  sufficientForWeeklySummary,
}

extension EvidenceDepthX on EvidenceDepth {
  String get wireName {
    switch (this) {
      case EvidenceDepth.limited:
        return 'limited';
      case EvidenceDepth.developing:
        return 'developing';
      case EvidenceDepth.sufficientForWeeklySummary:
        return 'sufficient_for_weekly_summary';
    }
  }

  static EvidenceDepth fromWire(String? raw) {
    switch (raw) {
      case 'developing':
        return EvidenceDepth.developing;
      case 'sufficient_for_weekly_summary':
        return EvidenceDepth.sufficientForWeeklySummary;
      case 'limited':
      default:
        return EvidenceDepth.limited;
    }
  }
}

enum PlanFitSignal {
  maintain,
  considerMoreSupport,
  considerLessLoad,
  insufficientEvidence,
}

extension PlanFitSignalX on PlanFitSignal {
  String get wireName {
    switch (this) {
      case PlanFitSignal.maintain:
        return 'maintain';
      case PlanFitSignal.considerMoreSupport:
        return 'consider_more_support';
      case PlanFitSignal.considerLessLoad:
        return 'consider_less_load';
      case PlanFitSignal.insufficientEvidence:
        return 'insufficient_evidence';
    }
  }

  static PlanFitSignal fromWire(String? raw) {
    switch (raw) {
      case 'consider_more_support':
        return PlanFitSignal.considerMoreSupport;
      case 'consider_less_load':
        return PlanFitSignal.considerLessLoad;
      case 'insufficient_evidence':
        return PlanFitSignal.insufficientEvidence;
      case 'maintain':
      default:
        return PlanFitSignal.maintain;
    }
  }
}

enum LoadSignal {
  light,
  suitable,
  heavy,
  unknown,
}

extension LoadSignalX on LoadSignal {
  String get wireName => name;

  static LoadSignal fromWire(String? raw) {
    switch (raw) {
      case 'light':
        return LoadSignal.light;
      case 'suitable':
        return LoadSignal.suitable;
      case 'heavy':
        return LoadSignal.heavy;
      case 'unknown':
      default:
        return LoadSignal.unknown;
    }
  }
}

enum ObstacleSignal {
  time,
  forgetfulness,
  lowEnergy,
  interruptions,
  unclearStep,
  accessOrEnvironment,
  none,
  unknown,
}

extension ObstacleSignalX on ObstacleSignal {
  String get wireName {
    switch (this) {
      case ObstacleSignal.time:
        return 'time';
      case ObstacleSignal.forgetfulness:
        return 'forgetfulness';
      case ObstacleSignal.lowEnergy:
        return 'low_energy';
      case ObstacleSignal.interruptions:
        return 'interruptions';
      case ObstacleSignal.unclearStep:
        return 'unclear_step';
      case ObstacleSignal.accessOrEnvironment:
        return 'access_or_environment';
      case ObstacleSignal.none:
        return 'none';
      case ObstacleSignal.unknown:
        return 'unknown';
    }
  }

  static ObstacleSignal fromWire(String? raw) {
    switch (raw) {
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
      case 'none':
        return ObstacleSignal.none;
      case 'unknown':
      default:
        return ObstacleSignal.unknown;
    }
  }
}

enum AccessibilitySignal {
  used,
  notUsed,
  unknown,
}

extension AccessibilitySignalX on AccessibilitySignal {
  String get wireName {
    switch (this) {
      case AccessibilitySignal.used:
        return 'used';
      case AccessibilitySignal.notUsed:
        return 'not_used';
      case AccessibilitySignal.unknown:
        return 'unknown';
    }
  }

  static AccessibilitySignal fromWire(String? raw) {
    switch (raw) {
      case 'used':
        return AccessibilitySignal.used;
      case 'not_used':
        return AccessibilitySignal.notUsed;
      case 'unknown':
      default:
        return AccessibilitySignal.unknown;
    }
  }
}

enum SignalConfidence {
  low,
  moderate,
  adequateForSignal,
}

extension SignalConfidenceX on SignalConfidence {
  String get wireName {
    switch (this) {
      case SignalConfidence.low:
        return 'low';
      case SignalConfidence.moderate:
        return 'moderate';
      case SignalConfidence.adequateForSignal:
        return 'adequate_for_signal';
    }
  }

  static SignalConfidence fromWire(String? raw) {
    switch (raw) {
      case 'moderate':
        return SignalConfidence.moderate;
      case 'adequate_for_signal':
        return SignalConfidence.adequateForSignal;
      case 'low':
      default:
        return SignalConfidence.low;
    }
  }
}
