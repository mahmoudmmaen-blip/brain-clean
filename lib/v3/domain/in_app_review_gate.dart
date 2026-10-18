/// When to request Play In-App Review (once per install).
///
/// Triggers: first SOS where after ≤ before − 2, or Day 3 completion —
/// whichever comes first. Never on a calendar day the paywall was shown.
abstract final class InAppReviewGate {
  InAppReviewGate._();

  static bool isSosWin({required int? before, required int? after}) {
    if (before == null || after == null) return false;
    return after <= before - 2;
  }

  static bool shouldRequest({
    required bool alreadyRequested,
    required bool paywallShownToday,
    required bool triggerMet,
  }) {
    if (alreadyRequested || paywallShownToday || !triggerMet) return false;
    return true;
  }

  static String dateKey(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';

  static bool isSameLocalDay(String? storedKey, DateTime local) {
    if (storedKey == null || storedKey.isEmpty) return false;
    return storedKey == dateKey(local);
  }
}
