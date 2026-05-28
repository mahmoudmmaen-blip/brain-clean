import 'package:json_annotation/json_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
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

  /// Single source of truth — BC_score from the four frozen pillars only.
  static double computeBcScore({
    required double brainPerformance,
    required double digitalDiscipline,
    required double healthyHabits,
    required double consistency,
  }) {
    final raw = (brainPerformance * BcScoreConstants.brainPerformanceWeight) +
        (digitalDiscipline * BcScoreConstants.digitalDisciplineWeight) +
        (healthyHabits * BcScoreConstants.healthyHabitsWeight) +
        (consistency * BcScoreConstants.consistencyWeight);

    if (raw < BcScoreConstants.bhiScoreFloor) {
      return BcScoreConstants.bhiScoreFloor;
    }
    return raw.clamp(0.0, 100.0);
  }

  /// Recomputes [bcScore] from stored pillars (coherence validation).
  double get recomputedBcScore => computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  bool get isCoherent => (recomputedBcScore - bcScore).abs() < 0.001;

  /// Locks pillars then derives [bcScore] strictly from those values.
  factory BhiPillarFrozenSnapshot.freeze(
    DiagnosticModel model, {
    DateTime? moment,
  }) {
    final at = moment ?? DateTime.now();
    final brainPerformance = model.brainPerformance;
    final digitalDiscipline = model.digitalDiscipline;
    final healthyHabits = model.healthyHabits;
    final consistency = model.consistency;

    return BhiPillarFrozenSnapshot(
      brainPerformance: brainPerformance,
      digitalDiscipline: digitalDiscipline,
      healthyHabits: healthyHabits,
      consistency: consistency,
      bcScore: computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      ),
      frozenAt: at,
    );
  }

  DiagnosticModel toModel() => DiagnosticModel(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  factory BhiPillarFrozenSnapshot.fromJson(Map<String, dynamic> json) {
    final brainPerformance = (json['brain_performance'] as num).toDouble();
    final digitalDiscipline = (json['digital_discipline'] as num).toDouble();
    final healthyHabits = (json['healthy_habits'] as num).toDouble();
    final consistency = (json['consistency'] as num).toDouble();

    return BhiPillarFrozenSnapshot(
      brainPerformance: brainPerformance,
      digitalDiscipline: digitalDiscipline,
      healthyHabits: healthyHabits,
      consistency: consistency,
      bcScore: computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      ),
      frozenAt: DateTime.parse(json['frozen_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$BhiPillarFrozenSnapshotToJson(this);
}
