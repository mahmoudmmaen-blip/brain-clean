/// Human-facing progress summary facts (no diagnosis / recommendations).
class ProgressSummary {
  const ProgressSummary({
    required this.hasHistory,
    required this.firstCompletedSessionId,
    required this.lastCompletedSessionId,
    required this.firstCompletedDayKey,
    required this.lastCompletedDayKey,
    required this.activePlanId,
    required this.profilePackId,
    required this.recoveryScoreModelVersion,
  });

  final bool hasHistory;
  final String? firstCompletedSessionId;
  final String? lastCompletedSessionId;
  final String? firstCompletedDayKey;
  final String? lastCompletedDayKey;

  /// Reference only — never mutates the plan.
  final String? activePlanId;

  /// Reference only — never mutates the profile.
  final String? profilePackId;

  /// Score model stamp when known from plan linkage; never recalculates score.
  final String? recoveryScoreModelVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hasHistory': hasHistory,
        if (firstCompletedSessionId != null)
          'firstCompletedSessionId': firstCompletedSessionId,
        if (lastCompletedSessionId != null)
          'lastCompletedSessionId': lastCompletedSessionId,
        if (firstCompletedDayKey != null)
          'firstCompletedDayKey': firstCompletedDayKey,
        if (lastCompletedDayKey != null)
          'lastCompletedDayKey': lastCompletedDayKey,
        if (activePlanId != null) 'activePlanId': activePlanId,
        if (profilePackId != null) 'profilePackId': profilePackId,
        if (recoveryScoreModelVersion != null)
          'recoveryScoreModelVersion': recoveryScoreModelVersion,
      };

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      hasHistory: json['hasHistory'] as bool? ?? false,
      firstCompletedSessionId: json['firstCompletedSessionId'] as String?,
      lastCompletedSessionId: json['lastCompletedSessionId'] as String?,
      firstCompletedDayKey: json['firstCompletedDayKey'] as String?,
      lastCompletedDayKey: json['lastCompletedDayKey'] as String?,
      activePlanId: json['activePlanId'] as String?,
      profilePackId: json['profilePackId'] as String?,
      recoveryScoreModelVersion:
          json['recoveryScoreModelVersion'] as String?,
    );
  }

  static const empty = ProgressSummary(
    hasHistory: false,
    firstCompletedSessionId: null,
    lastCompletedSessionId: null,
    firstCompletedDayKey: null,
    lastCompletedDayKey: null,
    activePlanId: null,
    profilePackId: null,
    recoveryScoreModelVersion: null,
  );
}
