import 'package:freezed_annotation/freezed_annotation.dart';

import 'bc_score_engine.dart';
import 'bc_score_result.dart';

part 'diagnostic_metrics.freezed.dart';
part 'diagnostic_metrics.g.dart';

/// Six-point neuro-diagnostic input (each metric range 1–10).
@freezed
class DiagnosticMetrics with _$DiagnosticMetrics {
  const factory DiagnosticMetrics({
    @Default(5) int sleepQuality,
    @Default(5) int sustainedAttention,
    @Default(5) int fragmentation,
    @Default(5) int dopamineSeeking,
    @Default(5) int taskSwitching,
    @Default(5) int burnout,
  }) = _DiagnosticMetrics;

  factory DiagnosticMetrics.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticMetricsFromJson(json);
}

extension DiagnosticMetricsX on DiagnosticMetrics {
  double get focusScorePercentage => BcScoreEngine.calculate(this).bcScore;

  BcScoreResult get bcScoreResult => BcScoreEngine.calculate(this);
}
