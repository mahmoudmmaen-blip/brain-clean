/// Canonical DailySession id builder.
abstract final class DailySessionId {
  /// One session per TodayAct per local calendar day.
  static String build({
    required String planId,
    required String todayActId,
    required String dayKey,
  }) =>
      'dsess_${planId}_${todayActId}_$dayKey';
}
