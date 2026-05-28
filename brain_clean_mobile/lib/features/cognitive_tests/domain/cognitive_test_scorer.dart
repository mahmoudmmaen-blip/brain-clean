import '../../diagnostic/domain/diagnostic_model.dart';
import 'cognitive_test_result.dart';

/// Blends cognitive mini-game scores into [DiagnosticModel.brainPerformance].
///
/// Placeholder: returns model unchanged until real game telemetry exists.
abstract final class CognitiveTestScorer {
  static const double brainPerformanceWeight = 0.15;

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
