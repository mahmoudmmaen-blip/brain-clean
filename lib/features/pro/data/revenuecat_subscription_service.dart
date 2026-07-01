import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

/// PUBLISH-TIME STUB — not wired, no SDK calls.
class RevenueCatSubscriptionService implements SubscriptionService {
  const RevenueCatSubscriptionService();

  @override
  bool get isPro => throw UnimplementedError(
        'Wire RevenueCat customerInfo before using RevenueCatSubscriptionService.',
      );

  @override
  List<SubscriptionPlan> get plans => throw UnimplementedError(
        'Fetch offerings via Purchases.getOfferings() before using this service.',
      );

  @override
  Future<bool> purchase(String planId) => throw UnimplementedError(
        'Call Purchases.purchasePackage() before using this service.',
      );

  @override
  Future<void> restorePurchases() => throw UnimplementedError(
        'Call Purchases.restorePurchases() before using this service.',
      );
}