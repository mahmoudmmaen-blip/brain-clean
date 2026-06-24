import 'package:brain_clean_mobile/features/cognitive_tests/domain/cognitive_test_result.dart';
import 'package:brain_clean_mobile/features/cognitive_tests/domain/cognitive_test_scorer.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitiveTestScorer.normalizeMemoryScore', () {
    test('maps min span to low score and max span to 100', () {
      expect(CognitiveTestScorer.normalizeMemoryScore(2), 0);
      expect(CognitiveTestScorer.normalizeMemoryScore(3), closeTo(12.5, 0.01));
      expect(CognitiveTestScorer.normalizeMemoryScore(10), 100);
    });

    test('buildMemoryResult embeds span telemetry', () {
      final result = CognitiveTestScorer.buildMemoryResult(
        longestSuccessfulSpan: 6,
      );
      expect(result.testId, CognitiveTestIds.memorySequence);
      expect(result.longestSuccessfulSpan, 6);
      expect(result.normalizedScore, greaterThan(0));
    });
  });

  group('CognitiveTestScorer.normalizeVisualScore', () {
    test('fast perfect rounds yield high normalized score', () {
      const points = 8 * 3;
      expect(
        CognitiveTestScorer.normalizeVisualScore(points),
        100,
      );
    });

    test('visualRoundPoints matches speed tiers', () {
      expect(
        CognitiveTestScorer.visualRoundPoints(
          correct: true,
          tapTimeSeconds: 0.8,
        ),
        3,
      );
      expect(
        CognitiveTestScorer.visualRoundPoints(
          correct: true,
          tapTimeSeconds: 2.0,
        ),
        2,
      );
      expect(
        CognitiveTestScorer.visualRoundPoints(
          correct: false,
          tapTimeSeconds: 0.5,
        ),
        0,
      );
    });

    test('buildVisualResult packages telemetry', () {
      final result = CognitiveTestScorer.buildVisualResult(
        totalPoints: 12,
        roundsPlayed: 8,
      );
      expect(result.testId, CognitiveTestIds.visualAttention);
      expect(result.visualTotalPoints, 12);
      expect(result.visualRoundsPlayed, 8);
    });
  });

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
