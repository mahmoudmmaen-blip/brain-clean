import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_habit_scorer.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetoxHabitScorer', () {
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

    test('detoxHabitScore returns 100 when all habits are maxed', () {
      expect(
        DetoxHabitScorer.detoxHabitScore(
          boredomBefriended: true,
          delayedGratificationCount: BcScoreConstants.maxDelayedGratificationCount,
          bodyActivated: true,
        ),
        100,
      );
    });

    test('recalculateHealthyHabits blends diagnostic and detox scores', () {
      final blended = DetoxHabitScorer.recalculateHealthyHabits(
        baseHealthyHabits: 40,
        boredomBefriended: true,
        delayedGratificationCount: 0,
        bodyActivated: false,
      );

      // 40 * 0.55 + 35 * 0.45 = 22 + 15.75 = 37.75
      expect(blended, closeTo(37.75, 0.01));
    });

    test('applyDetoxToModel updates healthyHabits and habit fields', () {
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
      expect(updated.bcScore, greaterThan(base.bcScore));
    });
  });
}
