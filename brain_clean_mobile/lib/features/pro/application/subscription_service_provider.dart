import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/local_subscription_service.dart';
import '../data/revenue_cat_bootstrap.dart';
import '../data/revenuecat_subscription_service.dart';
import '../domain/subscription_service.dart';

part 'subscription_service_provider.g.dart';

/// Bumps when RevenueCat offerings refresh so paywalls rebuild plan tiles.
final subscriptionCatalogVersionProvider = StateProvider<int>((ref) => 0);

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  RevenueCatBootstrap.attach(
    ref,
    isProProvider: isProUserProvider,
    catalogVersionProvider: subscriptionCatalogVersionProvider,
  );
  return RevenueCatSubscriptionService(ref);
}

/// Reactive Pro entitlement from [subscriptionServiceProvider].
///
/// Invalidated automatically via RevenueCat customer-info listeners.
/// Used by [navigateWithProGate] and every other Pro gate in the app.
@riverpod
bool isProUser(IsProUserRef ref) {
  ref.watch(subscriptionCatalogVersionProvider);
  return ref.watch(subscriptionServiceProvider).isPro;
}

/// Local-only subscription service for widget tests (no store / SDK).
SubscriptionService localSubscriptionService(Ref ref) {
  return LocalSubscriptionService(ref);
}
