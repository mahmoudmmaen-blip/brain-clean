import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/bhi_pillar_frozen_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/pillar_bound_evaluation.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_assessment.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_bhi_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
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

    test('getBand and interpretScore map all scores to four protocol bands', () {
      const expectedBands = <int, InterpretationBand>{
        0: InterpretationBand.mild,
        1: InterpretationBand.mild,
        2: InterpretationBand.mild,
        3: InterpretationBand.moderate,
        4: InterpretationBand.moderate,
        5: InterpretationBand.moderate,
        6: InterpretationBand.severe,
        7: InterpretationBand.severe,
        8: InterpretationBand.severe,
        9: InterpretationBand.critical,
        10: InterpretationBand.critical,
      };

      for (final entry in expectedBands.entries) {
        expect(BrainRotTest.getBand(entry.key), entry.value);
        expect(
          BrainRotTest.interpretScore(entry.key),
          BrainRotTest.interpretationLabelsAr[entry.value],
        );
        expect(
          DiagnosticModel.interpretBrainRotScore(entry.key),
          BrainRotTest.interpretationLabelsAr[entry.value],
        );
        expect(DiagnosticModel.getBrainRotBand(entry.key), entry.value);
      }
    });

    test('interpretation labels match Dr. Moneam Arabic copy exactly', () {
      expect(BrainRotTest.labelMildAr, BrainRotTest.interpretationLabelsAr[InterpretationBand.mild]);
      expect(BrainRotTest.labelModerateAr, BrainRotTest.interpretationLabelsAr[InterpretationBand.moderate]);
      expect(BrainRotTest.labelSevereAr, BrainRotTest.interpretationLabelsAr[InterpretationBand.severe]);
      expect(BrainRotTest.labelCriticalAr, BrainRotTest.interpretationLabelsAr[InterpretationBand.critical]);
      expect(DiagnosticModel.brainRotInterpretationLabelsAr, BrainRotTest.interpretationLabelsAr);
      expect(InterpretationBand.severe.labelAr, BrainRotTest.labelSevereAr);
      expect(
        DiagnosticModel.brainRotInterpretationForScore(7),
        InterpretationBand.severe.labelAr,
      );
      expect(InterpretationBand.mild.scoreRange, (0, 2));
      expect(InterpretationBand.critical.scoreRange, (9, 10));
    });

    test('evaluate returns centralized Arabic label without UI hardcoding', () {
      final result = DiagnosticModel.evaluateBrainRot(
        List<bool>.filled(10, true),
      );
      expect(result.score, 10);
      expect(result.band, InterpretationBand.critical);
      expect(result.interpretationAr, BrainRotTest.labelCriticalAr);
      expect(result.interpretationAr, DiagnosticModel.interpretBrainRotScore(10));
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

      expectHabitMetrics(roundTrip(model), boredom: true, delayed: 4, body: false);
    });
  });

  group('PillarBoundEvaluation', () {
    test('fromFrozen normalizes incoherent stored bcScore', () {
      final bad = BhiPillarFrozenSnapshot(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
        bcScore: 999,
        frozenAt: DateTime.utc(2026, 1, 1),
      );
      final evaluation = PillarBoundEvaluation.fromFrozen(bad);
      expect(evaluation.isCoherent, isTrue);
      expect(evaluation.bcScore, isNot(999));
    });

    test('matrix contributions align with frozen bcScore formula', () {
      const model = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 68,
        healthyHabits: 70,
        consistency: 60,
      );
      final frozen = BhiPillarFrozenSnapshot.freeze(model);
      final evaluation = PillarBoundEvaluation.fromFrozen(frozen);

      expect(evaluation.isCoherent, isTrue);
      expect(evaluation.bcScore, frozen.bcScore);
      final sum = evaluation.brainContribution +
          evaluation.digitalContribution +
          evaluation.habitsContribution +
          evaluation.consistencyContribution;
      expect(evaluation.bcScore, greaterThanOrEqualTo(sum - 0.01));
      expect(evaluation.pillarRows, hasLength(4));
    });
  });

  group('DiagnosticSession serialization', () {
    test('inProgress exposes live BHI and questionnaire without commit', () {
      const model = DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      );
      const metrics = DiagnosticMetrics(sleepQuality: 8);
      const questionnaire = BrainRotQuestionnaireSnapshot(
        answers: [true, false, true, false, false, false, false, false, false, false],
        currentIndex: 9,
        phase: BrainRotFlowPhase.results,
      );

      final draft = DiagnosticSession.inProgress(
        metrics: metrics,
        model: model,
        questionnaire: questionnaire,
      );

      expect(draft.isCommitted, isFalse);
      expect(draft.isInProgress, isTrue);
      expect(draft.brainRotAssessment, isNull);
      expect(draft.brainRotScore, 2);
      expect(draft.bcScore, draft.frozenPillars.bcScore);
      expect(draft.pillarModel.brainPerformance, draft.frozenBrainPerformance);
      expect(draft.isPillarBoundCoherent, isTrue);
      expect(
        draft.frozenPillars.recomputedBcScore,
        BhiPillarFrozenSnapshot.computeBcScore(
          brainPerformance: draft.frozenBrainPerformance,
          digitalDiscipline: draft.frozenDigitalDiscipline,
          healthyHabits: draft.frozenHealthyHabits,
          consistency: draft.frozenConsistency,
        ),
      );
      expect(draft.metrics.sleepQuality, 8);
      expect(draft.questionnairePhase, BrainRotFlowPhase.results);
    });

    test('round-trips model, metrics, and Brain Rot assessment', () {
      const model = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 68,
        healthyHabits: 70,
        consistency: 60,
      );
      const metrics = DiagnosticMetrics(
        sleepQuality: 7,
        sustainedAttention: 6,
        fragmentation: 5,
        dopamineSeeking: 4,
        taskSwitching: 5,
        burnout: 6,
      );
      final interpretation = DiagnosticModel.evaluateBrainRot(
        [true, false, true, false, false, false, false, false, false, false],
      );
      final session = DiagnosticSession.fromAssessment(
        model: model,
        metrics: metrics,
        brainRot: interpretation,
        brainRotAnswers: interpretation.score > 0
            ? [true, false, true, false, false, false, false, false, false, false]
            : List<bool>.filled(10, false),
        committedAt: DateTime.utc(2026, 5, 20, 9, 30),
      );

      final restored = DiagnosticSession.fromJson(session.toJson());
      expect(restored.bcScoreRounded, session.bcScoreRounded);
      expect(restored.brainRotScore, 2);
      expect(restored.brainRotBand, InterpretationBand.mild);
      expect(restored.brainRotAnswers, hasLength(10));
      expect(restored.bhi.metrics.sleepQuality, 7);
      expect(restored.questionnaire.phase, BrainRotFlowPhase.bhiSliders);
      expect(restored.frozenBrainPerformance, 72);
      expect(restored.frozenDigitalDiscipline, 68);
      expect(restored.frozenHealthyHabits, 70);
      expect(restored.frozenConsistency, 60);
      expect(restored.frozenPillars.bcScore, session.frozenPillars.bcScore);
      expect(restored.bcScore, restored.pillarEvaluation.bcScore);
      expect(restored.bcScore, restored.frozenPillars.bcScore);
      expect(restored.pillarModel.consistency, 60);
      expect(restored.pillarEvaluation.isCoherent, isTrue);

      final payload = session.toRepositoryPayload();
      expect(payload['brain_rot_score'], 2);
      expect(payload['interpretation_band'], 'mild');
      expect(payload['sleep_quality'], 7);
      expect(payload['brain_rot_answers'], isA<List<dynamic>>());
      expect(payload['mapped_brain_performance'], isA<double>());
      expect(payload['questionnaire_phase'], 'bhiSliders');
      expect(payload['bhi_frozen_snapshot'], isA<Map<String, dynamic>>());
      expect(payload['questionnaire_json'], isA<Map<String, dynamic>>());
      expect(payload['brain_performance'], 72);
    });

    test('frozen pillars remain stable after model mutation post-commit', () {
      const model = DiagnosticModel(
        brainPerformance: 80,
        digitalDiscipline: 75,
        healthyHabits: 70,
        consistency: 65,
      );
      const metrics = DiagnosticMetrics();
      final session = DiagnosticSession.fromAssessment(
        model: model,
        metrics: metrics,
        brainRot: DiagnosticModel.evaluateBrainRot(
          List<bool>.filled(10, false),
        ),
        brainRotAnswers: List<bool>.filled(10, false),
      );

      final mutatedJson = session.toJson();
      final modelMap = mutatedJson['bhi'] as Map<String, dynamic>;
      final innerModel = modelMap['model'] as Map<String, dynamic>;
      innerModel['brainPerformance'] = 10.0;

      final restored = DiagnosticSession.fromJson(mutatedJson);
      expect(restored.frozenBrainPerformance, 80);
      expect(restored.model.brainPerformance, 10);
    });
  });
}