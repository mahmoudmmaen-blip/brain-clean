/// Keys inside the encrypted [HiveBoxes.v3State] box.
abstract final class V3StorageKeys {
  static const schemaVersion = 'schema_version';
  static const userProfile = 'user_profile';
  static const dayProgress = 'day_progress';
  static const clarityResults = 'clarity_results';
  static const eveningCheckIns = 'evening_check_ins';
  static const sosLogs = 'sos_logs';
  static const focusLogs = 'focus_logs';
  static const userInputs = 'user_inputs';
  static const day7PaywallShown = 'day7_paywall_shown';
  static const trialOfferShown = 'trial_offer_shown';
  static const trialEndingNoticeKey = 'trial_ending_notice_key';
  static const inAppReviewRequested = 'in_app_review_requested';
  static const lastPaywallShownDate = 'last_paywall_shown_date';
}
