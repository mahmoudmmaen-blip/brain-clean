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

  PillarBoundEvaluation get pillarEvaluation =>
      PillarBoundEvaluation.fromFrozen(frozenPillars);

  DiagnosticModel get pillarModel => pillarEvaluation.toPillarModel();

  double get boundBcScore => pillarEvaluation.bcScore;

  double get frozenBcScore => boundBcScore;

  bool get isPillarBoundCoherent =>
      frozenPillars.isCoherent &&
      pillarEvaluation.isCoherent &&
      PillarBoundEvaluation.scoresMatch(
        frozenPillars.bcScore,
        pillarEvaluation.bcScore,
      );

  /// Live or commit path: metrics + model → frozen pillars → validated snapshot.
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
    return DiagnosticBhiSnapshot._emit(
      metrics: metrics,
      model: model,
      frozenPillars: frozen,
    );
  }

  factory DiagnosticBhiSnapshot._emit({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    required BhiPillarFrozenSnapshot frozenPillars,
  }) {
    final snapshot = DiagnosticBhiSnapshot(
      metrics: metrics,
      model: model,
      frozenPillars: frozenPillars,
    );
    snapshot.ensurePillarBoundCoherence();
    return snapshot;
  }

  void ensurePillarBoundCoherence() {
    pillarEvaluation.ensureCoherent();
    if (!isPillarBoundCoherent) {
      throw StateError(
        'DiagnosticBhiSnapshot coherence failed (ε=${PillarBoundEvaluation.coherenceEpsilon}): '
        'frozen=${frozenPillars.bcScore} matrix=${pillarEvaluation.bcScore} '
        'recomputed=${frozenPillars.recomputedBcScore}',
      );
    }
  }

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['frozen_pillars'] != null) {
      return DiagnosticBhiSnapshot._emit(
        metrics: DiagnosticMetrics.fromJson(
          json['metrics'] as Map<String, dynamic>,
        ),
        model: DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>),
        frozenPillars: BhiPillarFrozenSnapshot.fromJson(
          json['frozen_pillars'] as Map<String, dynamic>,
        ),
      );
    }
    return DiagnosticBhiSnapshot.compose(
      metrics: DiagnosticMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      model: DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => _$DiagnosticBhiSnapshotToJson(this);
}
