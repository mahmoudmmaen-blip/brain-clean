import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiagnosticModel.calculateBcScore', () {
    test('applies weighted pillars correctly at maximum', () {
      const model = DiagnosticModel(
        brainPerformance: 100,
        digitalDiscipline: 100,
        healthyHabits: 100,
        consistency: 100,
      );
      expect(model.calculateBcScore(), 100);
    });

    test('enforces 26.8 floor for low scores', () {
      const model = DiagnosticModel(
        brainPerformance: 0,
        digitalDiscipline: 0,
        healthyHabits: 0,
        consistency: 0,
      );
      expect(model.calculateBcScore(), BcScoreConstants.bhiScoreFloor);
    });

    test('json round-trip preserves detox habit metrics', () {
      const model = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 65,
        healthyHabits: 80,
        consistency: 55,
        boredomBefriended: true,
        delayedGratificationCount: 4,
        bodyActivated: true,
      );
      final json = model.toJson();
      expect(json['boredom_befriended'], isTrue);
      expect(json['delayed_gratification_count'], 4);
      expect(json['body_activated'], isTrue);

      final restored = DiagnosticModel.fromJson(json);
      expect(restored.boredomBefriended, isTrue);
      expect(restored.delayedGratificationCount, 4);
      expect(restored.bodyActivated, isTrue);
      expect(restored.calculateBcScore(), model.calculateBcScore());
    });

    test('json defaults detox habits when keys are absent', () {
      final restored = DiagnosticModel.fromJson({
        'brainPerformance': 50.0,
        'digitalDiscipline': 50.0,
        'healthyHabits': 50.0,
        'consistency': 50.0,
      });
      expect(restored.boredomBefriended, isFalse);
      expect(restored.delayedGratificationCount, 0);
      expect(restored.bodyActivated, isFalse);
    });
  });
}
