import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/features/pro/data/local_subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uses [LocalSubscriptionService] so tests avoid native RevenueCat / store I/O.
Override localSubscriptionTestOverride() {
  return subscriptionServiceProvider.overrideWith(LocalSubscriptionService.new);
}
