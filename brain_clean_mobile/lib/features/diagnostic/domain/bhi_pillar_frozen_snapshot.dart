import 'package:json_annotation/json_annotation.dart';

import 'diagnostic_model.dart';

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

  /// Locks the four pillars and BC_score from [model] at [moment].
  factory BhiPillarFrozenSnapshot.freeze(
    DiagnosticModel model, {
    DateTime? moment,
  }) {
    final at = moment ?? DateTime.now();
    return BhiPillarFrozenSnapshot(
      brainPerformance: model.brainPerformance,
      digitalDiscipline: model.digitalDiscipline,
      healthyHabits: model.healthyHabits,
      consistency: model.consistency,
      bcScore: model.calculateBcScore(),
      frozenAt: at,
    );
  }

  DiagnosticModel toModel() => DiagnosticModel(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  factory BhiPillarFrozenSnapshot.fromJson(Map<String, dynamic> json) =>
      _$BhiPillarFrozenSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$BhiPillarFrozenSnapshotToJson(this);
}
