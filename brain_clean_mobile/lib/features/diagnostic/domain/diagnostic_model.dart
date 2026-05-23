import 'package:freezed_annotation/freezed_annotation.dart';

import 'bc_score_engine.dart';
import 'bc_score_result.dart';

part 'diagnostic_model.freezed.dart';
part 'diagnostic_model.g.dart';

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
  /// Live BC_score percentage (delegates to [BcScoreEngine]).
  double get focusScorePercentage => BcScoreEngine.calculate(this).bcScore;

  /// Full breakdown for UI / persistence.
  BcScoreResult get bcScoreResult => BcScoreEngine.calculate(this);
}
