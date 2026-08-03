import 'subscription_adapter_kind.dart';
import 'subscription_outcomes.dart';
import 'subscription_plan.dart';

/// Root subscription boundary (Production Monetization Contract).
abstract interface class SubscriptionService {
  SubscriptionAdapterKind get adapterKind;

  /// Authoritative entitlement for the selected adapter.
  ///
  /// Production RevenueCat / store-unavailable paths must not grant Premium
  /// from Hive-only local flags.
  bool get isPro;

  /// True when the production store SDK is configured and usable for purchase.
  bool get isStoreConfigured;

  /// Last known plans (may be empty until [loadOfferings]).
  List<SubscriptionPlan> get plans;

  /// Single-shot init for store adapters; no-op for fake / unavailable.
  Future<void> ensureInitialized();

  /// Refresh offerings from the store (or local fake catalog).
  Future<List<SubscriptionPlan>> loadOfferings();

  Future<SubscriptionPurchaseResult> purchasePlan(String planId);

  Future<SubscriptionRestoreResult> restoreEntitlements();

  /// Legacy V1 helper — true only when entitled after purchase.
  Future<bool> purchase(String planId);

  /// Legacy V1 helper.
  Future<void> restorePurchases();
}
