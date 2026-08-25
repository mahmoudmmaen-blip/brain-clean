import 'structured_daily_activity.dart';

/// Named adaptive program tracks driven by BRI + cognitive scores.
enum AdaptiveProgramProtocol {
  /// Free baseline when no diagnosis signal.
  base,

  /// "Reset Protocol" — Free (capped) + Pro (full weeks).
  resetProtocol,

  /// "Neural Ascension" — Pro only (weak cognition / high BRI).
  neuralAscension,

  /// "Enhanced Mind" — Pro only (healthy scores, wants improvement).
  enhancedMind,
}

extension AdaptiveProgramProtocolX on AdaptiveProgramProtocol {
  String get titleKey => switch (this) {
        AdaptiveProgramProtocol.base => 'adaptiveProgramBaseTitle',
        AdaptiveProgramProtocol.resetProtocol => 'adaptiveProgramResetTitle',
        AdaptiveProgramProtocol.neuralAscension =>
          'adaptiveProgramAscensionTitle',
        AdaptiveProgramProtocol.enhancedMind =>
          'adaptiveProgramEnhancedMindTitle',
      };

  String get goalKey => switch (this) {
        AdaptiveProgramProtocol.base => 'adaptiveProgramBaseGoal',
        AdaptiveProgramProtocol.resetProtocol => 'adaptiveProgramResetGoal',
        AdaptiveProgramProtocol.neuralAscension =>
          'adaptiveProgramAscensionGoal',
        AdaptiveProgramProtocol.enhancedMind =>
          'adaptiveProgramEnhancedMindGoal',
      };

  bool get isProOnly =>
      this == AdaptiveProgramProtocol.neuralAscension ||
      this == AdaptiveProgramProtocol.enhancedMind;
}

/// How the user felt after today's session.
enum AdaptiveSessionFeeling {
  hard,
  ok,
  easy,
}

/// Difficulty offset applied to tomorrow's generation (−1 … +1).
int feelingDifficultyDelta(AdaptiveSessionFeeling feeling) {
  return switch (feeling) {
    AdaptiveSessionFeeling.hard => -1,
    AdaptiveSessionFeeling.ok => 0,
    AdaptiveSessionFeeling.easy => 1,
  };
}

/// Snapshot of engine output for UI + completions.
class AdaptiveProgramPlan {
  const AdaptiveProgramPlan({
    required this.protocol,
    required this.protocolWeek,
    required this.weekGoalKey,
    required this.activities,
    required this.showWeekendChallenge,
    required this.difficultyLevel,
    this.freeResetComplete = false,
    this.showUpgradeStrip = false,
    this.isFreeTier = false,
  });

  final AdaptiveProgramProtocol protocol;

  /// 1-based week inside the active protocol track.
  final int protocolWeek;
  final String weekGoalKey;
  final List<StructuredDailyActivity> activities;
  final bool showWeekendChallenge;

  /// 0 = easy, 1 = medium, 2 = hard (gated by week + feedback).
  final int difficultyLevel;

  /// Free Reset finished its 4 weeks (does not repeat).
  final bool freeResetComplete;

  /// Show daily Pro upgrade strip on Home program section.
  final bool showUpgradeStrip;

  final bool isFreeTier;
}
