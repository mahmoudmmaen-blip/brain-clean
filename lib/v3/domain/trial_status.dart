/// Snapshot for the "trial ends soon" notice on Today.
class TrialStatus {
  const TrialStatus({
    this.isTrialPeriod = false,
    this.expiresAt,
    this.yearlyPriceString,
    this.endingNoticeShownKey,
  });

  final bool isTrialPeriod;
  final DateTime? expiresAt;
  final String? yearlyPriceString;

  /// Persisted key of the expiration already acknowledged (once per trial).
  final String? endingNoticeShownKey;

  static String expirationKey(DateTime expiresAt) =>
      expiresAt.toUtc().toIso8601String();

  bool get endingNoticeAlreadyShown {
    final exp = expiresAt;
    if (exp == null || endingNoticeShownKey == null) return false;
    return endingNoticeShownKey == expirationKey(exp);
  }

  /// True when in trial, expiration within 48 h, and notice not yet shown.
  bool shouldShowEndingNotice({required DateTime now}) {
    if (!isTrialPeriod || expiresAt == null) return false;
    if (endingNoticeAlreadyShown) return false;
    final remaining = expiresAt!.difference(now);
    return !remaining.isNegative && remaining <= const Duration(hours: 48);
  }
}
