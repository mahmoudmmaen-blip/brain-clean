import 'package:brain_clean_mobile/features/diagnostic/domain/bhi_pillar_frozen_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/bhi_pillar_json_keys.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_bhi_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BhiPillarJsonKeys', () {
    const model = DiagnosticModel(
      brainPerformance: 80,
      digitalDiscipline: 75,
      healthyHabits: 70,
      consistency: 65,
    );

    test('decodeHiveMap coerces dynamic keys without cast errors', () {
      final hiveRaw = <dynamic, dynamic>{
        BhiPillarJsonKeys.metrics: <dynamic, dynamic>{
          BhiPillarJsonKeys.sleepQuality: 7,
        },
        BhiPillarJsonKeys.bhi: <dynamic, dynamic>{
          BhiPillarJsonKeys.metrics: <dynamic, dynamic>{
            BhiPillarJsonKeys.sleepQuality: 6,
          },
          BhiPillarJsonKeys.model: <dynamic, dynamic>{
            BhiPillarJsonKeys.brainPerformance: 70.0,
            BhiPillarJsonKeys.digitalDiscipline: 65.0,
            BhiPillarJsonKeys.healthyHabits: 60.0,
            BhiPillarJsonKeys.consistency: 55.0,
          },
        },
        BhiPillarJsonKeys.committedAt: '2026-05-20T12:00:00.000',
        BhiPillarJsonKeys.questionnaire: <dynamic, dynamic>{
          BhiPillarJsonKeys.currentIndex: 0,
          BhiPillarJsonKeys.phase: 'questions',
        },
      };

      final session = DiagnosticSession.fromJson(
        BhiPillarJsonKeys.normalizeIncoming(
          BhiPillarJsonKeys.decodeHiveMap(hiveRaw),
        ),
      );
      expect(session.metrics.sleepQuality, 6);
      expect(session.isLive, isTrue);
    });

    test('normalizeIncoming migrates legacy snake_case pillar keys', () {
      final legacy = {
        BhiPillarJsonKeys.brainPerformanceSnake: 80,
        BhiPillarJsonKeys.digitalDisciplineSnake: 75,
        BhiPillarJsonKeys.healthyHabitsSnake: 70,
        BhiPillarJsonKeys.consistency: 65,
        BhiPillarJsonKeys.bcScoreSnake: 74.5,
        BhiPillarJsonKeys.frozenAtLegacy: '2026-01-01T00:00:00.000Z',
        BhiPillarJsonKeys.recoveryPenaltyDeductionSnake: 15,
      };
      final normalized = BhiPillarJsonKeys.normalizeIncoming(legacy);
      expect(
        normalized[BhiPillarJsonKeys.recoveryPenaltyDeduction],
        15,
      );
      expect(normalized[BhiPillarJsonKeys.brainPerformance], 80);
    });

    test('writePenaltyEnvelope uses centralized keys only', () {
      final map = <String, dynamic>{};
      BhiPillarJsonKeys.writePenaltyEnvelope(
        map,
        recoveryPenaltyDeduction: 15,
        pillarMatrixBcScore: 74.5,
        boundBcScore: 59.5,
      );
      expect(map[BhiPillarJsonKeys.recoveryPenaltyDeduction], 15);
      expect(map[BhiPillarJsonKeys.pillarMatrixBcScore], 74.5);
      expect(map[BhiPillarJsonKeys.boundBcScore], 59.5);
      expect(map[BhiPillarJsonKeys.bcScore], 59.5);
      expect(map.containsKey('recovery_penalty_deduction'), isFalse);
    });

    test('DiagnosticBhiSnapshot toJson embeds penalty via key gateway', () {
      final bhi = DiagnosticBhiSnapshot.compose(
        metrics: const DiagnosticMetrics(),
        model: model,
        recoveryPenaltyDeduction: 15,
      );
      final json = bhi.toJson();
      expect(
        json[BhiPillarJsonKeys.recoveryPenaltyDeduction],
        15,
      );
      expect(
        json[BhiPillarJsonKeys.frozenPillars]
            [BhiPillarJsonKeys.recoveryPenaltyDeduction],
        15,
      );
      final restored = DiagnosticBhiSnapshot.fromJson(json);
      expect(restored.recoveryPenaltyDeduction, 15);
    });

    test('DiagnosticSession toJson uses centralized session envelope keys', () {
      final session = DiagnosticSession.fromAssessment(
        model: model,
        metrics: const DiagnosticMetrics(),
        brainRot: DiagnosticModel.evaluateBrainRot(List<bool>.filled(10, false)),
        brainRotAnswers: List<bool>.filled(10, false),
      ).withRecoveryPenaltyTotal(15);

      final json = session.toJson();
      expect(json.containsKey(BhiPillarJsonKeys.bhi), isTrue);
      expect(json.containsKey(BhiPillarJsonKeys.committedAt), isTrue);
      expect(json.containsKey(BhiPillarJsonKeys.recoveryPenaltyDeduction), isTrue);
      expect(json[BhiPillarJsonKeys.hasRecoveryPenalty], isTrue);
      expect(json[BhiPillarJsonKeys.accountabilityDeductionTotal], 15);
      expect(json.containsKey(BhiPillarJsonKeys.committedAtSnake), isFalse);

      final legacy = Map<String, dynamic>.from(json)
        ..[BhiPillarJsonKeys.committedAtSnake] =
            json.remove(BhiPillarJsonKeys.committedAt);
      final restored = DiagnosticSession.fromJson(legacy);
      expect(restored.recoveryPenaltyDeduction, 15);
    });

    test('DiagnosticMetrics fromJson migrates snake_case slider keys', () {
      final legacy = {
        BhiPillarJsonKeys.sleepQualitySnake: 8,
        BhiPillarJsonKeys.sustainedAttentionSnake: 7,
        BhiPillarJsonKeys.fragmentationSnake: 6,
        BhiPillarJsonKeys.dopamineSeekingSnake: 5,
        BhiPillarJsonKeys.taskSwitchingSnake: 4,
        BhiPillarJsonKeys.burnoutSnake: 3,
      };
      final metrics = DiagnosticMetrics.fromJson(legacy);
      expect(metrics.sleepQuality, 8);
      expect(metrics.burnout, 3);
      final json = metrics.toJson();
      expect(json[BhiPillarJsonKeys.sleepQuality], 8);
    });

    test('frozen snapshot toJson emits camelCase keys exclusively', () {
      final frozen = BhiPillarFrozenSnapshot.freeze(model).copyWith(
        recoveryPenaltyDeduction: 15,
      );
      final json = frozen.toJson();
      expect(
        json.containsKey(BhiPillarJsonKeys.recoveryPenaltyDeduction),
        isTrue,
      );
      expect(
        json.containsKey(BhiPillarJsonKeys.recoveryPenaltyDeductionSnake),
        isFalse,
      );
    });
  });
}
