import 'package:json_annotation/json_annotation.dart';

import 'diagnostic_metrics.dart';
import 'diagnostic_metrics_mapper.dart';
import 'diagnostic_model.dart';

part 'diagnostic_bhi_snapshot.g.dart';

/// Slider inputs mapped to the centralized [DiagnosticModel] BHI pillars.
@JsonSerializable(explicitToJson: true)
class DiagnosticBhiSnapshot {
  const DiagnosticBhiSnapshot({
    required this.metrics,
    required this.model,
  });

  /// Six-point slider source (1–10 per axis).
  final DiagnosticMetrics metrics;

  /// Committed BHI pillar values (may include live detox weighting at submit).
  final DiagnosticModel model;

  /// Pure mapper output from [metrics] — used to verify coherence at commit.
  DiagnosticModel get mappedFromMetrics =>
      DiagnosticMetricsMapper.fromMetrics(metrics);

  factory DiagnosticBhiSnapshot.compose({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
  }) =>
      DiagnosticBhiSnapshot(metrics: metrics, model: model);

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticBhiSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticBhiSnapshotToJson(this);
}
