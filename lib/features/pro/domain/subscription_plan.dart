/// Billing cadence for a [SubscriptionPlan].
enum SubscriptionPeriod { monthly, annual, lifetime }

/// A purchasable Pro plan.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceString,
    required this.period,
    this.trialConfirmed = false,
    this.trialDays,
    this.trialLabel,
  });

  final String id;
  final String title;
  final String priceString;
  final SubscriptionPeriod period;

  /// True only when the store reports a free trial phase on the default option.
  final bool trialConfirmed;

  /// Free-trial length in days, parsed from the store period (never invented).
  final int? trialDays;

  /// Optional pre-built label; UI prefers localizing from [trialDays].
  final String? trialLabel;
}
