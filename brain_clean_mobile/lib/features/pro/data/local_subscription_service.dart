import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

class LocalSubscriptionService implements SubscriptionService {
  LocalSubscriptionService(this._ref);

  final Ref _ref;

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
  Future<bool> purchase(String planId) async {
    if (plans.every((plan) => plan.id != planId)) return false;
    await _ref.read(appPreferencesProvider.notifier).setProUser(true);
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    _ref.invalidate(appPreferencesProvider);
  }
}