import 'package:brain_clean_mobile/features/diagnostic/domain/bc_score_engine.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BcScoreEngine', () {
    test('max positive metrics yields high BC_score', () {
      const metrics = DiagnosticMetrics(
        sleepQuality: 10,
        sustainedAttention: 10,
        fragmentation: 1,
        dopamineSeeking: 1,
        taskSwitching: 1,
        burnout: 1,
      );
      final result = BcScoreEngine.calculate(metrics);
      expect(result.bcScore, greaterThan(90));
      expect(result.bcScore, lessThanOrEqualTo(100));
    });

    test('max negative metrics yields low BC_score', () {
      const metrics = DiagnosticMetrics(
        sleepQuality: 1,
        sustainedAttention: 1,
        fragmentation: 10,
        dopamineSeeking: 10,
        taskSwitching: 10,
        burnout: 10,
      );
      final result = BcScoreEngine.calculate(metrics);
      expect(result.bcScore, lessThan(15));
      expect(result.bcScore, greaterThanOrEqualTo(0));
    });

    test('bc_score is always clamped 0-100', () {
      for (var s = 1; s <= 10; s++) {
        final result = BcScoreEngine.calculate(
          DiagnosticMetrics(
            sleepQuality: s,
            sustainedAttention: s,
            fragmentation: 11 - s,
            dopamineSeeking: 11 - s,
            taskSwitching: 11 - s,
            burnout: 11 - s,
          ),
        );
        expect(result.bcScore, inInclusiveRange(0.0, 100.0));
      }
    });
  });
}
