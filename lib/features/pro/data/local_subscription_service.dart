import 'package:hive/hive.dart';

import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

class LocalSubscriptionService implements SubscriptionService {
  const LocalSubscriptionService(this._box);

  final Box<dynamic> _box;

  static const _kPlanKey = 'subscriptionPlan';

  @override
  SubscriptionPlan get currentPlan {
    final stored =
        _box.get(_kPlanKey, defaultValue: SubscriptionPlan.free.name) as String;
    return SubscriptionPlan.values.firstWhere(
      (p) => p.name == stored,
      orElse: () => SubscriptionPlan.free,
    );
  }

  @override
  bool get isPro => currentPlan.isPro;

  @override
  Future<bool> purchaseMonthly() async {
    await _box.put(_kPlanKey, SubscriptionPlan.monthlyPro.name);
    return true;
  }

  @override
  Future<bool> purchaseAnnual() async {
    await _box.put(_kPlanKey, SubscriptionPlan.annualPro.name);
    return true;
  }

  @override
  Future<bool> restorePurchases() async => isPro;
}
