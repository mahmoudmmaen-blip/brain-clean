/// RevenueCat product and entitlement identifiers (Google Play).
///
/// Canonical entitlement id is [proEntitlement] (`pro`).
/// [legacyProEntitlement] remains accepted for existing dashboard mappings.
class RevenueCatConstants {
  const RevenueCatConstants._();

  static const String lifetimeProductId = 'brainclean_lifetime';
  static const String yearlyProductId = 'brainclean_yearly';
  static const String monthlyProductId = 'brainclean_monthly';

  /// Preferred entitlement id for new RevenueCat offerings.
  static const String proEntitlement = 'pro';

  /// Legacy entitlement still active for early Play builds.
  static const String legacyProEntitlement = 'Brain Clean';
}
