import 'subscription_plan.dart';

abstract interface class SubscriptionService {
  bool get isPro;
  List<SubscriptionPlan> get plans;
  Future<bool> purchase(String planId);
  Future<void> restorePurchases();
}