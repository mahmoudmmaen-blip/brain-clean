import 'diagnostic_metrics.dart';
import 'diagnostic_model.dart';

/// Maps 6-point slider metrics (1–10) → BHI pillars (0–100).
abstract final class DiagnosticMetricsMapper {
  static double _toPercent(int value) => (value.clamp(1, 10) / 10) * 100;

  static double _inversePercent(int value) =>
      ((10 - value.clamp(1, 10)) / 10) * 100;

  static DiagnosticModel fromMetrics(DiagnosticMetrics metrics) {
    return DiagnosticModel(
      brainPerformance: (_toPercent(metrics.sleepQuality) +
              _toPercent(metrics.sustainedAttention)) /
          2,
      digitalDiscipline: (_inversePercent(metrics.fragmentation) +
              _inversePercent(metrics.dopamineSeeking) +
              _inversePercent(metrics.taskSwitching)) /
          3,
      healthyHabits: (_toPercent(metrics.sleepQuality) +
              _inversePercent(metrics.burnout)) /
          2,
      consistency: (_toPercent(metrics.sustainedAttention) +
              _inversePercent(metrics.taskSwitching)) /
          2,
    );
  }
}
