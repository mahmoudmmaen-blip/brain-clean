import 'package:brain_clean_mobile/features/diagnostic/domain/bhi_pillar_frozen_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_bhi_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/pillar_bound_evaluation.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Recovery BC_score penalty wiring', () {
    const model = DiagnosticModel(
      brainPerformance: 80,
      digitalDiscipline: 75,
      healthyHabits: 70,
      consistency: 65,
    );
    const metrics = DiagnosticMetrics();

    test('effectiveBcScore deducts exactly 15 per penalty with ε coherence', () {
      const penalty = 15.0;
      final frozen = BhiPillarFrozenSnapshot.freeze(model).copyWith(
        recoveryPenaltyDeduction: penalty,
      );

      expect(
        frozen.pillarMatrixBcScore - frozen.bcScore,
        closeTo(penalty, 1e-9),
      );
      expect(frozen.isCoherent, isTrue);
      expect(
        PillarBoundEvaluation.scoresMatch(
          frozen.bcScore,
          frozen.recomputedBcScore,
        ),
        isTrue,
      );
    });

    test('DiagnosticSession.withRecoveryPenaltyTotal passes matrix ε check', () {
      final session = DiagnosticSession.fromAssessment(
        model: model,
        metrics: metrics,
        brainRot: DiagnosticModel.evaluateBrainRot(
          List<bool>.filled(10, false),
        ),
        brainRotAnswers: List<bool>.filled(10, false),
      );

      final before = session.bcScore;
      final penalized = session.withRecoveryPenaltyTotal(
        RecoveryProtocolConstants.penaltyBcScoreDeduction.toDouble(),
      );

      expect(penalized.bcScore, closeTo(before - 15, 1e-9));
      expect(penalized.frozenPillars.recoveryPenaltyDeduction, 15);
      expect(penalized.pillarEvaluation.isCoherent, isTrue);
      penalized.ensureDiagnosticCoherence();
    });

    test('DiagnosticBhiSnapshot.compose applies recovery penalty at creation', () {
      const model = DiagnosticModel(
        brainPerformance: 70,
        digitalDiscipline: 70,
        healthyHabits: 70,
        consistency: 70,
      );
      final bhi = DiagnosticBhiSnapshot.compose(
        metrics: const DiagnosticMetrics(),
        model: model,
        recoveryPenaltyDeduction: 15,
      );

      expect(bhi.hasRecoveryPenalty, isTrue);
      expect(bhi.boundBcScore, closeTo(bhi.pillarMatrixBcScore - 15, 1e-9));
      bhi.ensurePillarBoundCoherence();
    });

    test('cumulative penalties clamp at BHI floor', () {
      final lowModel = const DiagnosticModel(
        brainPerformance: 30,
        digitalDiscipline: 30,
        healthyHabits: 30,
        consistency: 30,
      );
      final frozen = BhiPillarFrozenSnapshot.freeze(lowModel).copyWith(
        recoveryPenaltyDeduction: 100,
      );

      expect(frozen.bcScore, 26.8);
      expect(frozen.isCoherent, isTrue);
    });
  });
}
