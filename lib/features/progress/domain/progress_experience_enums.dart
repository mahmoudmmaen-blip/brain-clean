/// Deterministic proof headline keys for PRG-01 (localized in UI).
enum ProgressProofHeadline {
  empty,
  firstSession,
  fewDays,
  rhythmBeginning,
  steadierPattern,
  limitedHistory,
  weeklyEvidenceAvailable,
}

/// Observed evidence depth for Progress (session-count based; not medical).
enum ProgressEvidenceDepth {
  empty,
  limited,
  developing,
  sufficient,
}

/// Weekly Review card state on Progress.
enum ProgressWeeklyReviewCardState {
  notEnoughActivity,
  currentWeekInProgress,
  available,
  draftInProgress,
  completed,
  summaryAvailable,
  unsupportedVersion,
  missingReferences,
  error,
}

/// Primary next destination from PRG-01 (Build Spec: one Next CTA).
enum ProgressNextDestination {
  today,
  weeklyReviewQuestions,
  weeklyReviewSummary,
  none,
}
