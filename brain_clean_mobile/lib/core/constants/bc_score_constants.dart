/// Neuro-scientific bounds and BHI weights for BC_score calculation.
abstract final class BcScoreConstants {
  // Legacy 6-point engine (raw formula normalization)
  static const double positiveWeight = 1.5;
  static const double negativeWeight = 0.8;
  static const double minRaw = -29.0;
  static const double maxRaw = 26.8;
  static const double rawSpan = maxRaw - minRaw;

  static const int metricMin = 1;
  static const int metricMax = 10;

  // BHI pillar weights (DiagnosticModel) — must sum to 1.0
  static const double brainPerformanceWeight = 0.35;
  static const double digitalDisciplineWeight = 0.30;

  /// Habits pillar holds 25% of total BHI / BC_score.
  static const double healthyHabitsWeight = 0.25;

  static const double consistencyWeight = 0.10;

  /// Minimum BC_score floor for behavioral gradient stability.
  static const double bhiScoreFloor = 26.8;

  // ---------------------------------------------------------------------------
  // 7-Day Dopamine Detox Protocol → Habits pillar (25% BHI slot)
  // ---------------------------------------------------------------------------
  static const int detoxProtocolDayCount = 7;

  /// Maximum delayed-gratification wins counted toward the bonus ceiling.
  static const int maxDelayedGratificationCount = 7;

  /// Sub-component share inside the detox habit score (sums to 1.0).
  /// 10-minute silence challenge (`boredom_befriended`).
  static const double habitsBoredomSilenceSubWeight = 0.35;

  /// Dynamic delayed-gratification bonus (`delayed_gratification_count`).
  static const double habitsDelayedGratificationSubWeight = 0.30;

  /// Morning sun + cold shower (`body_activated`).
  static const double habitsBodyActivationSubWeight = 0.35;

  /// Full sub-component score when a daily bool habit is completed.
  static const double habitsSubComponentFullScore = 100.0;

  /// Per-win bonus points inside the delayed-gratification sub-component.
  static const double habitsDelayedGratificationBonusPerWin =
      habitsSubComponentFullScore / maxDelayedGratificationCount;

  /// Ceiling for the delayed-gratification sub-component (0–100).
  static const double habitsDelayedGratificationCeiling =
      habitsSubComponentFullScore;

  /// Blend: diagnostic slider habits vs live detox protocol habits.
  static const double diagnosticHabitBaselineWeight = 0.40;
  static const double detoxProtocolHabitWeight = 0.60;
}
