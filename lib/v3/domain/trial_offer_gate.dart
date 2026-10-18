import '../../features/pro/domain/subscription_plan.dart';
import '../../features/v2_premium/domain/premium_offering.dart';

/// Whether the one-time onboarding trial offer should appear after Result.
abstract final class TrialOfferGate {
  TrialOfferGate._();

  static bool shouldShow({
    required bool alreadyShown,
    required bool isPro,
    required bool storeConfigured,
    required bool yearlyTrialConfirmed,
  }) {
    if (alreadyShown || isPro || !storeConfigured) return false;
    return yearlyTrialConfirmed;
  }

  static bool yearlyHasConfirmedTrial(Iterable<PremiumOffering> offerings) {
    for (final o in offerings) {
      if (o.period == SubscriptionPeriod.annual &&
          o.trialConfirmed &&
          (o.trialDays ?? 0) > 0) {
        return true;
      }
    }
    return false;
  }

  static PremiumOffering? yearlyOffering(Iterable<PremiumOffering> offerings) {
    for (final o in offerings) {
      if (o.period == SubscriptionPeriod.annual) return o;
    }
    return null;
  }
}
