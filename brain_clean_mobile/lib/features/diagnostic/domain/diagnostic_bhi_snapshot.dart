import 'package:json_annotation/json_annotation.dart';

import 'bhi_pillar_frozen_snapshot.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_metrics_mapper.dart';
import 'diagnostic_model.dart';
import 'pillar_bound_evaluation.dart';

part 'diagnostic_bhi_snapshot.g.dart';

/// Slider inputs, live model, and frozen pillar snapshot for a diagnostic session.
@JsonSerializable(explicitToJson: true)
class DiagnosticBhiSnapshot {
  const DiagnosticBhiSnapshot({
    required this.metrics,
    required this.model,
    required this.frozenPillars,
  });

  final DiagnosticMetrics metrics;
  final DiagnosticModel model;

  @JsonKey(name: 'frozen_pillars')
  final BhiPillarFrozenSnapshot frozenPillars;

  DiagnosticModel get mappedFromMetrics =>
      DiagnosticMetricsMapper.fromMetrics(metrics);

  /// Validated matrix — [bcScore] always recomputed from frozen pillars.
  PillarBoundEvaluation get pillarEvaluation =>
      PillarBoundEvaluation.fromFrozen(frozenPillars);

  DiagnosticModel get pillarModel => pillarEvaluation.toPillarModel();

  double get boundBcScore => pillarEvaluation.bcScore;

  double get frozenBcScore => boundBcScore;

  bool get isPillarBoundCoherent =>
      frozenPillars.isCoherent && pillarEvaluation.isCoherent;

  factory DiagnosticBhiSnapshot.compose({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    DateTime? frozenAt,
  }) {
    final evaluation = PillarBoundEvaluation.fromModel(model);
    final frozen = BhiPillarFrozenSnapshot.fromEvaluation(
      evaluation,
      moment: frozenAt,
    );
    final snapshot = DiagnosticBhiSnapshot(
      metrics: metrics,
      model: model,
      frozenPillars: frozen,
    );
    snapshot.ensurePillarBoundCoherence();
    return snapshot;
  }

  void ensurePillarBoundCoherence() {
    pillarEvaluation.ensureCoherent();
    if (!isPillarBoundCoherent) {
      throw StateError(
        'DiagnosticBhiSnapshot pillar-bound mismatch: '
        'frozen=${frozenPillars.bcScore} matrix=${pillarEvaluation.bcScore}',
      );
    }
  }

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['frozen_pillars'] != null) {
      final metrics = DiagnosticMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      );
      final model =
          DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>);
      final frozen = BhiPillarFrozenSnapshot.fromJson(
        json['frozen_pillars'] as Map<String, dynamic>,
      );
      final snapshot = DiagnosticBhiSnapshot(
        metrics: metrics,
        model: model,
        frozenPillars: frozen,
      );
      snapshot.ensurePillarBoundCoherence();
      return snapshot;
    }
    final model = DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>);
    return DiagnosticBhiSnapshot.compose(
      metrics: DiagnosticMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      model: model,
    );
  }

  Map<String, dynamic> toJson() => _$DiagnosticBhiSnapshotToJson(this);
}
