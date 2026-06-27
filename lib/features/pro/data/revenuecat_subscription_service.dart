// RevenueCat integration stub — wire up purchases_flutter when added as a dependency.
import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

class RevenueCatSubscriptionService implements SubscriptionService {
  const RevenueCatSubscriptionService();

  @override
  SubscriptionPlan get currentPlan => SubscriptionPlan.free;

  @override
  bool get isPro => false;

  @override
  Future<bool> purchaseMonthly() async => false;

  @override
  Future<bool> purchaseAnnual() async => false;

  @override
  Future<bool> restorePurchases() async => false;
}
