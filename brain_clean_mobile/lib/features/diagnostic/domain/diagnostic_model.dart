import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_model.freezed.dart';

/// Six-point neuro-diagnostic input (each metric range 1–10).
@freezed
class DiagnosticMetrics with _$DiagnosticMetrics {
  const factory DiagnosticMetrics({
    /// S1 — sleep quality
    @Default(0) int sleepQuality,
    /// A2 — sustained attention
    @Default(0) int sustainedAttention,
    /// F3 — fragmentation
    @Default(0) int fragmentation,
    /// D4 — dopamine seeking
    @Default(0) int dopamineSeeking,
    /// T5 — task switching
    @Default(0) int taskSwitching,
    /// B6 — burnout
    @Default(0) int burnout,
  }) = _DiagnosticMetrics;

  const DiagnosticMetrics._();

  static const double _minRaw = -29.0;
  static const double _maxRaw = 26.8;

  /// Neuro-scientific focus score normalized to \[0, 100\].
  double calculateFocusScore() {
    final rawScore = ((sleepQuality + sustainedAttention) * 1.5) -
        ((fragmentation +
                dopamineSeeking +
                taskSwitching +
                burnout) *
            0.8);
    final normalized =
        ((rawScore - _minRaw) / (_maxRaw - _minRaw)) * 100.0;
    return normalized.clamp(0.0, 100.0);
  }
}
