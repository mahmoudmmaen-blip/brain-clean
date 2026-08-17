import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pro/application/subscription_service_provider.dart';
import '../application/premium_controller.dart';
import '../data/subscription_premium_store_port.dart';
import '../domain/premium_store_port.dart';

final premiumStorePortProvider = Provider<PremiumStorePort>((ref) {
  return SubscriptionPremiumStorePort(
    service: ref.watch(subscriptionServiceProvider),
    onEntitlementMaybeChanged: () {
      ref.invalidate(isProUserProvider);
    },
  );
});

final premiumControllerProvider = Provider<PremiumController>((ref) {
  return PremiumController(store: ref.watch(premiumStorePortProvider));
});
