/// RevenueCat product and entitlement identifiers (Google Play).
///
/// Live dashboard (Local Pro RC):
/// - Offering: [defaultOfferingId] (`default`)
/// - Packages: monthly → [monthlyProductId], annual → [yearlyProductId]
/// - Lifetime is **not** in the active offering
/// - Entitlement id in RevenueCat: [legacyProEntitlement] (`Brain Clean`)
///   Display name: Brain Clean Pro
/// - Also accept [proEntitlement] (`pro`) for future dashboard alignment
class RevenueCatConstants {
  const RevenueCatConstants._();

  static const String defaultOfferingId = 'default';

  static const String lifetimeProductId = 'brainclean_lifetime';
  static const String yearlyProductId = 'brainclean_yearly';
  static const String monthlyProductId = 'brainclean_monthly';

  /// Optional / future entitlement id.
  static const String proEntitlement = 'pro';

  /// Live RevenueCat entitlement identifier (keep accepting forever).
  static const String legacyProEntitlement = 'Brain Clean';

  /// All entitlement ids that unlock Pro.
  static const List<String> acceptedProEntitlementIds = [
    proEntitlement,
    legacyProEntitlement,
  ];
}
