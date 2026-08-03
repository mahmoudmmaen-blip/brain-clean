import 'premium_offering.dart';

enum PremiumPurchaseOutcome {
  success,
  cancelled,
  failed,
  pending,
  alreadyEntitled,
}

enum PremiumRestoreOutcome {
  restored,
  nothingToRestore,
  failed,
}

/// Store boundary for V2 Premium (wraps existing subscription / RC layer).
abstract interface class PremiumStorePort {
  bool get isEntitled;

  /// Last-known entitlement when offline cache is honored.
  bool get hasCachedEntitlement;

  bool get isOnline;

  Future<List<PremiumOffering>> loadOfferings();

  Future<PremiumPurchaseOutcome> purchase(String productId);

  Future<PremiumRestoreOutcome> restore();
}
