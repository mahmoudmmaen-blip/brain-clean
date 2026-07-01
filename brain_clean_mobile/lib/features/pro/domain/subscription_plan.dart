/// Billing cadence for a [SubscriptionPlan].
enum SubscriptionPeriod { monthly, annual, lifetime }

/// A purchasable Pro plan.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceString,
    required this.period,
  });

  final String id;
  final String title;
  final String priceString;
  final SubscriptionPeriod period;
}