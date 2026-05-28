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

  /// Pillar values bound to [frozenPillars] — never reads fluid [model] fields.
  DiagnosticModel get pillarModel => pillarEvaluation.toPillarModel();

  /// Strict pillar-bound matrix — single source for score and pillar UI.
  PillarBoundEvaluation get pillarEvaluation =>
      PillarBoundEvaluation.fromFrozen(frozenPillars);

  /// Pillar-bound BC_score (screen, dashboard, repository).
  double get boundBcScore => pillarEvaluation.bcScore;

  double get frozenBcScore => boundBcScore;

  /// True when stored [bcScore] matches recomputation from frozen pillars.
  bool get isPillarBoundCoherent =>
      frozenPillars.isCoherent && pillarEvaluation.isCoherent;

  factory DiagnosticBhiSnapshot.compose({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    DateTime? frozenAt,
  }) {
    final snapshot = DiagnosticBhiSnapshot(
      metrics: metrics,
      model: model,
      frozenPillars: BhiPillarFrozenSnapshot.freeze(model, moment: frozenAt),
    );
    snapshot.ensurePillarBoundCoherence();
    return snapshot;
  }

  void ensurePillarBoundCoherence() {
    if (!isPillarBoundCoherent) {
      throw StateError(
        'DiagnosticBhiSnapshot pillar-bound mismatch: '
        'stored=${frozenPillars.bcScore} recomputed=${pillarEvaluation.recomputedBcScore}',
      );
    }
  }

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) {
    final DiagnosticBhiSnapshot snapshot;
    if (json['frozen_pillars'] != null) {
      snapshot = _$DiagnosticBhiSnapshotFromJson(json);
    } else {
      final model =
          DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>);
      snapshot = DiagnosticBhiSnapshot(
        metrics: DiagnosticMetrics.fromJson(
          json['metrics'] as Map<String, dynamic>,
        ),
        model: model,
        frozenPillars: BhiPillarFrozenSnapshot.freeze(model),
      );
    }
    return snapshot._withCoherentFrozenPillars();
  }

  /// Re-derives [bcScore] from [PillarBoundEvaluation] after deserialization.
  DiagnosticBhiSnapshot _withCoherentFrozenPillars() {
    final evaluation = PillarBoundEvaluation.fromFrozen(frozenPillars);
    final coherent = BhiPillarFrozenSnapshot(
      brainPerformance: evaluation.brainPerformance,
      digitalDiscipline: evaluation.digitalDiscipline,
      healthyHabits: evaluation.healthyHabits,
      consistency: evaluation.consistency,
      bcScore: evaluation.recomputedBcScore,
      frozenAt: frozenPillars.frozenAt,
    );
    final snapshot = DiagnosticBhiSnapshot(
      metrics: metrics,
      model: model,
      frozenPillars: coherent,
    );
    snapshot.ensurePillarBoundCoherence();
    return snapshot;
  }

  Map<String, dynamic> toJson() => _$DiagnosticBhiSnapshotToJson(this);
}
