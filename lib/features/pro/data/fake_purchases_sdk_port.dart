import '../domain/purchases_sdk_port.dart';
import '../domain/subscription_plan.dart';
import '../../v2_premium/domain/premium_identifiers.dart';

/// Deterministic store SDK for tests (never touches native Purchases).
class FakePurchasesSdkPort implements PurchasesSdkPort {
  FakePurchasesSdkPort({
    this.configureSucceeds = true,
    this.entitled = false,
    this.offerings = const [],
    this.purchaseResult,
    this.restoreResult,
    this.throwOnPurchase,
    this.throwOnRestore,
    this.throwOnOfferings,
  });

  bool configureSucceeds;
  bool entitled;
  List<StorePackageRef> offerings;
  StoreCustomerSnapshot? purchaseResult;
  StoreCustomerSnapshot? restoreResult;
  StorePurchaseException? throwOnPurchase;
  StorePurchaseException? throwOnRestore;
  StorePurchaseException? throwOnOfferings;

  int configureCalls = 0;
  int purchaseCalls = 0;
  int restoreCalls = 0;
  bool _configured = false;
  void Function(StoreCustomerSnapshot info)? _listener;

  @override
  bool get isConfigured => _configured;

  @override
  Future<void> configure({required String apiKey}) async {
    configureCalls++;
    if (!configureSucceeds || apiKey.isEmpty) {
      throw const StorePurchaseException(StorePurchaseFailureKind.notConfigured);
    }
    if (_configured) return;
    _configured = true;
  }

  @override
  Future<StoreCustomerSnapshot> getCustomerInfo() async {
    _require();
    return StoreCustomerSnapshot(
      entitled: entitled,
      activeEntitlementIds: entitled
          ? const [PremiumIdentifiers.entitlementId]
          : const [],
    );
  }

  @override
  Future<List<StorePackageRef>> getCurrentOfferingPackages() async {
    _require();
    if (throwOnOfferings != null) throw throwOnOfferings!;
    return List.unmodifiable(offerings);
  }

  @override
  Future<StoreCustomerSnapshot> purchaseProductId(String productId) async {
    _require();
    purchaseCalls++;
    if (throwOnPurchase != null) throw throwOnPurchase!;
    final snap = purchaseResult ??
        StoreCustomerSnapshot(
          entitled: true,
          activeEntitlementIds: const [PremiumIdentifiers.entitlementId],
        );
    entitled = snap.entitled;
    _listener?.call(snap);
    return snap;
  }

  @override
  Future<StoreCustomerSnapshot> restorePurchases() async {
    _require();
    restoreCalls++;
    if (throwOnRestore != null) throw throwOnRestore!;
    final snap = restoreResult ??
        StoreCustomerSnapshot(
          entitled: entitled,
          activeEntitlementIds: entitled
              ? const [PremiumIdentifiers.entitlementId]
              : const [],
        );
    entitled = snap.entitled;
    _listener?.call(snap);
    return snap;
  }

  @override
  void setCustomerInfoListener(
    void Function(StoreCustomerSnapshot info)? listener,
  ) {
    _listener = listener;
  }

  @override
  void dispose() {
    _listener = null;
  }

  void emitCustomerInfo(StoreCustomerSnapshot snap) {
    entitled = snap.entitled;
    _listener?.call(snap);
  }

  void _require() {
    if (!_configured) {
      throw const StorePurchaseException(StorePurchaseFailureKind.notConfigured);
    }
  }

  static List<StorePackageRef> defaultOfferings({
    bool includeLifetime = true,
    bool withTrial = false,
  }) {
    return [
      StorePackageRef(
        productId: PremiumIdentifiers.monthlyProductId,
        title: 'Monthly',
        priceString: 'SAR 18.99',
        period: SubscriptionPeriod.monthly,
        trialConfirmed: withTrial,
        trialLabel: withTrial ? '7-day trial' : null,
      ),
      StorePackageRef(
        productId: PremiumIdentifiers.yearlyProductId,
        title: 'Yearly',
        priceString: 'SAR 149.99',
        period: SubscriptionPeriod.annual,
      ),
      if (includeLifetime)
        const StorePackageRef(
          productId: PremiumIdentifiers.lifetimeProductId,
          title: 'Lifetime',
          priceString: 'SAR 399.99',
          period: SubscriptionPeriod.lifetime,
        ),
    ];
  }
}
