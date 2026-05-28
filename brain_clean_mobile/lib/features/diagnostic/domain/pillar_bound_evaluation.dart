import '../../../core/constants/bc_score_constants.dart';
import 'bhi_pillar_frozen_snapshot.dart';
import 'bhi_score_formula.dart';
import 'diagnostic_model.dart';

/// Strict four-pillar evaluation matrix — single path for score + contributions.
class PillarBoundEvaluation {
  const PillarBoundEvaluation({
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
    required this.bcScore,
  });

  /// High-precision tolerance for stored vs. recomputed BC_score (IEEE-754 safe).
  static const double coherenceEpsilon = 1e-7;

  final double brainPerformance;
  final double digitalDiscipline;
  final double healthyHabits;
  final double consistency;
  final double bcScore;

  static const double brainWeight = BcScoreConstants.brainPerformanceWeight;
  static const double digitalWeight = BcScoreConstants.digitalDisciplineWeight;
  static const double habitsWeight = BcScoreConstants.healthyHabitsWeight;
  static const double consistencyWeight = BcScoreConstants.consistencyWeight;

  static bool scoresMatch(double stored, double recomputed) =>
      (stored - recomputed).abs() < coherenceEpsilon;

  /// Uniform guard used across snapshot, BHI, and session layers.
  static void requireScoresMatch({
    required double stored,
    required double recomputed,
    required String layer,
  }) {
    if (!scoresMatch(stored, recomputed)) {
      throw StateError(
        '$layer coherence failed (ε=$coherenceEpsilon): '
        'stored=$stored recomputed=$recomputed',
      );
    }
  }

  double get brainContribution => brainPerformance * brainWeight;
  double get digitalContribution => digitalDiscipline * digitalWeight;
  double get habitsContribution => healthyHabits * habitsWeight;
  double get consistencyContribution => consistency * consistencyWeight;

  static double computeBcScore({
    required double brainPerformance,
    required double digitalDiscipline,
    required double healthyHabits,
    required double consistency,
  }) =>
      BhiScoreFormula.compute(
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

  bool get isCoherent => scoresMatch(bcScore, recomputedBcScore);

  factory PillarBoundEvaluation.coherent({
    required double brainPerformance,
    required double digitalDiscipline,
    required double healthyHabits,
    required double consistency,
  }) =>
      PillarBoundEvaluation(
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
      );

  factory PillarBoundEvaluation.fromModel(DiagnosticModel model) =>
      PillarBoundEvaluation.coherent(
        brainPerformance: model.brainPerformance,
        digitalDiscipline: model.digitalDiscipline,
        healthyHabits: model.healthyHabits,
        consistency: model.consistency,
      );

  factory PillarBoundEvaluation.fromFrozen(BhiPillarFrozenSnapshot frozen) =>
      PillarBoundEvaluation.coherent(
        brainPerformance: frozen.brainPerformance,
        digitalDiscipline: frozen.digitalDiscipline,
        healthyHabits: frozen.healthyHabits,
        consistency: frozen.consistency,
      );

  void ensureCoherent() => requireScoresMatch(
        stored: bcScore,
        recomputed: recomputedBcScore,
        layer: 'PillarBoundEvaluation',
      );

  DiagnosticModel toPillarModel() => DiagnosticModel(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  List<({String key, double score, double weight, double contribution})>
      get pillarRows => [
            (
              key: 'brain_performance',
              score: brainPerformance,
              weight: brainWeight,
              contribution: brainContribution,
            ),
            (
              key: 'digital_discipline',
              score: digitalDiscipline,
              weight: digitalWeight,
              contribution: digitalContribution,
            ),
            (
              key: 'healthy_habits',
              score: healthyHabits,
              weight: habitsWeight,
              contribution: habitsContribution,
            ),
            (
              key: 'consistency',
              score: consistency,
              weight: consistencyWeight,
              contribution: consistencyContribution,
            ),
          ];
}
