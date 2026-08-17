import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../domain/subscription_adapter_kind.dart';
import '../domain/subscription_outcomes.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

/// Deterministic local/fake adapter for **tests and explicit dev only**.
///
/// Must never be selected as the silent production default.
class LocalSubscriptionService implements SubscriptionService {
  LocalSubscriptionService(this._ref);

  final Ref _ref;

  @override
  SubscriptionAdapterKind get adapterKind => SubscriptionAdapterKind.localFake;

  @override
  bool get isStoreConfigured => true;

  @override
  bool get isPro => _ref.read(appPreferencesProvider).isProUser;

  @override
  List<SubscriptionPlan> get plans => const [
        SubscriptionPlan(
          id: 'pro_monthly',
          title: 'Monthly',
          priceString: '\$4.99',
          period: SubscriptionPeriod.monthly,
        ),
        SubscriptionPlan(
          id: 'pro_annual',
          title: 'Annual',
          priceString: '\$29.99',
          period: SubscriptionPeriod.annual,
        ),
        SubscriptionPlan(
          id: 'pro_lifetime',
          title: 'Lifetime',
          priceString: '\$79.99',
          period: SubscriptionPeriod.lifetime,
        ),
      ];

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<List<SubscriptionPlan>> loadOfferings() async => plans;

  @override
  Future<SubscriptionPurchaseResult> purchasePlan(String planId) async {
    if (plans.every((plan) => plan.id != planId)) {
      return SubscriptionPurchaseResult.failed;
    }
    if (isPro) return SubscriptionPurchaseResult.alreadyEntitled;
    await _ref.read(appPreferencesProvider.notifier).setProUser(true);
    return SubscriptionPurchaseResult.success;
  }

  @override
  Future<SubscriptionRestoreResult> restoreEntitlements() async {
    _ref.invalidate(appPreferencesProvider);
    return isPro
        ? SubscriptionRestoreResult.restored
        : SubscriptionRestoreResult.nothingToRestore;
  }

  @override
  Future<bool> purchase(String planId) async {
    final r = await purchasePlan(planId);
    return r == SubscriptionPurchaseResult.success ||
        r == SubscriptionPurchaseResult.alreadyEntitled;
  }

  @override
  Future<void> restorePurchases() async {
    await restoreEntitlements();
  }
}
