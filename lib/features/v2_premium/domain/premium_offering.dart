import '../../pro/domain/subscription_plan.dart';

/// One store-backed (or adapter-backed) purchasable offering.
///
/// Prices and titles must come from the store/port — never from UI literals.
class PremiumOffering {
  const PremiumOffering({
    required this.productId,
    required this.title,
    required this.priceString,
    required this.period,
    this.trialConfirmed = false,
    this.trialLabel,
    this.introPricingConfirmed = false,
    this.introPriceLabel,
  });

  final String productId;
  final String title;
  final String priceString;
  final SubscriptionPeriod period;

  /// Trial copy may be shown only when [trialConfirmed] is true.
  final bool trialConfirmed;
  final String? trialLabel;

  /// Intro pricing only when store confirms.
  final bool introPricingConfirmed;
  final String? introPriceLabel;

  String get semanticsLabel {
    final buf = StringBuffer('$title. $priceString. ${period.name}');
    if (trialConfirmed && trialLabel != null) {
      buf.write('. $trialLabel');
    }
    if (introPricingConfirmed && introPriceLabel != null) {
      buf.write('. $introPriceLabel');
    }
    return buf.toString();
  }
}
