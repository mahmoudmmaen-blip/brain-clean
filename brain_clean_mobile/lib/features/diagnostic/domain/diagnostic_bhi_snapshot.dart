import 'package:json_annotation/json_annotation.dart';

import 'bhi_pillar_frozen_snapshot.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_metrics_mapper.dart';
import 'diagnostic_model.dart';

part 'diagnostic_bhi_snapshot.g.dart';

/// Slider inputs, live model, and frozen pillar snapshot for a diagnostic session.
@JsonSerializable(explicitToJson: true)
class DiagnosticBhiSnapshot {
  const DiagnosticBhiSnapshot({
    required this.metrics,
    required this.model,
    required this.frozenPillars,
  });

  /// Six-point slider source (1–10 per axis).
  final DiagnosticMetrics metrics;

  /// Full BHI model at compose/commit time (habits + pillars).
  final DiagnosticModel model;

  /// Frozen four pillars + BC_score at save (immutable historical record).
  @JsonKey(name: 'frozen_pillars')
  final BhiPillarFrozenSnapshot frozenPillars;

  /// Pure mapper output from [metrics] — coherence check at commit.
  DiagnosticModel get mappedFromMetrics =>
      DiagnosticMetricsMapper.fromMetrics(metrics);

  double get frozenBcScore => frozenPillars.bcScore;

  /// Pillar values bound to [frozenPillars] — never reads fluid [model] fields.
  DiagnosticModel get pillarModel => frozenPillars.toModel();

  /// Pillar-bound BC_score — matches [frozenPillars.bcScore] when coherent.
  double get boundBcScore => frozenPillars.bcScore;

  /// True when stored [bcScore] matches recomputation from frozen pillars.
  bool get isPillarBoundCoherent => frozenPillars.isCoherent;

  factory DiagnosticBhiSnapshot.compose({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    DateTime? frozenAt,
  }) =>
      DiagnosticBhiSnapshot(
        metrics: metrics,
        model: model,
        frozenPillars: BhiPillarFrozenSnapshot.freeze(model, moment: frozenAt),
      );

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['frozen_pillars'] != null) {
      return _$DiagnosticBhiSnapshotFromJson(json);
    }
    final model = DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>);
    return DiagnosticBhiSnapshot(
      metrics: DiagnosticMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      model: model,
      frozenPillars: BhiPillarFrozenSnapshot.freeze(model),
    );
  }

  Map<String, dynamic> toJson() => _$DiagnosticBhiSnapshotToJson(this);
}
