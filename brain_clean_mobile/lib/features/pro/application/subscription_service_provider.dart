import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/purchases_service.dart';

part 'subscription_service_provider.g.dart';

/// Reactive Pro entitlement, derived from [entitlementStatusProvider].
///
/// Defaults to `false` until RevenueCat resolves the first customer info, and
/// updates automatically via the customer-info listener. Used by
/// [navigateWithProGate] and every other Pro gate in the app.
@riverpod
bool isProUser(IsProUserRef ref) {
  return ref.watch(entitlementStatusProvider).valueOrNull ?? false;
}
