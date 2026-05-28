import 'package:json_annotation/json_annotation.dart';

import 'diagnostic_model.dart';
import 'pillar_bound_evaluation.dart';

part 'bhi_pillar_frozen_snapshot.g.dart';

/// Immutable BHI pillar values captured at session commit (or live preview).
@JsonSerializable()
class BhiPillarFrozenSnapshot {
  const BhiPillarFrozenSnapshot({
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
    required this.bcScore,
    required this.frozenAt,
  });

  @JsonKey(name: 'brain_performance')
  final double brainPerformance;

  @JsonKey(name: 'digital_discipline')
  final double digitalDiscipline;

  @JsonKey(name: 'healthy_habits')
  final double healthyHabits;

  final double consistency;

  @JsonKey(name: 'bc_score')
  final double bcScore;

  @JsonKey(name: 'frozen_at')
  final DateTime frozenAt;

  static double computeBcScore({
    required double brainPerformance,
    required double digitalDiscipline,
    required double healthyHabits,
    required double consistency,
  }) =>
      PillarBoundEvaluation.computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  double get recomputedBcScore => computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  bool get isCoherent =>
      PillarBoundEvaluation.scoresMatch(bcScore, recomputedBcScore);

  void ensureCoherent() => PillarBoundEvaluation.requireScoresMatch(
        stored: bcScore,
        recomputed: recomputedBcScore,
        layer: 'BhiPillarFrozenSnapshot',
      );

  factory BhiPillarFrozenSnapshot.fromEvaluation(
    PillarBoundEvaluation evaluation, {
    DateTime? moment,
  }) {
    evaluation.ensureCoherent();
    return BhiPillarFrozenSnapshot(
      brainPerformance: evaluation.brainPerformance,
      digitalDiscipline: evaluation.digitalDiscipline,
      healthyHabits: evaluation.healthyHabits,
      consistency: evaluation.consistency,
      bcScore: evaluation.bcScore,
      frozenAt: moment ?? DateTime.now(),
    );
  }

  factory BhiPillarFrozenSnapshot.freeze(
    DiagnosticModel model, {
    DateTime? moment,
  }) =>
      BhiPillarFrozenSnapshot.fromEvaluation(
        PillarBoundEvaluation.fromModel(model),
        moment: moment,
      );

  DiagnosticModel toModel() => DiagnosticModel(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  factory BhiPillarFrozenSnapshot.fromJson(Map<String, dynamic> json) {
    final evaluation = PillarBoundEvaluation.coherent(
      brainPerformance: (json['brain_performance'] as num).toDouble(),
      digitalDiscipline: (json['digital_discipline'] as num).toDouble(),
      healthyHabits: (json['healthy_habits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
    );
    final storedBc = (json['bc_score'] as num?)?.toDouble();
    if (storedBc != null) {
      PillarBoundEvaluation.requireScoresMatch(
        stored: storedBc,
        recomputed: evaluation.bcScore,
        layer: 'BhiPillarFrozenSnapshot.fromJson',
      );
    }
    return BhiPillarFrozenSnapshot.fromEvaluation(
      evaluation,
      moment: DateTime.parse(json['frozen_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    ensureCoherent();
    return _$BhiPillarFrozenSnapshotToJson(this);
  }
}
