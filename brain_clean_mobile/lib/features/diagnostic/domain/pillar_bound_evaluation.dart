import '../../../core/constants/bc_score_constants.dart';
import 'bhi_pillar_frozen_snapshot.dart';

/// Strict four-pillar evaluation matrix — single path for score + contributions.
class PillarBoundEvaluation {
  const PillarBoundEvaluation({
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
    required this.bcScore,
  });

  final double brainPerformance;
  final double digitalDiscipline;
  final double healthyHabits;
  final double consistency;
  final double bcScore;

  static const double brainWeight = BcScoreConstants.brainPerformanceWeight;
  static const double digitalWeight = BcScoreConstants.digitalDisciplineWeight;
  static const double habitsWeight = BcScoreConstants.healthyHabitsWeight;
  static const double consistencyWeight = BcScoreConstants.consistencyWeight;

  double get brainContribution => brainPerformance * brainWeight;
  double get digitalContribution => digitalDiscipline * digitalWeight;
  double get habitsContribution => healthyHabits * habitsWeight;
  double get consistencyContribution => consistency * consistencyWeight;

  double get recomputedBcScore => BhiPillarFrozenSnapshot.computeBcScore(
        brainPerformance: brainPerformance,
        digitalDiscipline: digitalDiscipline,
        healthyHabits: healthyHabits,
        consistency: consistency,
      );

  bool get isCoherent => (bcScore - recomputedBcScore).abs() < 0.001;

  factory PillarBoundEvaluation.fromFrozen(BhiPillarFrozenSnapshot frozen) =>
      PillarBoundEvaluation(
        brainPerformance: frozen.brainPerformance,
        digitalDiscipline: frozen.digitalDiscipline,
        healthyHabits: frozen.healthyHabits,
        consistency: frozen.consistency,
        bcScore: frozen.bcScore,
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
