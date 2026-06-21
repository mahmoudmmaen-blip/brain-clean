import 'package:freezed_annotation/freezed_annotation.dart';

import 'bhi_pillar_json_keys.dart';
import 'bc_score_engine.dart';
import 'bc_score_result.dart';

part 'diagnostic_metrics.freezed.dart';
part 'diagnostic_metrics.g.dart';

/// Six-point neuro-diagnostic input (each metric range 1–10).
@freezed
class DiagnosticMetrics with _$DiagnosticMetrics {
  const factory DiagnosticMetrics({
    @JsonKey(name: BhiPillarJsonKeys.sleepQuality) @Default(5) int sleepQuality,
    @JsonKey(name: BhiPillarJsonKeys.sustainedAttention)
    @Default(5)
    int sustainedAttention,
    @JsonKey(name: BhiPillarJsonKeys.fragmentation) @Default(5) int fragmentation,
    @JsonKey(name: BhiPillarJsonKeys.dopamineSeeking)
    @Default(5)
    int dopamineSeeking,
    @JsonKey(name: BhiPillarJsonKeys.taskSwitching) @Default(5) int taskSwitching,
    @JsonKey(name: BhiPillarJsonKeys.burnout) @Default(5) int burnout,
  }) = _DiagnosticMetrics;

  factory DiagnosticMetrics.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticMetricsFromJson(
        BhiPillarJsonKeys.normalizeIncoming(json),
      );
}

extension DiagnosticMetricsX on DiagnosticMetrics {
  double get focusScorePercentage => BcScoreEngine.calculate(this).bcScore;

  BcScoreResult get bcScoreResult => BcScoreEngine.calculate(this);
}
