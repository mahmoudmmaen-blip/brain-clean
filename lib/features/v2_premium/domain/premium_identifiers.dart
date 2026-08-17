/// Canonical store entitlement / product identifiers (Premium Contract §8).
///
/// Do not invent new entitlement ids. Existing purchasers of `"Brain Clean"`
/// must remain valid. Local stub plan ids (`pro_*`) may still be used by the
/// existing [SubscriptionService] until RevenueCat is fully wired.
abstract final class PremiumIdentifiers {
  /// RevenueCat / Master entitlement — existing purchases.
  static const entitlementId = 'Brain Clean';

  /// Store product identifiers (Master).
  static const monthlyProductId = 'brainclean_monthly';
  static const yearlyProductId = 'brainclean_yearly';
  static const lifetimeProductId = 'brainclean_lifetime';

  /// Legacy local stub plan ids — purchase still goes through existing service.
  static const stubMonthlyPlanId = 'pro_monthly';
  static const stubAnnualPlanId = 'pro_annual';
  static const stubLifetimePlanId = 'pro_lifetime';
}
