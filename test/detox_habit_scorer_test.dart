import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_habit_scorer.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetoxHabitScorer — Habits pillar sub-components', () {
    test('boredomSilenceSubScore gives full marks when silence challenge done', () {
      expect(DetoxHabitScorer.boredomSilenceSubScore(true), 100);
      expect(DetoxHabitScorer.boredomSilenceSubScore(false), 0);
    });

    test('bodyActivationSubScore gives full marks when sun and shower done', () {
      expect(DetoxHabitScorer.bodyActivationSubScore(true), 100);
      expect(DetoxHabitScorer.bodyActivationSubScore(false), 0);
    });

    test('delayedGratificationSubScore applies per-win bonus up to ceiling', () {
      expect(DetoxHabitScorer.delayedGratificationSubScore(0), 0);
      expect(
        DetoxHabitScorer.delayedGratificationSubScore(1),
        closeTo(BcScoreConstants.habitsDelayedGratificationBonusPerWin, 0.01),
      );
      expect(DetoxHabitScorer.delayedGratificationSubScore(7), 100);
      expect(DetoxHabitScorer.delayedGratificationSubScore(99), 100);
    });

    test('detoxHabitScore returns 0 when all habits are inactive', () {
      expect(
        DetoxHabitScorer.detoxHabitScore(
          boredomBefriended: false,
          delayedGratificationCount: 0,
          bodyActivated: false,
        ),
        0,
      );
    });

    test('detoxHabitScore returns 100 when all sub-components are maxed', () {
      expect(
        DetoxHabitScorer.detoxHabitScore(
          boredomBefriended: true,
          delayedGratificationCount: BcScoreConstants.maxDelayedGratificationCount,
          bodyActivated: true,
        ),
        100,
      );
    });

    test('recalculateHealthyHabits blends diagnostic baseline with detox score', () {
      final blended = DetoxHabitScorer.recalculateHealthyHabits(
        baseHealthyHabits: 40,
        boredomBefriended: true,
        delayedGratificationCount: 0,
        bodyActivated: false,
      );

      // detox = 100 * 0.35 = 35; blend = 40*0.40 + 35*0.60 = 16 + 21 = 37
      expect(blended, closeTo(37.0, 0.01));
    });

    test('habitsPillarContribution scales to 25% BHI boundary', () {
      expect(
        DetoxHabitScorer.habitsPillarContribution(80),
        closeTo(20.0, 0.01),
      );
      expect(
        DetoxHabitScorer.habitsPillarContribution(100),
        BcScoreConstants.healthyHabitsWeight * 100,
      );
    });

    test('applyDetoxToModel raises BC_score and respects 26.8 floor', () {
      const base = DiagnosticModel(
        brainPerformance: 70,
        digitalDiscipline: 60,
        healthyHabits: 50,
        consistency: 55,
      );

      final updated = DetoxHabitScorer.applyDetoxToModel(
        base,
        boredomBefriended: true,
        delayedGratificationCount: 7,
        bodyActivated: true,
      );

      expect(updated.boredomBefriended, isTrue);
      expect(updated.delayedGratificationCount, 7);
      expect(updated.bodyActivated, isTrue);
      expect(updated.healthyHabits, greaterThan(base.healthyHabits));
      expect(updated.habitsPillarContribution, greaterThan(base.habitsPillarContribution));
      expect(updated.bcScore, greaterThan(base.bcScore));
      expect(updated.bcScore, greaterThanOrEqualTo(BcScoreConstants.bhiScoreFloor));

      const lowBase = DiagnosticModel(
        brainPerformance: 0,
        digitalDiscipline: 0,
        healthyHabits: 0,
        consistency: 0,
      );
      final lowUpdated = DetoxHabitScorer.applyDetoxToModel(
        lowBase,
        boredomBefriended: false,
        delayedGratificationCount: 0,
        bodyActivated: false,
      );
      expect(lowUpdated.bcScore, BcScoreConstants.bhiScoreFloor);
    });
  });
}
