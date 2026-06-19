import '../../../core/constants/bc_score_constants.dart';
import '../../diagnostic/domain/diagnostic_model.dart';

/// Composes the Habits pillar (25% BHI weight) from detox protocol check-ins.
abstract final class DetoxHabitScorer {
  /// 10-minute silence challenge — full sub-component marks when completed.
  static double boredomSilenceSubScore(bool boredomBefriended) =>
      boredomBefriended ? BcScoreConstants.habitsSubComponentFullScore : 0.0;

  /// Morning sun + cold shower — full sub-component marks when completed.
  static double bodyActivationSubScore(bool bodyActivated) =>
      bodyActivated ? BcScoreConstants.habitsSubComponentFullScore : 0.0;

  /// Dynamic bonus per delayed-gratification win, capped at protocol ceiling.
  static double delayedGratificationSubScore(int delayedGratificationCount) {
    final capped = delayedGratificationCount.clamp(
      0,
      BcScoreConstants.maxDelayedGratificationCount,
    );
    final bonus = capped * BcScoreConstants.habitsDelayedGratificationBonusPerWin;
    return bonus.clamp(0.0, BcScoreConstants.habitsDelayedGratificationCeiling);
  }

  /// Weighted detox habit score (0–100) from the three protocol sub-components.
  static double detoxHabitScore({
    required bool boredomBefriended,
    required int delayedGratificationCount,
    required bool bodyActivated,
  }) {
    final boredom = boredomSilenceSubScore(boredomBefriended);
    final delayed = delayedGratificationSubScore(delayedGratificationCount);
    final body = bodyActivationSubScore(bodyActivated);

    return (boredom * BcScoreConstants.habitsBoredomSilenceSubWeight +
            delayed * BcScoreConstants.habitsDelayedGratificationSubWeight +
            body * BcScoreConstants.habitsBodyActivationSubWeight)
        .clamp(0.0, 100.0);
  }

  /// Smoothly blends diagnostic baseline with detox protocol into Habits pillar (0–100).
  static double recalculateHealthyHabits({
    required double baseHealthyHabits,
    required bool boredomBefriended,
    required int delayedGratificationCount,
    required bool bodyActivated,
  }) {
    final detoxScore = detoxHabitScore(
      boredomBefriended: boredomBefriended,
      delayedGratificationCount: delayedGratificationCount,
      bodyActivated: bodyActivated,
    );

    return (baseHealthyHabits * BcScoreConstants.diagnosticHabitBaselineWeight +
            detoxScore * BcScoreConstants.detoxProtocolHabitWeight)
        .clamp(0.0, 100.0);
  }

  /// Habits pillar contribution toward total BHI (scaled to 25% boundary).
  static double habitsPillarContribution(double healthyHabitsPillarScore) =>
      healthyHabitsPillarScore * BcScoreConstants.healthyHabitsWeight;

  /// Returns a [DiagnosticModel] with detox fields applied and habits pillar updated.
  static DiagnosticModel applyDetoxToModel(
    DiagnosticModel base, {
    required bool boredomBefriended,
    required int delayedGratificationCount,
    required bool bodyActivated,
  }) {
    return DiagnosticModel(
      brainPerformance: base.brainPerformance,
      digitalDiscipline: base.digitalDiscipline,
      healthyHabits: recalculateHealthyHabits(
        baseHealthyHabits: base.healthyHabits,
        boredomBefriended: boredomBefriended,
        delayedGratificationCount: delayedGratificationCount,
        bodyActivated: bodyActivated,
      ),
      consistency: base.consistency,
      boredomBefriended: boredomBefriended,
      delayedGratificationCount: delayedGratificationCount,
      bodyActivated: bodyActivated,
    );
  }
}
