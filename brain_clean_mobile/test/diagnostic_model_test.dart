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

Map<String, dynamic> _habitJsonSnake({
  bool boredomBefriended = false,
  int delayedGratificationCount = 0,
  bool bodyActivated = false,
}) =>
    {
      DiagnosticModelJsonKeys.boredomBefriendedSnake: boredomBefriended,
      DiagnosticModelJsonKeys.delayedGratificationCountSnake:
          delayedGratificationCount,
      DiagnosticModelJsonKeys.bodyActivatedSnake: bodyActivated,
    };

Map<String, dynamic> _habitJsonCamel({
  bool boredomBefriended = false,
  int delayedGratificationCount = 0,
  bool bodyActivated = false,
}) =>
    {
      DiagnosticModelJsonKeys.boredomBefriendedCamel: boredomBefriended,
      DiagnosticModelJsonKeys.delayedGratificationCountCamel:
          delayedGratificationCount,
      DiagnosticModelJsonKeys.bodyActivatedCamel: bodyActivated,
    };

void _expectHabitDefaults(DiagnosticModel model) {
  expect(model.boredomBefriended, isFalse);
  expect(model.delayedGratificationCount, 0);
  expect(model.bodyActivated, isFalse);
}

void _expectHabitValues(
  DiagnosticModel model, {
  required bool boredomBefriended,
  required int delayedGratificationCount,
  required bool bodyActivated,
}) {
  expect(model.boredomBefriended, boredomBefriended);
  expect(model.delayedGratificationCount, delayedGratificationCount);
  expect(model.bodyActivated, bodyActivated);
}

void _expectSnakeCaseHabitKeys(
  Map<String, dynamic> json, {
  required bool boredomBefriended,
  required int delayedGratificationCount,
  required bool bodyActivated,
}) {
  expect(json[DiagnosticModelJsonKeys.boredomBefriendedSnake], boredomBefriended);
  expect(
    json[DiagnosticModelJsonKeys.delayedGratificationCountSnake],
    delayedGratificationCount,
  );
  expect(json[DiagnosticModelJsonKeys.bodyActivatedSnake], bodyActivated);
  expect(json.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel), isFalse);
  expect(json.containsKey(DiagnosticModelJsonKeys.delayedGratificationCountCamel), isFalse);
  expect(json.containsKey(DiagnosticModelJsonKeys.bodyActivatedCamel), isFalse);
}

DiagnosticModel _roundTrip(DiagnosticModel model) =>
    DiagnosticModel.fromJson(model.toJson());

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

  group('Test Suite A — Firestore snake_case validation', () {
    test('parses snake_case habit keys into model fields', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(brainPerformance: 72, digitalDiscipline: 65),
        ..._habitJsonSnake(
          boredomBefriended: true,
          delayedGratificationCount: 6,
          bodyActivated: true,
        ),
      });

      _expectHabitValues(
        model,
        boredomBefriended: true,
        delayedGratificationCount: 6,
        bodyActivated: true,
      );
    });

    test('toJson emits snake_case keys only', () {
      const model = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 65,
        healthyHabits: 80,
        consistency: 55,
        boredomBefriended: true,
        delayedGratificationCount: 4,
        bodyActivated: true,
      );

      _expectSnakeCaseHabitKeys(
        model.toJson(),
        boredomBefriended: true,
        delayedGratificationCount: 4,
        bodyActivated: true,
      );
    });

    test('round-trip preserves snake_case habit values', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        ..._habitJsonSnake(
          boredomBefriended: true,
          delayedGratificationCount: 4,
          bodyActivated: false,
        ),
      });

      _expectHabitValues(
        _roundTrip(model),
        boredomBefriended: true,
        delayedGratificationCount: 4,
        bodyActivated: false,
      );
    });

    test('snake_case takes precedence when both casings are present', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        ..._habitJsonSnake(
          boredomBefriended: false,
          delayedGratificationCount: 2,
          bodyActivated: true,
        ),
        ..._habitJsonCamel(
          boredomBefriended: true,
          delayedGratificationCount: 9,
          bodyActivated: false,
        ),
      });

      _expectHabitValues(
        model,
        boredomBefriended: false,
        delayedGratificationCount: 2,
        bodyActivated: true,
      );
    });
  });

  group('Test Suite B — Local camelCase validation', () {
    test('parses camelCase habit keys when snake_case is absent', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        ..._habitJsonCamel(
          boredomBefriended: true,
          delayedGratificationCount: 8,
          bodyActivated: true,
        ),
      });

      _expectHabitValues(
        model,
        boredomBefriended: true,
        delayedGratificationCount: 8,
        bodyActivated: true,
      );
    });

    test('camelCase input normalizes to snake_case on toJson', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(brainPerformance: 68),
        ..._habitJsonCamel(
          boredomBefriended: true,
          delayedGratificationCount: 3,
          bodyActivated: false,
        ),
      });

      _expectSnakeCaseHabitKeys(
        model.toJson(),
        boredomBefriended: true,
        delayedGratificationCount: 3,
        bodyActivated: false,
      );
    });

    test('round-trip preserves habit values after snake_case normalization', () {
      final model = DiagnosticModel.fromJson({
        ..._pillarJson(),
        ..._habitJsonCamel(
          boredomBefriended: true,
          delayedGratificationCount: 5,
          bodyActivated: true,
        ),
      });

      _expectHabitValues(
        _roundTrip(model),
        boredomBefriended: true,
        delayedGratificationCount: 5,
        bodyActivated: true,
      );
    });
  });

  group('Test Suite C — Missing keys / default fallback validation', () {
    test('constructor and fromJson apply habit defaults when keys are absent', () {
      const fromConstructor = DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      );
      _expectHabitDefaults(fromConstructor);
      _expectHabitDefaults(DiagnosticModel.fromJson(_pillarJson()));
    });

    test('toJson default habits round-trip to the same defaults', () {
      const model = DiagnosticModel(
        brainPerformance: 60,
        digitalDiscipline: 60,
        healthyHabits: 60,
        consistency: 60,
      );

      final json = model.toJson();
      _expectSnakeCaseHabitKeys(
        json,
        boredomBefriended: false,
        delayedGratificationCount: 0,
        bodyActivated: false,
      );
      _expectHabitDefaults(DiagnosticModel.fromJson(json));
    });
  });
}
