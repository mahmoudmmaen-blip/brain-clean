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

  /// Authoritative BC_score including recovery accountability deductions.
  double get boundBcScore => frozenPillars.bcScore;

  double get pillarMatrixBcScore => frozenPillars.pillarMatrixBcScore;

  double get recoveryPenaltyDeduction => frozenPillars.recoveryPenaltyDeduction;

  bool get hasRecoveryPenalty => frozenPillars.hasRecoveryPenalty;

  bool get isPillarBoundCoherent =>
      frozenPillars.isCoherent && pillarEvaluation.isCoherent;

  factory DiagnosticBhiSnapshot.compose({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    DateTime? frozenAt,
    double recoveryPenaltyDeduction = 0,
  }) =>
      DiagnosticBhiSnapshot._coherent(
        metrics: metrics,
        model: model,
        frozenPillars: BhiPillarFrozenSnapshot.freeze(
          model,
          moment: frozenAt,
          recoveryPenaltyDeduction: recoveryPenaltyDeduction,
        ),
      );

  /// Rebuilds a coherent snapshot when frozen pillars are updated (e.g. penalties).
  factory DiagnosticBhiSnapshot.withFrozenPillars({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    required BhiPillarFrozenSnapshot frozenPillars,
  }) =>
      DiagnosticBhiSnapshot._coherent(
        metrics: metrics,
        model: model,
        frozenPillars: frozenPillars,
      );

  factory DiagnosticBhiSnapshot._coherent({
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
    frozenPillars.ensureCoherent();
    pillarEvaluation.ensureCoherent();
    if (frozenPillars.recoveryPenaltyDeduction == 0) {
      PillarBoundEvaluation.requireScoresMatch(
        stored: frozenPillars.bcScore,
        recomputed: pillarEvaluation.bcScore,
        layer: 'DiagnosticBhiSnapshot',
      );
    }
  }

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['frozen_pillars'] != null) {
      return DiagnosticBhiSnapshot._coherent(
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

  Map<String, dynamic> toJson() {
    ensurePillarBoundCoherence();
    return _$DiagnosticBhiSnapshotToJson(this);
  }
}
