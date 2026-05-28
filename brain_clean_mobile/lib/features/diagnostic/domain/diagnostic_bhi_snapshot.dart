import 'bhi_pillar_frozen_snapshot.dart';
import 'bhi_pillar_json_keys.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_metrics_mapper.dart';
import 'diagnostic_model.dart';
import 'pillar_bound_evaluation.dart';

/// Slider inputs, live model, and frozen pillar snapshot for a diagnostic session.
class DiagnosticBhiSnapshot {
  const DiagnosticBhiSnapshot({
    required this.metrics,
    required this.model,
    required this.frozenPillars,
  });

  final DiagnosticMetrics metrics;
  final DiagnosticModel model;
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

  static void _assertEmbeddedPenaltyMatchesRoot({
    required Map<String, dynamic> json,
    required double embeddedPenalty,
  }) {
    final rootPenalty = BhiPillarJsonKeys.readPenalty(json);
    if (rootPenalty == 0 && embeddedPenalty == 0) return;
    PillarBoundEvaluation.requireScoresMatch(
      stored: rootPenalty,
      recomputed: embeddedPenalty,
      layer: 'DiagnosticBhiSnapshot.${BhiPillarJsonKeys.recoveryPenaltyDeduction}',
    );
  }

  factory DiagnosticBhiSnapshot.fromJson(Map<String, dynamic> json) {
    final normalized = BhiPillarJsonKeys.normalizeIncoming(json);
    final frozenRaw = BhiPillarJsonKeys.readFrozenPillarsMap(normalized);
    if (frozenRaw != null) {
      final frozen = BhiPillarFrozenSnapshot.fromJson(frozenRaw);
      _assertEmbeddedPenaltyMatchesRoot(
        json: normalized,
        embeddedPenalty: frozen.recoveryPenaltyDeduction,
      );
      return DiagnosticBhiSnapshot._coherent(
        metrics: DiagnosticMetrics.fromJson(
          BhiPillarJsonKeys.requireMap(normalized, BhiPillarJsonKeys.metrics),
        ),
        model: DiagnosticModel.fromJson(
          BhiPillarJsonKeys.requireMap(normalized, BhiPillarJsonKeys.model),
        ),
        frozenPillars: frozen,
      );
    }
    return DiagnosticBhiSnapshot.compose(
      metrics: DiagnosticMetrics.fromJson(
        BhiPillarJsonKeys.requireMap(normalized, BhiPillarJsonKeys.metrics),
      ),
      model: DiagnosticModel.fromJson(
        BhiPillarJsonKeys.requireMap(normalized, BhiPillarJsonKeys.model),
      ),
      recoveryPenaltyDeduction: BhiPillarJsonKeys.readPenalty(normalized),
    );
  }

  Map<String, dynamic> toJson() {
    ensurePillarBoundCoherence();
    final map = <String, dynamic>{
      BhiPillarJsonKeys.metrics: metrics.toJson(),
      BhiPillarJsonKeys.model: model.toJson(),
      BhiPillarJsonKeys.frozenPillars: frozenPillars.toJson(),
    };
    BhiPillarJsonKeys.writePenaltyEnvelope(
      map,
      recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      pillarMatrixBcScore: pillarMatrixBcScore,
      boundBcScore: boundBcScore,
    );
    return map;
  }
}
