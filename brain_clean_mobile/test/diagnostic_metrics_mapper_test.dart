import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiagnosticMetricsMapper', () {
    test('maps default metrics to mid-range pillars', () {
      const metrics = DiagnosticMetrics();
      final model = DiagnosticMetricsMapper.fromMetrics(metrics);

      expect(model.brainPerformance, 50);
      expect(model.digitalDiscipline, 50);
      expect(model.healthyHabits, 50);
      expect(model.consistency, 50);
      expect(model.bcScore, 50);
    });

    test('maps optimal sliders to high BC_score', () {
      const metrics = DiagnosticMetrics(
        sleepQuality: 10,
        sustainedAttention: 10,
        fragmentation: 1,
        dopamineSeeking: 1,
        taskSwitching: 1,
        burnout: 1,
      );
      final model = DiagnosticMetricsMapper.fromMetrics(metrics);
      expect(model.bcScore, greaterThan(90));
    });

    test('maps worst sliders to BHI floor', () {
      const metrics = DiagnosticMetrics(
        sleepQuality: 1,
        sustainedAttention: 1,
        fragmentation: 10,
        dopamineSeeking: 10,
        taskSwitching: 10,
        burnout: 10,
      );
      final model = DiagnosticMetricsMapper.fromMetrics(metrics);
      expect(model.bcScore, BcScoreConstants.bhiScoreFloor);
    });
  });
}
