import 'package:json_annotation/json_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';

part 'diagnostic_model.g.dart';

/// BHI pillars (0–100 each) plus 7-Day Dopamine Detox Protocol habit metrics.
@JsonSerializable()
class DiagnosticModel {
  const DiagnosticModel({
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
    this.boredomBefriended = false,
    this.delayedGratificationCount = 0,
    this.bodyActivated = false,
  });

  /// 0–100
  final double brainPerformance;

  /// 0–100
  final double digitalDiscipline;

  /// 0–100
  final double healthyHabits;

  /// 0–100
  final double consistency;

  /// Day habit: user sat with boredom without reaching for a screen.
  @JsonKey(name: 'boredom_befriended')
  final bool boredomBefriended;

  /// Cumulative delayed-gratification wins during the 7-day protocol.
  @JsonKey(name: 'delayed_gratification_count')
  final int delayedGratificationCount;

  /// Day habit: physical movement / body activation completed.
  @JsonKey(name: 'body_activated')
  final bool bodyActivated;

  /// Normalized Brain Clarity Score \[0, 100\] with 26.8 floor.
  double get bcScore => calculateBcScore();

  int get bcScoreRounded => bcScore.round();

  /// Brain Clarity Score (BHI) — weighted pillars with relapse floor.
  ///
  /// Weights: 35% performance, 30% digital discipline, 25% habits, 10% consistency.
  double calculateBcScore() {
    final score = (brainPerformance * BcScoreConstants.brainPerformanceWeight) +
        (digitalDiscipline * BcScoreConstants.digitalDisciplineWeight) +
        (healthyHabits * BcScoreConstants.healthyHabitsWeight) +
        (consistency * BcScoreConstants.consistencyWeight);

    if (score < BcScoreConstants.bhiScoreFloor) {
      return BcScoreConstants.bhiScoreFloor;
    }
    return score.clamp(0.0, 100.0);
  }

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticModelToJson(this);
}
