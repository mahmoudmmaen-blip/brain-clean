import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_scale.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/measurement_event.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/item_polarity.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score_engine.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/score_calculation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MeasurementEvent eventFor(
    BrainCheckMode mode,
    Map<String, int> answers, {
    String id = 'sess',
  }) {
    return MeasurementEvent(
      id: id,
      mode: mode,
      capturedAt: DateTime.utc(2026, 8, 2),
      answers: answers,
      sectionIds: BrainCheckItemBank.sectionsFor(mode)
          .map((s) => s.id)
          .toList(growable: false),
    );
  }

  Map<String, int> allAt(BrainCheckMode mode, int Function(String id) picker) {
    final map = <String, int>{};
    for (final q in BrainCheckItemBank.questionsFor(mode)) {
      map[q.id] = picker(q.id);
    }
    return map;
  }

  group('normalization', () {
    test('likert forward max → 100', () {
      final q = BrainCheckItemBank.questionById(BrainCheckMode.full, 'full_q1')!;
      expect(
        RecoveryScoreEngine.normalizeItemOrNull(question: q, rawValue: 5),
        100,
      );
    });

    test('reverse full_q3 raw 5 → 0', () {
      final q = BrainCheckItemBank.questionById(BrainCheckMode.full, 'full_q3')!;
      expect(ItemPolarityTable.forQuestionId('full_q3'), ItemPolarity.reverse);
      expect(
        RecoveryScoreEngine.normalizeItemOrNull(question: q, rawValue: 5),
        0,
      );
    });

    test('reverse full_q6 raw 1 → 100', () {
      final q = BrainCheckItemBank.questionById(BrainCheckMode.full, 'full_q6')!;
      expect(
        RecoveryScoreEngine.normalizeItemOrNull(question: q, rawValue: 1),
        100,
      );
    });

    test('yesNo forward yes → 100, no → 0', () {
      final q = BrainCheckItemBank.questionById(BrainCheckMode.lite, 'lite_q4')!;
      expect(q.scale, BrainCheckScale.yesNo);
      expect(
        RecoveryScoreEngine.normalizeItemOrNull(question: q, rawValue: 1),
        100,
      );
      expect(
        RecoveryScoreEngine.normalizeItemOrNull(question: q, rawValue: 0),
        0,
      );
    });

    test('out-of-range rejected (no clamp)', () {
      final q = BrainCheckItemBank.questionById(BrainCheckMode.full, 'full_q1')!;
      expect(
        RecoveryScoreEngine.normalizeItemOrNull(question: q, rawValue: 99),
        isNull,
      );
    });
  });

  group('overall score and bands', () {
    test('all max forward/reverse-min Full → 100 growing_foundation', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        if (ItemPolarityTable.forQuestionId(id) == ItemPolarity.reverse) {
          return 1; // frequency/likert min → reverse → 100
        }
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        return q.scale.maxValue;
      });
      final result =
          RecoveryScoreEngine.compute(eventFor(BrainCheckMode.full, answers));
      expect(result, isA<ScoreCalculationValid>());
      final valid = result as ScoreCalculationValid;
      expect(valid.recoveryScore.value, 100);
      expect(valid.recoveryScore.band, RecoveryScoreBand.growingFoundation);
      expect(valid.confidence, MeasurementConfidence.strong);
      expect(valid.recoveryScore.modelVersion, 'recovery_score_v1');
    });

    test('all min forward/reverse-max Full → 0 gathering_footing', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        if (ItemPolarityTable.forQuestionId(id) == ItemPolarity.reverse) {
          return 5;
        }
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        return q.scale.minValue;
      });
      final valid = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers),
      ) as ScoreCalculationValid;
      expect(valid.recoveryScore.value, 0);
      expect(valid.recoveryScore.band, RecoveryScoreBand.gatheringFooting);
    });

    test('band boundaries', () {
      expect(RecoveryScoreEngine.bandForDisplay(0), RecoveryScoreBand.gatheringFooting);
      expect(RecoveryScoreEngine.bandForDisplay(24), RecoveryScoreBand.gatheringFooting);
      expect(RecoveryScoreEngine.bandForDisplay(25), RecoveryScoreBand.buildingRhythm);
      expect(RecoveryScoreEngine.bandForDisplay(49), RecoveryScoreBand.buildingRhythm);
      expect(RecoveryScoreEngine.bandForDisplay(50), RecoveryScoreBand.findingSteadiness);
      expect(RecoveryScoreEngine.bandForDisplay(74), RecoveryScoreBand.findingSteadiness);
      expect(RecoveryScoreEngine.bandForDisplay(75), RecoveryScoreBand.growingFoundation);
      expect(RecoveryScoreEngine.bandForDisplay(100), RecoveryScoreBand.growingFoundation);
    });

    test('band near-edges', () {
      expect(RecoveryScoreEngine.bandForDisplay(23), RecoveryScoreBand.gatheringFooting);
      expect(RecoveryScoreEngine.bandForDisplay(26), RecoveryScoreBand.buildingRhythm);
      expect(RecoveryScoreEngine.bandForDisplay(48), RecoveryScoreBand.buildingRhythm);
      expect(RecoveryScoreEngine.bandForDisplay(51), RecoveryScoreBand.findingSteadiness);
      expect(RecoveryScoreEngine.bandForDisplay(73), RecoveryScoreBand.findingSteadiness);
      expect(RecoveryScoreEngine.bandForDisplay(76), RecoveryScoreBand.growingFoundation);
    });

    test('roundHalfUp 67.5 → 68', () {
      expect(RecoveryScoreEngine.roundHalfUp(67.5), 68);
      expect(RecoveryScoreEngine.roundHalfUp(67.4), 67);
    });

    test('equal weights Full — midpoint likert 3', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        if (q.scale == BrainCheckScale.yesNo) return 1;
        return 3;
      });
      final a = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers, id: 'a'),
      ) as ScoreCalculationValid;
      final b = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers, id: 'b'),
      ) as ScoreCalculationValid;
      expect(a.recoveryScore.value, b.recoveryScore.value);
      expect(a.overallInternal, b.overallInternal);
      expect(a.contributions.length, 4);
      expect(
        a.contributions.map((c) => c.weight).fold<double>(0, (x, y) => x + y),
        closeTo(1.0, 1e-9),
      );
    });
  });

  group('confidence', () {
    test('Lite complete → moderate never strong', () {
      final answers = allAt(BrainCheckMode.lite, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.lite, id)!;
        return q.scale.maxValue;
      });
      final valid = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.lite, answers),
      ) as ScoreCalculationValid;
      expect(valid.confidence, MeasurementConfidence.moderate);
      expect(valid.flags, contains('first_or_short_path'));
    });

    test('Full complete → strong', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        return q.scale.maxValue;
      });
      final valid = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers),
      ) as ScoreCalculationValid;
      expect(valid.confidence, MeasurementConfidence.strong);
    });

    test('corrupt recovery flag → provisional', () {
      expect(
        RecoveryScoreEngine.confidenceFor(
          mode: BrainCheckMode.full,
          recoveredFromCorrupt: true,
        ),
        MeasurementConfidence.provisional,
      );
    });
  });

  group('unavailable / edge cases', () {
    test('invalid range → unavailable', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        if (q.scale == BrainCheckScale.yesNo) return 1;
        return 3;
      });
      answers['full_q1'] = 99;
      final u = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers),
      ) as ScoreCalculationUnavailable;
      expect(u.reason, ScoreUnavailableReason.invalidRange);
      expect(u.flags, contains('invalid_range'));
    });

    test('unknown question → unavailable', () {
      final answers = allAt(BrainCheckMode.lite, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.lite, id)!;
        if (q.scale == BrainCheckScale.yesNo) return 1;
        return 3;
      });
      answers['legacy_qX'] = 2;
      final u = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.lite, answers),
      ) as ScoreCalculationUnavailable;
      expect(u.reason, ScoreUnavailableReason.unknownQuestion);
    });

    test('duplicate keys in map are canonical — last write wins in Dart map', () {
      final answers = allAt(BrainCheckMode.pulse, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.pulse, id)!;
        return q.scale.minValue;
      });
      answers['pulse_q1'] = 5;
      final valid = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.pulse, answers),
      ) as ScoreCalculationValid;
      expect(valid.recoveryScore.isValid, isTrue);
    });

    test('empty answers → unavailable not zero', () {
      final u = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.lite, {}),
      ) as ScoreCalculationUnavailable;
      expect(u.reason, ScoreUnavailableReason.emptyAnswers);
    });

    test('missing required → unavailable', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        if (q.scale == BrainCheckScale.yesNo) return 1;
        return 3;
      })
        ..remove('full_q1');
      final result = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers),
      );
      expect(result, isA<ScoreCalculationUnavailable>());
      final u = result as ScoreCalculationUnavailable;
      expect(u.reason, ScoreUnavailableReason.missingRequired);
      expect(u.flags, contains('missing_required'));
    });

    test('optional deepeners omitted → moderate on Full', () {
      final answers = allAt(BrainCheckMode.full, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.full, id)!;
        if (q.scale == BrainCheckScale.yesNo) return 1;
        return 3;
      });
      final valid = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.full, answers),
        optionalDeepenersOmitted: true,
      ) as ScoreCalculationValid;
      expect(valid.confidence, MeasurementConfidence.moderate);
      expect(valid.flags, contains('optional_omitted'));
    });
  });

  group('display integrity', () {
    test('no fake decimal — value is int', () {
      final answers = allAt(BrainCheckMode.lite, (id) {
        final q = BrainCheckItemBank.questionById(BrainCheckMode.lite, id)!;
        if (q.scale == BrainCheckScale.yesNo) return 1;
        return 3;
      });
      final valid = RecoveryScoreEngine.compute(
        eventFor(BrainCheckMode.lite, answers),
      ) as ScoreCalculationValid;
      expect(valid.recoveryScore.value, isA<int>());
      expect(valid.flags, contains('display_integer_only'));
    });
  });
}
