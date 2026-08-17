import '../domain/subscription_adapter_kind.dart';
import '../domain/subscription_outcomes.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

/// Production path when RevenueCat public SDK key is missing/placeholder.
///
/// Never grants Premium via Hive. Purchase/restore fail honestly.
class StoreUnavailableSubscriptionService implements SubscriptionService {
  StoreUnavailableSubscriptionService({
    bool Function()? readStoreVerifiedMirror,
  }) : _readStoreVerifiedMirror = readStoreVerifiedMirror;

  final bool Function()? _readStoreVerifiedMirror;

  @override
  SubscriptionAdapterKind get adapterKind =>
      SubscriptionAdapterKind.storeUnavailable;

  @override
  bool get isStoreConfigured => false;

  @override
  bool get isPro => _readStoreVerifiedMirror?.call() ?? false;

  @override
  List<SubscriptionPlan> get plans => const [];

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<List<SubscriptionPlan>> loadOfferings() async => const [];

  @override
  Future<SubscriptionPurchaseResult> purchasePlan(String planId) async =>
      SubscriptionPurchaseResult.storeUnavailable;

  @override
  Future<SubscriptionRestoreResult> restoreEntitlements() async =>
      SubscriptionRestoreResult.failed;

  @override
  Future<bool> purchase(String planId) async => false;

  @override
  Future<void> restorePurchases() async {}
}
