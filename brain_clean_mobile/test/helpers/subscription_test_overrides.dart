import 'package:brain_clean_mobile/core/services/purchases_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Forces a non-Pro entitlement so widget tests avoid native RevenueCat I/O.
Override localSubscriptionTestOverride() {
  return entitlementStatusProvider.overrideWith((ref) => Stream.value(false));
}
