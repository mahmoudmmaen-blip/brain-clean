import 'subscription_plan.dart';

abstract interface class SubscriptionService {
  SubscriptionPlan get currentPlan;
  bool get isPro;
  Future<bool> purchaseMonthly();
  Future<bool> purchaseAnnual();
  Future<bool> restorePurchases();
}
