/// Which subscription adapter is active (Production Monetization Contract §3.4).
enum SubscriptionAdapterKind {
  /// Production store path (RevenueCat).
  revenueCat,

  /// Explicit test/dev deterministic adapter only.
  localFake,

  /// Production path when SDK key missing / not configured — never Hive-grants.
  storeUnavailable,
}
