/// Exact Premium purchase / entitlement phases (Premium Contract §9).
enum PremiumPurchasePhase {
  loading,
  offeringReady,
  noOffering,
  purchasing,
  purchased,
  alreadyEntitled,
  restoring,
  restored,
  nothingToRestore,
  cancelled,
  failed,
  pending,
  offlineCachedEntitlement,
  offlineUnknown,
  storeUnavailable,
}
