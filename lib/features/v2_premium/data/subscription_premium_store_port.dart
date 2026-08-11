import '../../pro/domain/subscription_outcomes.dart';
import '../../pro/domain/subscription_plan.dart';
import '../../pro/domain/subscription_service.dart';
import '../domain/premium_offering.dart';
import '../domain/premium_store_port.dart';

/// Adapts [SubscriptionService] for V2 Premium (Production Monetization Contract).
///
/// Trial/intro fields stay unconfirmed here until a deliberate store passthrough
/// lands. Never invent trial duration or eligibility in this adapter.
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

  @override
  bool get isEntitled => _service.isPro;

  @override
  bool get hasCachedEntitlement => _service.isPro;

  @override
  bool get isOnline => _isOnline();

  @override
  bool get isStoreConfigured => _service.isStoreConfigured;

  @override
  Future<List<PremiumOffering>> loadOfferings() async {
    await _service.ensureInitialized();
    if (!_isOnline()) {
      return const [];
    }
    try {
      final plans = await _service.loadOfferings();
      return plans
          .map(
            (p) => PremiumOffering(
              productId: p.id,
              title: _periodTitle?.call(p.period) ?? p.title,
              priceString: p.priceString,
              period: p.period,
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
    final result = await _service.purchasePlan(productId);
    _onEntitlementMaybeChanged();
    return switch (result) {
      SubscriptionPurchaseResult.success => PremiumPurchaseOutcome.success,
      SubscriptionPurchaseResult.cancelled => PremiumPurchaseOutcome.cancelled,
      SubscriptionPurchaseResult.pending => PremiumPurchaseOutcome.pending,
      SubscriptionPurchaseResult.alreadyEntitled =>
        PremiumPurchaseOutcome.alreadyEntitled,
      SubscriptionPurchaseResult.storeUnavailable =>
        PremiumPurchaseOutcome.failed,
      SubscriptionPurchaseResult.failed => PremiumPurchaseOutcome.failed,
    };
  }

  @override
  Future<PremiumRestoreOutcome> restore() async {
    final result = await _service.restoreEntitlements();
    _onEntitlementMaybeChanged();
    return switch (result) {
      SubscriptionRestoreResult.restored => PremiumRestoreOutcome.restored,
      SubscriptionRestoreResult.nothingToRestore =>
        PremiumRestoreOutcome.nothingToRestore,
      SubscriptionRestoreResult.failed => PremiumRestoreOutcome.failed,
    };
  }
}
