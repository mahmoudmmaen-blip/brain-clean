import 'package:brain_clean_mobile/features/interactive_diagnostic/domain/diag_metric.dart';
import 'package:brain_clean_mobile/features/interactive_diagnostic/domain/diag_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scoreFromAnswers', () {
    test('computes overall and weakest metric from five likert answers', () {
      // Low screen habits (Q3, Q4), higher elsewhere.
      final result = scoreFromAnswers([5, 4, 1, 2, 4]);

      expect(result.overallPercent, greaterThan(0));
      expect(result.weakestMetric, DiagMetric.screenHabits);
      expect(
        result.scoreFor(DiagMetric.screenHabits).percent,
        lessThan(result.scoreFor(DiagMetric.attention).percent),
      );
    });

    test('throws when answer count is not five', () {
      expect(
        () => scoreFromAnswers([3, 3]),
        throwsArgumentError,
      );
    });

    test('throws when answer is out of likert range', () {
      expect(
        () => scoreFromAnswers([1, 2, 3, 4, 6]),
        throwsArgumentError,
      );
    });
  });
}
