import 'package:brain_clean_mobile/features/diagnostic/domain/bhi_pillar_frozen_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/bhi_pillar_json_keys.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_bhi_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BhiPillarJsonKeys', () {
    const model = DiagnosticModel(
      brainPerformance: 80,
      digitalDiscipline: 75,
      healthyHabits: 70,
      consistency: 65,
    );

    test('normalizeIncoming migrates legacy snake_case pillar keys', () {
      final legacy = {
        BhiPillarJsonKeys.brainPerformanceSnake: 80,
        BhiPillarJsonKeys.digitalDisciplineSnake: 75,
        BhiPillarJsonKeys.healthyHabitsSnake: 70,
        BhiPillarJsonKeys.consistency: 65,
        BhiPillarJsonKeys.bcScoreSnake: 74.5,
        'frozen_at': '2026-01-01T00:00:00.000Z',
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
