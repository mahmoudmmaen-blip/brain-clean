import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared pillar payload for habit JSON tests.
Map<String, dynamic> _pillarJson({
  double brainPerformance = 50,
  double digitalDiscipline = 50,
  double healthyHabits = 50,
  double consistency = 50,
}) =>
    {
      'brainPerformance': brainPerformance,
      'digitalDiscipline': digitalDiscipline,
      'healthyHabits': healthyHabits,
      'consistency': consistency,
    };

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

  group('DiagnosticModel JSON serialization validation', () {
    test('parses strictly Firestore snake_case habit keys', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        'boredom_befriended': true,
        'delayed_gratification_count': 6,
        'body_activated': true,
      });

      expect(model.boredomBefriended, isTrue);
      expect(model.delayedGratificationCount, 6);
      expect(model.bodyActivated, isTrue);
    });

    test('parses strictly camelCase habit keys', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        'boredomBefriended': true,
        'delayedGratificationCount': 8,
        'bodyActivated': true,
      });

      expect(model.boredomBefriended, isTrue);
      expect(model.delayedGratificationCount, 8);
      expect(model.bodyActivated, isTrue);
    });

    test('applies default values when habit metric keys are absent', () {
      final model = DiagnosticModel.fromJson(_pillarJson());

      expect(model.boredomBefriended, isFalse);
      expect(model.delayedGratificationCount, 0);
      expect(model.bodyActivated, isFalse);
    });
  });

  group('DiagnosticModel habit defaults', () {
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
  });

  group('DiagnosticModel extended JSON edge cases', () {
    test('fromJson reads snake_case habit keys via key constants', () {
      final restored = DiagnosticModel.fromJson({
        ..._pillarJson(brainPerformance: 60),
        DiagnosticModelJsonKeys.boredomBefriendedSnake: true,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake: 7,
        DiagnosticModelJsonKeys.bodyActivatedSnake: true,
      });

      expect(restored.boredomBefriended, isTrue);
      expect(restored.delayedGratificationCount, 7);
      expect(restored.bodyActivated, isTrue);
    });

    test('toJson writes snake_case habit keys only', () {
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
      expect(json[DiagnosticModelJsonKeys.boredomBefriendedSnake], isTrue);
      expect(json[DiagnosticModelJsonKeys.delayedGratificationCountSnake], 4);
      expect(json[DiagnosticModelJsonKeys.bodyActivatedSnake], isTrue);
      expect(json.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel), isFalse);
      expect(json.containsKey(DiagnosticModelJsonKeys.delayedGratificationCountCamel), isFalse);
      expect(json.containsKey(DiagnosticModelJsonKeys.bodyActivatedCamel), isFalse);
    });

    test('Firestore document round-trip preserves snake_case habit keys', () {
      final firestoreDoc = {
        ..._pillarJson(
          brainPerformance: 72,
          digitalDiscipline: 65,
          healthyHabits: 80,
          consistency: 55,
        ),
        DiagnosticModelJsonKeys.boredomBefriendedSnake: true,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake: 4,
        DiagnosticModelJsonKeys.bodyActivatedSnake: true,
      };

      final encoded = DiagnosticModel.fromJson(firestoreDoc).toJson();

      expect(
        encoded[DiagnosticModelJsonKeys.boredomBefriendedSnake],
        firestoreDoc[DiagnosticModelJsonKeys.boredomBefriendedSnake],
      );
      expect(
        encoded[DiagnosticModelJsonKeys.delayedGratificationCountSnake],
        firestoreDoc[DiagnosticModelJsonKeys.delayedGratificationCountSnake],
      );
      expect(
        encoded[DiagnosticModelJsonKeys.bodyActivatedSnake],
        firestoreDoc[DiagnosticModelJsonKeys.bodyActivatedSnake],
      );

      final roundTripped = DiagnosticModel.fromJson(encoded);
      expect(roundTripped.boredomBefriended, isTrue);
      expect(roundTripped.delayedGratificationCount, 4);
      expect(roundTripped.bodyActivated, isTrue);
    });

    test('toJson writes snake_case keys for default habit values', () {
      const model = DiagnosticModel(
        brainPerformance: 60,
        digitalDiscipline: 60,
        healthyHabits: 60,
        consistency: 60,
      );

      final json = model.toJson();
      expect(json[DiagnosticModelJsonKeys.boredomBefriendedSnake], isFalse);
      expect(json[DiagnosticModelJsonKeys.delayedGratificationCountSnake], 0);
      expect(json[DiagnosticModelJsonKeys.bodyActivatedSnake], isFalse);

      final restored = DiagnosticModel.fromJson(json);
      expect(restored.boredomBefriended, isFalse);
      expect(restored.delayedGratificationCount, 0);
      expect(restored.bodyActivated, isFalse);
    });
  });

  group('DiagnosticModel camelCase JSON backwards compatibility', () {
    test('fromJson reads camelCase habit keys when snake_case is absent', () {
      final restored = DiagnosticModel.fromJson({
        ..._pillarJson(),
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 5,
        DiagnosticModelJsonKeys.bodyActivatedCamel: true,
      });

      expect(restored.boredomBefriended, isTrue);
      expect(restored.delayedGratificationCount, 5);
      expect(restored.bodyActivated, isTrue);
    });

    test('camelCase-only map round-trip via toJson normalizes to snake_case', () {
      final localJson = {
        ..._pillarJson(brainPerformance: 68),
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 3,
        DiagnosticModelJsonKeys.bodyActivatedCamel: false,
      };

      final model = DiagnosticModel.fromJson(localJson);
      final encoded = model.toJson();

      expect(encoded.containsKey(DiagnosticModelJsonKeys.boredomBefriendedSnake), isTrue);
      expect(encoded.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel), isFalse);
      expect(encoded[DiagnosticModelJsonKeys.boredomBefriendedSnake], isTrue);
      expect(encoded[DiagnosticModelJsonKeys.delayedGratificationCountSnake], 3);
      expect(encoded[DiagnosticModelJsonKeys.bodyActivatedSnake], isFalse);

      final roundTripped = DiagnosticModel.fromJson(encoded);
      expect(roundTripped.boredomBefriended, isTrue);
      expect(roundTripped.delayedGratificationCount, 3);
      expect(roundTripped.bodyActivated, isFalse);
    });

    test('snake_case takes precedence when both casings are present', () {
      final restored = DiagnosticModel.fromJson({
        ..._pillarJson(),
        DiagnosticModelJsonKeys.boredomBefriendedSnake: false,
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake: 2,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 9,
        DiagnosticModelJsonKeys.bodyActivatedSnake: true,
        DiagnosticModelJsonKeys.bodyActivatedCamel: false,
      });

      expect(restored.boredomBefriended, isFalse);
      expect(restored.delayedGratificationCount, 2);
      expect(restored.bodyActivated, isTrue);
    });
  });
}
