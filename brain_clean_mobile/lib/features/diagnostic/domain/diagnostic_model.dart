import 'package:json_annotation/json_annotation.dart';

part 'diagnostic_model.g.dart';

/// BHI pillars (0–100 each) for weighted Brain Clarity Score.
@JsonSerializable()
class DiagnosticModel {
  const DiagnosticModel({
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
  });

  /// 0–100
  final double brainPerformance;

  /// 0–100
  final double digitalDiscipline;

  /// 0–100
  final double healthyHabits;

  /// 0–100
  final double consistency;

  /// Normalized Brain Clarity Score \[0, 100\] with 26.8 floor.
  double get bcScore => calculateBcScore();

  int get bcScoreRounded => bcScore.round();

  /// Brain Clarity Score (BHI) — weighted pillars with relapse floor.
  ///
  /// Weights: 35% performance, 30% digital discipline, 25% habits, 10% consistency.
  double calculateBcScore() {
    final score = (brainPerformance * 0.35) +
        (digitalDiscipline * 0.30) +
        (healthyHabits * 0.25) +
        (consistency * 0.10);

    // Theoretical range floor (26.8) for behavioral gradient stability.
    if (score < 26.8) return 26.8;
    return score.clamp(0.0, 100.0);
  }

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticModelToJson(this);
}
