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
  });

  group('DiagnosticModel JSON serialization', () {
    test('constructor applies default habit metric values', () {
      const model = DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      );

      expect(model.boredomBefriended, isFalse);
      expect(model.delayedGratificationCount, 0);
      expect(model.bodyActivated, isFalse);
    });

    test('round-trip preserves habit metrics via Firestore json keys', () {
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
      expect(json['brainPerformance'], 72);
      expect(json['digitalDiscipline'], 65);
      expect(json['healthyHabits'], 80);
      expect(json['consistency'], 55);
      expect(json['boredom_befriended'], isTrue);
      expect(json['delayed_gratification_count'], 4);
      expect(json['body_activated'], isTrue);
      expect(json.containsKey('boredomBefriended'), isFalse);
      expect(json.containsKey('delayedGratificationCount'), isFalse);
      expect(json.containsKey('bodyActivated'), isFalse);

      final restored = DiagnosticModel.fromJson(json);
      expect(restored.brainPerformance, model.brainPerformance);
      expect(restored.digitalDiscipline, model.digitalDiscipline);
      expect(restored.healthyHabits, model.healthyHabits);
      expect(restored.consistency, model.consistency);
      expect(restored.boredomBefriended, model.boredomBefriended);
      expect(restored.delayedGratificationCount, model.delayedGratificationCount);
      expect(restored.bodyActivated, model.bodyActivated);
      expect(restored.calculateBcScore(), model.calculateBcScore());
    });

    test('fromJson applies defaults when Firestore habit keys are missing', () {
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

    test('fromJson reads Firestore snake_case keys into camelCase fields', () {
      final restored = DiagnosticModel.fromJson({
        'brainPerformance': 60.0,
        'digitalDiscipline': 60.0,
        'healthyHabits': 60.0,
        'consistency': 60.0,
        'boredom_befriended': true,
        'delayed_gratification_count': 7,
        'body_activated': true,
      });

      expect(restored.boredomBefriended, isTrue);
      expect(restored.delayedGratificationCount, 7);
      expect(restored.bodyActivated, isTrue);
    });

    test('toJson writes Firestore snake_case keys for default habit values', () {
      const model = DiagnosticModel(
        brainPerformance: 60,
        digitalDiscipline: 60,
        healthyHabits: 60,
        consistency: 60,
      );

      final json = model.toJson();
      expect(json.containsKey('boredom_befriended'), isTrue);
      expect(json.containsKey('delayed_gratification_count'), isTrue);
      expect(json.containsKey('body_activated'), isTrue);
      expect(json['boredom_befriended'], isFalse);
      expect(json['delayed_gratification_count'], 0);
      expect(json['body_activated'], isFalse);

      final restored = DiagnosticModel.fromJson(json);
      expect(restored.boredomBefriended, isFalse);
      expect(restored.delayedGratificationCount, 0);
      expect(restored.bodyActivated, isFalse);
    });
  });
}
