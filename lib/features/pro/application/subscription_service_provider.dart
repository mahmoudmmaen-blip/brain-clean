import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../data/local_subscription_service.dart';
import '../domain/subscription_service.dart';

part 'subscription_service_provider.g.dart';

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return LocalSubscriptionService(ref);
}

/// Reactive Pro entitlement, read from [subscriptionServiceProvider].
///
/// Used by [navigateWithProGate] and every other Pro gate in the app.
@riverpod
bool isProUser(IsProUserRef ref) {
  ref.watch(appPreferencesProvider);
  return ref.watch(subscriptionServiceProvider).isPro;
}