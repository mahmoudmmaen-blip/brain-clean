import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../data/local_subscription_service.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

final subscriptionServiceProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionPlan>(
  SubscriptionNotifier.new,
);

class SubscriptionNotifier extends Notifier<SubscriptionPlan> {
  late SubscriptionService _service;

  @override
  SubscriptionPlan build() {
    final box = ref.watch(appMetaBoxProvider);
    _service = LocalSubscriptionService(box);
    return _service.currentPlan;
  }

  Future<bool> purchaseMonthly() async {
    final ok = await _service.purchaseMonthly();
    if (ok) {
      await ref.read(appMetaBoxProvider).put(HiveMetaKeys.isProUser, true);
      ref.invalidateSelf();
    }
    return ok;
  }

  Future<bool> purchaseAnnual() async {
    final ok = await _service.purchaseAnnual();
    if (ok) {
      await ref.read(appMetaBoxProvider).put(HiveMetaKeys.isProUser, true);
      ref.invalidateSelf();
    }
    return ok;
  }

  Future<bool> restorePurchases() async {
    final ok = await _service.restorePurchases();
    if (ok) ref.invalidateSelf();
    return ok;
  }
}

final isSubscriptionProProvider = Provider<bool>(
  (ref) => ref.watch(subscriptionServiceProvider).isPro,
  name: 'isSubscriptionProProvider',
);
