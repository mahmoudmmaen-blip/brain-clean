import 'package:json_annotation/json_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
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
    this.recoveryPenaltyDeduction = 0,
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

  /// Cumulative BC_score accountability from 30-day recovery penalty box (−15 each).
  @JsonKey(name: 'recovery_penalty_deduction', defaultValue: 0)
  final double recoveryPenaltyDeduction;

  bool get hasRecoveryPenalty => recoveryPenaltyDeduction > 0;

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

  /// Weighted pillar matrix before recovery penalties.
  double get pillarMatrixBcScore => computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  /// Authoritative score after recovery accountability deductions.
  static double effectiveBcScore({
    required double brainPerformance,
    required double digitalDiscipline,
    required double healthyHabits,
    required double consistency,
    double recoveryPenaltyDeduction = 0,
  }) {
    final matrix = computeBcScore(
      brainPerformance: brainPerformance,
      digitalDiscipline: digitalDiscipline,
      healthyHabits: healthyHabits,
      consistency: consistency,
    );
    final penalized = matrix - recoveryPenaltyDeduction;
    if (penalized < BcScoreConstants.bhiScoreFloor) {
      return BcScoreConstants.bhiScoreFloor;
    }
    return penalized.clamp(0.0, 100.0);
  }

  double get recomputedBcScore => effectiveBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
        recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      );

  bool get isCoherent =>
      PillarBoundEvaluation.scoresMatch(bcScore, recomputedBcScore);

  void ensureCoherent() => PillarBoundEvaluation.requireScoresMatch(
        stored: bcScore,
        recomputed: recomputedBcScore,
        layer: 'BhiPillarFrozenSnapshot',
      );

  BhiPillarFrozenSnapshot copyWith({
    double? brainPerformance,
    double? digitalDiscipline,
    double? healthyHabits,
    double? consistency,
    double? bcScore,
    DateTime? frozenAt,
    double? recoveryPenaltyDeduction,
  }) {
    final nextPenalty = recoveryPenaltyDeduction ?? this.recoveryPenaltyDeduction;
    return BhiPillarFrozenSnapshot(
      brainPerformance: brainPerformance ?? this.brainPerformance,
      digitalDiscipline: digitalDiscipline ?? this.digitalDiscipline,
      healthyHabits: healthyHabits ?? this.healthyHabits,
      consistency: consistency ?? this.consistency,
      bcScore: bcScore ??
          effectiveBcScore(
            brainPerformance: brainPerformance ?? this.brainPerformance,
            digitalDiscipline: digitalDiscipline ?? this.digitalDiscipline,
            healthyHabits: healthyHabits ?? this.healthyHabits,
            consistency: consistency ?? this.consistency,
            recoveryPenaltyDeduction: nextPenalty,
          ),
      frozenAt: frozenAt ?? this.frozenAt,
      recoveryPenaltyDeduction: nextPenalty,
    );
  }

  factory BhiPillarFrozenSnapshot.fromEvaluation(
    PillarBoundEvaluation evaluation, {
    DateTime? moment,
    double recoveryPenaltyDeduction = 0,
  }) {
    evaluation.ensureCoherent();
    final effective = effectiveBcScore(
      brainPerformance: evaluation.brainPerformance,
      digitalDiscipline: evaluation.digitalDiscipline,
      healthyHabits: evaluation.healthyHabits,
      consistency: evaluation.consistency,
      recoveryPenaltyDeduction: recoveryPenaltyDeduction,
    );
    PillarBoundEvaluation.requireScoresMatch(
      stored: effective,
      recomputed: effective,
      layer: 'BhiPillarFrozenSnapshot.fromEvaluation',
    );
    return BhiPillarFrozenSnapshot(
      brainPerformance: evaluation.brainPerformance,
      digitalDiscipline: evaluation.digitalDiscipline,
      healthyHabits: evaluation.healthyHabits,
      consistency: evaluation.consistency,
      bcScore: effective,
      frozenAt: moment ?? DateTime.now(),
      recoveryPenaltyDeduction: recoveryPenaltyDeduction,
    );
  }

  factory BhiPillarFrozenSnapshot.freeze(
    DiagnosticModel model, {
    DateTime? moment,
    double recoveryPenaltyDeduction = 0,
  }) =>
      BhiPillarFrozenSnapshot.fromEvaluation(
        PillarBoundEvaluation.fromModel(model),
        moment: moment,
        recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      );

  DiagnosticModel toModel() => DiagnosticModel(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  factory BhiPillarFrozenSnapshot.fromJson(Map<String, dynamic> json) {
    final penalty = (json['recovery_penalty_deduction'] as num?)?.toDouble() ?? 0;
    final evaluation = PillarBoundEvaluation.coherent(
      brainPerformance: (json['brain_performance'] as num).toDouble(),
      digitalDiscipline: (json['digital_discipline'] as num).toDouble(),
      healthyHabits: (json['healthy_habits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
    );
    final effective = effectiveBcScore(
      brainPerformance: evaluation.brainPerformance,
      digitalDiscipline: evaluation.digitalDiscipline,
      healthyHabits: evaluation.healthyHabits,
      consistency: evaluation.consistency,
      recoveryPenaltyDeduction: penalty,
    );
    final storedBc = (json['bc_score'] as num?)?.toDouble() ?? effective;
    PillarBoundEvaluation.requireScoresMatch(
      stored: storedBc,
      recomputed: effective,
      layer: 'BhiPillarFrozenSnapshot.fromJson',
    );
    return BhiPillarFrozenSnapshot.fromEvaluation(
      evaluation,
      moment: DateTime.parse(json['frozen_at'] as String),
      recoveryPenaltyDeduction: penalty,
    );
  }

  Map<String, dynamic> toJson() {
    ensureCoherent();
    return _$BhiPillarFrozenSnapshotToJson(this);
  }
}
