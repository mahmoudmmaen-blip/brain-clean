import '../../pro/domain/subscription_plan.dart';
import '../../pro/domain/subscription_service.dart';
import '../domain/premium_offering.dart';
import '../domain/premium_store_port.dart';

/// Adapts the existing [SubscriptionService] for V2 Premium.
///
/// Does not hardcode prices in UI — prices come from [SubscriptionPlan.priceString]
/// supplied by the active subscription layer (store when wired; local stub for dev).
class SubscriptionPremiumStorePort implements PremiumStorePort {
  SubscriptionPremiumStorePort({
    required SubscriptionService service,
    required void Function() onEntitlementMaybeChanged,
    bool Function()? isOnline,
    String Function(SubscriptionPeriod period)? periodTitle,
  })  : _service = service,
        _onEntitlementMaybeChanged = onEntitlementMaybeChanged,
        _isOnline = isOnline ?? (() => true),
        _periodTitle = periodTitle;

  final SubscriptionService _service;
  final void Function() _onEntitlementMaybeChanged;
  final bool Function() _isOnline;
  final String Function(SubscriptionPeriod period)? _periodTitle;

  bool _inflightPurchase = false;
  bool _inflightRestore = false;

  @override
  bool get isEntitled => _service.isPro;

  @override
  bool get hasCachedEntitlement => _service.isPro;

  @override
  bool get isOnline => _isOnline();

  @override
  Future<List<PremiumOffering>> loadOfferings() async {
    if (!_isOnline()) {
      return const [];
    }
    try {
      final plans = _service.plans;
      return plans
          .map(
            (p) => PremiumOffering(
              productId: p.id,
              title: _periodTitle?.call(p.period) ?? p.title,
              priceString: p.priceString,
              period: p.period,
              // Local / current service does not confirm store trials.
              trialConfirmed: false,
              introPricingConfirmed: false,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<PremiumPurchaseOutcome> purchase(String productId) async {
    if (_inflightPurchase) {
      return PremiumPurchaseOutcome.failed;
    }
    if (_service.isPro) {
      return PremiumPurchaseOutcome.alreadyEntitled;
    }
    _inflightPurchase = true;
    try {
      final ok = await _service.purchase(productId);
      _onEntitlementMaybeChanged();
      if (ok) return PremiumPurchaseOutcome.success;
      return PremiumPurchaseOutcome.failed;
    } catch (_) {
      return PremiumPurchaseOutcome.failed;
    } finally {
      _inflightPurchase = false;
    }
  }

  @override
  Future<PremiumRestoreOutcome> restore() async {
    if (_inflightRestore) {
      // Idempotent: ignore overlapping restore.
      return _service.isPro
          ? PremiumRestoreOutcome.restored
          : PremiumRestoreOutcome.nothingToRestore;
    }
    _inflightRestore = true;
    try {
      await _service.restorePurchases();
      _onEntitlementMaybeChanged();
      return _service.isPro
          ? PremiumRestoreOutcome.restored
          : PremiumRestoreOutcome.nothingToRestore;
    } catch (_) {
      return PremiumRestoreOutcome.failed;
    } finally {
      _inflightRestore = false;
    }
  }
}
