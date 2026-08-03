/// Purchase outcome from the subscription adapter.
enum SubscriptionPurchaseResult {
  success,
  cancelled,
  failed,
  pending,
  alreadyEntitled,
  storeUnavailable,
}

/// Restore outcome from the subscription adapter.
enum SubscriptionRestoreResult {
  restored,
  nothingToRestore,
  failed,
}
