import 'package:brain_clean_mobile/features/cognitive_tests/domain/cognitive_test_result.dart';
import 'package:brain_clean_mobile/features/cognitive_tests/domain/cognitive_test_scorer.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CognitiveTestScorer blends visual and memory into brain performance', () {
    const base = DiagnosticModel(
      brainPerformance: 80,
      digitalDiscipline: 70,
      healthyHabits: 75,
      consistency: 65,
    );

    final blended = CognitiveTestScorer.applyCognitiveToModel(
      base,
      visualAttention: CognitiveTestResult(
        testId: 'visual',
        normalizedScore: 100,
        completedAt: DateTime(2026, 5, 28),
      ),
    );

    expect(blended.brainPerformance, closeTo(83, 0.01));
    expect(blended.brainPerformance, lessThan(100));
    expect(blended.digitalDiscipline, 70);
  });

  test('CognitiveTestScorer returns base when no results', () {
    const base = DiagnosticModel(
      brainPerformance: 80,
      digitalDiscipline: 70,
      healthyHabits: 75,
      consistency: 65,
    );
    expect(CognitiveTestScorer.applyCognitiveToModel(base), base);
  });
}
