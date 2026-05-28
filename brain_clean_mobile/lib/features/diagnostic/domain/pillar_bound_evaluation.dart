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

  /// Tolerance for stored vs. recomputed BC_score (floating-point safe).
  static const double coherenceEpsilon = 1e-5;

  final double brainPerformance;
  final double digitalDiscipline;
  final double healthyHabits;
  final double consistency;
  final double bcScore;

  static const double brainWeight = BcScoreConstants.brainPerformanceWeight;
  static const double digitalWeight = BcScoreConstants.digitalDisciplineWeight;
  static const double habitsWeight = BcScoreConstants.healthyHabitsWeight;
  static const double consistencyWeight = BcScoreConstants.consistencyWeight;

  /// True when [stored] and [recomputed] agree within [coherenceEpsilon].
  static bool scoresMatch(double stored, double recomputed) =>
      (stored - recomputed).abs() < coherenceEpsilon;

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

  /// Declarative matrix: pillars in → [bcScore] from [BhiScoreFormula] only.
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

  /// Live assessment → coherent evaluation (in-progress / compose).
  factory PillarBoundEvaluation.fromModel(DiagnosticModel model) =>
      PillarBoundEvaluation.coherent(
        brainPerformance: model.brainPerformance,
        digitalDiscipline: model.digitalDiscipline,
        healthyHabits: model.healthyHabits,
        consistency: model.consistency,
      );

  /// Historical frozen pillars → coherent evaluation (ignores stale [bcScore]).
  factory PillarBoundEvaluation.fromFrozen(BhiPillarFrozenSnapshot frozen) =>
      PillarBoundEvaluation.coherent(
        brainPerformance: frozen.brainPerformance,
        digitalDiscipline: frozen.digitalDiscipline,
        healthyHabits: frozen.healthyHabits,
        consistency: frozen.consistency,
      );

  void ensureCoherent() {
    if (!isCoherent) {
      throw StateError(
        'PillarBoundEvaluation coherence failed (ε=$coherenceEpsilon): '
        'stored=$bcScore recomputed=$recomputedBcScore',
      );
    }
  }

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
