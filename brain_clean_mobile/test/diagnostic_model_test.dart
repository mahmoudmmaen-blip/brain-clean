import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> pillarJson({
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

Map<String, dynamic> habitJsonSnake({
  bool? boredom,
  int? delayed,
  bool? body,
}) {
  final json = <String, dynamic>{};
  if (boredom != null) {
    json[DiagnosticModelJsonKeys.boredomBefriendedSnake] = boredom;
  }
  if (delayed != null) {
    json[DiagnosticModelJsonKeys.delayedGratificationCountSnake] = delayed;
  }
  if (body != null) {
    json[DiagnosticModelJsonKeys.bodyActivatedSnake] = body;
  }
  return json;
}

Map<String, dynamic> habitJsonCamel({
  bool? boredom,
  int? delayed,
  bool? body,
}) {
  final json = <String, dynamic>{};
  if (boredom != null) {
    json[DiagnosticModelJsonKeys.boredomBefriendedCamel] = boredom;
  }
  if (delayed != null) {
    json[DiagnosticModelJsonKeys.delayedGratificationCountCamel] = delayed;
  }
  if (body != null) {
    json[DiagnosticModelJsonKeys.bodyActivatedCamel] = body;
  }
  return json;
}

void expectHabitMetrics(
  DiagnosticModel model, {
  bool? boredom,
  int? delayed,
  bool? body,
}) {
  expect(model.boredomBefriended, boredom ?? false);
  expect(model.delayedGratificationCount, delayed ?? 0);
  expect(model.bodyActivated, body ?? false);
}

DiagnosticModel parseModel(Map<String, dynamic> json) =>
    DiagnosticModel.fromJson(json);

DiagnosticModel roundTrip(DiagnosticModel model) =>
    DiagnosticModel.fromJson(model.toJson());

void main() {
  group('BrainRotTest (Dr. Moneam protocol)', () {
    test('exposes 10 Arabic questions', () {
      expect(BrainRotTest.questionsAr, hasLength(10));
      expect(DiagnosticModel.brainRotQuestionsAr, BrainRotTest.questionsAr);
    });

    test('calculateScore sums affirmative answers', () {
      expect(
        BrainRotTest.calculateScore(List<bool>.filled(10, false)),
        0,
      );
      expect(
        BrainRotTest.calculateScore(List<bool>.filled(10, true)),
        10,
      );
      expect(
        DiagnosticModel.calculateBrainRotScore([
          true,
          true,
          false,
          false,
          true,
          false,
          false,
          false,
          false,
          false,
        ]),
        3,
      );
    });

    test('calculateScore requires exactly 10 answers', () {
      expect(
        () => BrainRotTest.calculateScore([true, false]),
        throwsArgumentError,
      );
    });

    test('interpretScore returns correct Arabic bands', () {
      expect(BrainRotTest.interpretScore(0), contains('خفيف'));
      expect(BrainRotTest.interpretScore(2), contains('خفيف'));
      expect(BrainRotTest.interpretScore(3), contains('بداية تعفن'));
      expect(BrainRotTest.interpretScore(5), contains('بداية تعفن'));
      expect(BrainRotTest.interpretScore(6), contains('واضح'));
      expect(BrainRotTest.interpretScore(8), contains('واضح'));
      expect(BrainRotTest.interpretScore(9), contains('شديد'));
      expect(BrainRotTest.interpretScore(10), contains('شديد'));
      expect(
        DiagnosticModel.interpretBrainRotScore(7),
        BrainRotTest.interpretScore(7),
      );
    });
  });

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

  group('DiagnosticModel habit metrics', () {
    test('parses Firestore snake_case keys', () {
      final model = parseModel({
        ...pillarJson(brainPerformance: 72, digitalDiscipline: 65),
        ...habitJsonSnake(boredom: true, delayed: 6, body: true),
      });

      expectHabitMetrics(model, boredom: true, delayed: 6, body: true);
    });

    test('falls back to camelCase keys when snake_case is absent', () {
      final model = parseModel({
        ...pillarJson(),
        ...habitJsonCamel(boredom: true, delayed: 8, body: true),
      });

      expectHabitMetrics(model, boredom: true, delayed: 8, body: true);
    });

    // Logic Verification: Firestore snake_case keys are strictly prioritized over local camelCase keys when both are present in the JSON payload.
    test(
      'Verifies that Firestore snake_case keys are strictly prioritized over '
      'local camelCase keys when both are present in the JSON payload.',
      () {
        final model = parseModel({
          ...pillarJson(),
          ...habitJsonSnake(boredom: false, delayed: 2, body: true),
          ...habitJsonCamel(boredom: true, delayed: 9, body: false),
        });

        expectHabitMetrics(model, boredom: false, delayed: 2, body: true);
      },
    );

    test('missing keys default to false, 0, false', () {
      expectHabitMetrics(parseModel(pillarJson()));
      expectHabitMetrics(
        const DiagnosticModel(
          brainPerformance: 50,
          digitalDiscipline: 50,
          healthyHabits: 50,
          consistency: 50,
        ),
      );
    });

    test('toJson emits snake_case keys and round-trip preserves values', () {
      const model = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 65,
        healthyHabits: 80,
        consistency: 55,
        boredomBefriended: true,
        delayedGratificationCount: 4,
        bodyActivated: false,
      );

      final json = model.toJson();
      expect(json[DiagnosticModelJsonKeys.boredomBefriendedSnake], isTrue);
      expect(json[DiagnosticModelJsonKeys.delayedGratificationCountSnake], 4);
      expect(json[DiagnosticModelJsonKeys.bodyActivatedSnake], isFalse);
      expect(
        json.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel),
        isFalse,
      );

      expectHabitMetrics(roundTrip(model), boredom: true, delayed: 4, body: false);
    });

    test('camelCase input normalizes to snake_case on export', () {
      final model = parseModel({
        ...pillarJson(brainPerformance: 68),
        ...habitJsonCamel(boredom: true, delayed: 3, body: false),
      });

      final json = model.toJson();
      expect(json[DiagnosticModelJsonKeys.boredomBefriendedSnake], isTrue);
      expect(json[DiagnosticModelJsonKeys.delayedGratificationCountSnake], 3);
      expect(json[DiagnosticModelJsonKeys.bodyActivatedSnake], isFalse);

      expectHabitMetrics(roundTrip(model), boredom: true, delayed: 3, body: false);
    });
  });
}
