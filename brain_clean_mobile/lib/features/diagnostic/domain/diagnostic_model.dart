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

/// Parses a detox habit field: Firestore snake_case → camelCase → [defaultValue].
T _parseHabitMetric<T>(
  Map<dynamic, dynamic> json, {
  required String snakeKey,
  required String camelKey,
  required T defaultValue,
}) {
  if (json.containsKey(snakeKey)) {
    return _coerceHabitValue(json[snakeKey], defaultValue);
  }
  if (json.containsKey(camelKey)) {
    return _coerceHabitValue(json[camelKey], defaultValue);
  }
  return defaultValue;
}

T _coerceHabitValue<T>(Object? raw, T defaultValue) {
  if (raw == null) return defaultValue;
  if (defaultValue is bool) return (raw as bool) as T;
  if (defaultValue is int) return (raw as num).toInt() as T;
  return raw as T;
}

Object? _readBoredomBefriended(Map<dynamic, dynamic> json, String key) =>
    _parseHabitMetric<bool>(
      json,
      snakeKey: DiagnosticModelJsonKeys.boredomBefriendedSnake,
      camelKey: DiagnosticModelJsonKeys.boredomBefriendedCamel,
      defaultValue: false,
    );

Object? _readDelayedGratificationCount(Map<dynamic, dynamic> json, String key) =>
    _parseHabitMetric<int>(
      json,
      snakeKey: DiagnosticModelJsonKeys.delayedGratificationCountSnake,
      camelKey: DiagnosticModelJsonKeys.delayedGratificationCountCamel,
      defaultValue: 0,
    );

Object? _readBodyActivated(Map<dynamic, dynamic> json, String key) =>
    _parseHabitMetric<bool>(
      json,
      snakeKey: DiagnosticModelJsonKeys.bodyActivatedSnake,
      camelKey: DiagnosticModelJsonKeys.bodyActivatedCamel,
      defaultValue: false,
    );

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
  @JsonKey(
    name: DiagnosticModelJsonKeys.boredomBefriendedSnake,
    defaultValue: false,
    readValue: _readBoredomBefriended,
  )
  final bool boredomBefriended;

  /// Cumulative delayed-gratification wins during the 7-day protocol.
  @JsonKey(
    name: DiagnosticModelJsonKeys.delayedGratificationCountSnake,
    defaultValue: 0,
    readValue: _readDelayedGratificationCount,
  )
  final int delayedGratificationCount;

  /// Day habit: physical movement / body activation completed.
  @JsonKey(
    name: DiagnosticModelJsonKeys.bodyActivatedSnake,
    defaultValue: false,
    readValue: _readBodyActivated,
  )
  final bool bodyActivated;

  /// Normalized Brain Clarity Score \[0, 100\] with 26.8 floor.
  double get bcScore => calculateBcScore();

  int get bcScoreRounded => bcScore.round();

  /// Habits pillar slice of BHI (25% weight), after detox integration.
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

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticModelToJson(this);
}
