import 'localized_text.dart';

/// Weekly tips keyed by goal id from `goal_tips.json`.
class GoalTipsContent {
  const GoalTipsContent(this._byGoal);

  /// goalId → week (1..4) → tip text.
  final Map<String, Map<int, LocalizedText>> _byGoal;

  static const fallbackGoal = 'less_scroll';

  factory GoalTipsContent.fromJson(Map<String, dynamic> json) {
    final goalsRaw = json['goals'];
    if (goalsRaw is! Map) {
      throw const FormatException('goal_tips.json missing goals object');
    }
    final goals = Map<String, dynamic>.from(goalsRaw);
    final out = <String, Map<int, LocalizedText>>{};
    for (final entry in goals.entries) {
      final weeksRaw = entry.value;
      if (weeksRaw is! Map) {
        throw FormatException('goal_tips goals.${entry.key} must be an object');
      }
      final weeks = <int, LocalizedText>{};
      for (final weekEntry in Map<String, dynamic>.from(weeksRaw).entries) {
        final week = int.tryParse(weekEntry.key);
        if (week == null) {
          throw FormatException(
            'goal_tips goals.${entry.key} has non-int week key ${weekEntry.key}',
          );
        }
        weeks[week] = LocalizedText.fromJson(
          weekEntry.value,
          path: 'goal_tips.goals.${entry.key}.$week',
        );
      }
      out[entry.key] = weeks;
    }
    if (!out.containsKey(fallbackGoal)) {
      throw const FormatException(
        'goal_tips.json must include fallback goal less_scroll',
      );
    }
    return GoalTipsContent(out);
  }

  /// Maps stored [UserProfile.goal] values onto JSON goal ids.
  static String mapProfileGoal(String profileGoal) {
    switch (profileGoal) {
      case 'browse':
        return 'less_scroll';
      case 'focus':
      case 'sleep':
      case 'calm':
      case 'less_scroll':
        return profileGoal;
      default:
        return fallbackGoal;
    }
  }

  /// Tip for [goal] and [week] (1..4). Falls back to [fallbackGoal], locale `en`.
  String tip({
    required String goal,
    required int week,
    String locale = 'en',
  }) {
    final cappedWeek = week < 1 ? 1 : (week > 4 ? 4 : week);
    final mapped = mapProfileGoal(goal);
    final goalTips = _byGoal[mapped] ?? _byGoal[fallbackGoal]!;
    final text = goalTips[cappedWeek] ??
        _byGoal[fallbackGoal]![cappedWeek] ??
        _byGoal[fallbackGoal]!.values.first;
    return text.resolve(locale);
  }

  /// All JSON goal ids (for integrity tests).
  Iterable<String> get goalIds => _byGoal.keys;
}
