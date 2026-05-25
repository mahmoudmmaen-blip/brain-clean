import 'package:json_annotation/json_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';

part 'diagnostic_model.g.dart';

/// Firestore + legacy camelCase JSON keys for detox habit metrics.
abstract final class DiagnosticModelJsonKeys {
  static const boredomBefriendedSnake = 'boredom_befriended';
  static const boredomBefriendedCamel = 'boredomBefriended';
  static const delayedGratificationCountSnake = 'delayed_gratification_count';
  static const delayedGratificationCountCamel = 'delayedGratificationCount';
  static const bodyActivatedSnake = 'body_activated';
  static const bodyActivatedCamel = 'bodyActivated';
}

/// Parses habit metric with strict Firestore snake_case precedence over local
/// camelCase. Falls back to defaultValue if both keys are missing. This ensures
/// Firestore data overrides local cache.
dynamic _parseMetric(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
  dynamic defaultValue,
) {
  if (json.containsKey(snakeKey)) return json[snakeKey];
  if (json.containsKey(camelKey)) return json[camelKey];
  return defaultValue;
}

bool _parseBoolMetric(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
) =>
    _parseMetric(json, snakeKey, camelKey, false) as bool;

int _parseIntMetric(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
) =>
    (_parseMetric(json, snakeKey, camelKey, 0) as num).toInt();

/// BHI pillars (0–100 each) plus 7-Day Dopamine Detox Protocol habit metrics.
@JsonSerializable(createFactory: false)
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
  @JsonKey(name: DiagnosticModelJsonKeys.boredomBefriendedSnake)
  final bool boredomBefriended;

  /// Cumulative delayed-gratification wins during the 7-day protocol.
  @JsonKey(name: DiagnosticModelJsonKeys.delayedGratificationCountSnake)
  final int delayedGratificationCount;

  /// Day habit: physical movement / body activation completed.
  @JsonKey(name: DiagnosticModelJsonKeys.bodyActivatedSnake)
  final bool bodyActivated;

  /// Normalized Brain Clarity Score \[0, 100\] with 26.8 floor.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get bcScore => calculateBcScore();

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get bcScoreRounded => bcScore.round();

  /// Habits pillar slice of BHI (25% weight), after detox integration.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get habitsPillarContribution =>
      healthyHabits * BcScoreConstants.healthyHabitsWeight;

  /// Brain Clarity Score (BHI) — weighted pillars with relapse floor.
  ///
  /// Weights: 35% performance, 30% digital discipline, 25% habits (detox-aware), 10% consistency.
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

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      brainPerformance: (json['brainPerformance'] as num).toDouble(),
      digitalDiscipline: (json['digitalDiscipline'] as num).toDouble(),
      healthyHabits: (json['healthyHabits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      boredomBefriended: _parseBoolMetric(
        json,
        DiagnosticModelJsonKeys.boredomBefriendedSnake,
        DiagnosticModelJsonKeys.boredomBefriendedCamel,
      ),
      delayedGratificationCount: _parseIntMetric(
        json,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel,
      ),
      bodyActivated: _parseBoolMetric(
        json,
        DiagnosticModelJsonKeys.bodyActivatedSnake,
        DiagnosticModelJsonKeys.bodyActivatedCamel,
      ),
    );
  }

  Map<String, dynamic> toJson() => _$DiagnosticModelToJson(this);
}
