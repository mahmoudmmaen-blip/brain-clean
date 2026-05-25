import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimum BHI pillar payload required by [DiagnosticModel.fromJson].
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

void _expectHabitDefaults(DiagnosticModel model) {
  expect(model.boredomBefriended, isFalse);
  expect(model.delayedGratificationCount, 0);
  expect(model.bodyActivated, isFalse);
}

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

  // ---------------------------------------------------------------------------
  // Test Suite A — Firestore snake_case validation
  // ---------------------------------------------------------------------------
  group('Test Suite A — Firestore snake_case validation', () {
    test('parses boredom_befriended, delayed_gratification_count, body_activated', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(brainPerformance: 72, digitalDiscipline: 65),
        DiagnosticModelJsonKeys.boredomBefriendedSnake: true,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake: 6,
        DiagnosticModelJsonKeys.bodyActivatedSnake: true,
      });

      expect(model.boredomBefriended, isTrue);
      expect(model.delayedGratificationCount, 6);
      expect(model.bodyActivated, isTrue);
    });

    test('toJson emits Firestore snake_case habit keys', () {
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
    });

    test('snake_case round-trip preserves habit values', () {
      final firestoreDoc = {
        ..._pillarJson(),
        DiagnosticModelJsonKeys.boredomBefriendedSnake: true,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake: 4,
        DiagnosticModelJsonKeys.bodyActivatedSnake: false,
      };

      final roundTripped = DiagnosticModel.fromJson(
        DiagnosticModel.fromJson(firestoreDoc).toJson(),
      );

      expect(roundTripped.boredomBefriended, isTrue);
      expect(roundTripped.delayedGratificationCount, 4);
      expect(roundTripped.bodyActivated, isFalse);
    });

    test('snake_case takes precedence when both casings are present', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        DiagnosticModelJsonKeys.boredomBefriendedSnake: false,
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake: 2,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 9,
        DiagnosticModelJsonKeys.bodyActivatedSnake: true,
        DiagnosticModelJsonKeys.bodyActivatedCamel: false,
      });

      expect(model.boredomBefriended, isFalse);
      expect(model.delayedGratificationCount, 2);
      expect(model.bodyActivated, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Test Suite B — Local camelCase validation
  // ---------------------------------------------------------------------------
  group('Test Suite B — Local camelCase validation', () {
    test('parses boredomBefriended, delayedGratificationCount, bodyActivated', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 8,
        DiagnosticModelJsonKeys.bodyActivatedCamel: true,
      });

      expect(model.boredomBefriended, isTrue);
      expect(model.delayedGratificationCount, 8);
      expect(model.bodyActivated, isTrue);
    });

    test('camelCase-only input normalizes to snake_case on toJson', () {
      final localJson = {
        ..._pillarJson(brainPerformance: 68),
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 3,
        DiagnosticModelJsonKeys.bodyActivatedCamel: false,
      };

      final encoded = DiagnosticModel.fromJson(localJson).toJson();

      expect(encoded.containsKey(DiagnosticModelJsonKeys.boredomBefriendedSnake), isTrue);
      expect(encoded.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel), isFalse);
      expect(encoded[DiagnosticModelJsonKeys.boredomBefriendedSnake], isTrue);
      expect(encoded[DiagnosticModelJsonKeys.delayedGratificationCountSnake], 3);
      expect(encoded[DiagnosticModelJsonKeys.bodyActivatedSnake], isFalse);
    });

    test('camelCase round-trip via toJson preserves habit values', () {
      final localJson = {
        ..._pillarJson(),
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 5,
        DiagnosticModelJsonKeys.bodyActivatedCamel: true,
      };

      final roundTripped = DiagnosticModel.fromJson(
        DiagnosticModel.fromJson(localJson).toJson(),
      );

      expect(roundTripped.boredomBefriended, isTrue);
      expect(roundTripped.delayedGratificationCount, 5);
      expect(roundTripped.bodyActivated, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Test Suite C — Missing keys / default fallback validation
  // ---------------------------------------------------------------------------
  group('Test Suite C — Missing keys / default fallback validation', () {
    test('constructor initializes habit fields to defaults', () {
      const model = DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      );
      _expectHabitDefaults(model);
    });

    test('fromJson applies defaults when habit keys are completely absent', () {
      final model = DiagnosticModel.fromJson(_pillarJson());
      _expectHabitDefaults(model);
    });

    test('fromJson applies defaults when only pillar keys are present', () {
      final model = DiagnosticModel.fromJson({
        'brainPerformance': 40.0,
        'digitalDiscipline': 40.0,
        'healthyHabits': 40.0,
        'consistency': 40.0,
      });
      _expectHabitDefaults(model);
    });

    test('toJson with default habits round-trips to same defaults', () {
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

      _expectHabitDefaults(DiagnosticModel.fromJson(json));
    });
  });
}
