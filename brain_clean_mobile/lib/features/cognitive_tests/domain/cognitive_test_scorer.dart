import '../../diagnostic/domain/diagnostic_model.dart';
import 'cognitive_test_result.dart';

/// Normalizes cognitive mini-game telemetry and blends into [DiagnosticModel].
abstract final class CognitiveTestScorer {
  static const double brainPerformanceWeight = 0.15;

  static const int memoryMinSpan = 3;
  static const int memoryMaxSpan = 10;
  static const int visualDefaultRounds = 8;
  static const int visualMaxPointsPerRound = 3;

  /// Points for one visual-attention round (mirrors [VisualCognitiveScorer] tiers).
  static int visualRoundPoints({
    required bool correct,
    required double tapTimeSeconds,
    bool timedOut = false,
  }) {
    if (timedOut || !correct) return 0;
    if (tapTimeSeconds <= 1.0) return 3;
    if (tapTimeSeconds <= 2.5) return 2;
    return 1;
  }

  /// Longest successfully recalled sequence length → 0–100.
  static double normalizeMemoryScore(int longestSuccessfulSpan) {
    if (longestSuccessfulSpan < memoryMinSpan) return 0;
    final span = longestSuccessfulSpan.clamp(memoryMinSpan, memoryMaxSpan);
    return ((span - memoryMinSpan + 1) /
            (memoryMaxSpan - memoryMinSpan + 1) *
            100)
        .clamp(0.0, 100.0);
  }

  /// Raw visual round points → 0–100.
  static double normalizeVisualScore(
    int totalPoints, {
    int rounds = visualDefaultRounds,
  }) {
    final maxPoints = rounds * visualMaxPointsPerRound;
    if (maxPoints <= 0) return 0;
    return (totalPoints / maxPoints * 100).clamp(0.0, 100.0);
  }

  static CognitiveTestResult buildMemoryResult({
    required int longestSuccessfulSpan,
    DateTime? completedAt,
  }) {
    return CognitiveTestResult(
      testId: CognitiveTestIds.memorySequence,
      normalizedScore: normalizeMemoryScore(longestSuccessfulSpan),
      completedAt: completedAt ?? DateTime.now(),
      longestSuccessfulSpan: longestSuccessfulSpan,
    );
  }

  static CognitiveTestResult buildVisualResult({
    required int totalPoints,
    required int roundsPlayed,
    DateTime? completedAt,
  }) {
    return CognitiveTestResult(
      testId: CognitiveTestIds.visualAttention,
      normalizedScore: normalizeVisualScore(totalPoints, rounds: roundsPlayed),
      completedAt: completedAt ?? DateTime.now(),
      visualTotalPoints: totalPoints,
      visualRoundsPlayed: roundsPlayed,
    );
  }

  static DiagnosticModel applyCognitiveToModel(
    DiagnosticModel base, {
    CognitiveTestResult? visualAttention,
    CognitiveTestResult? memorySequence,
  }) {
    final scores = <double>[
      if (visualAttention != null) visualAttention.normalizedScore,
      if (memorySequence != null) memorySequence.normalizedScore,
    ];
    if (scores.isEmpty) return base;

    final cognitiveAvg = scores.reduce((a, b) => a + b) / scores.length;
    final blended = base.brainPerformance * (1 - brainPerformanceWeight) +
        cognitiveAvg * brainPerformanceWeight;

    return base.copyWith(brainPerformance: blended.clamp(0, 100));
  }
}

/// Stable test identifiers persisted with results.
abstract final class CognitiveTestIds {
  static const visualAttention = 'visual_attention_v1';
  static const memorySequence = 'memory_sequence_v1';
}
