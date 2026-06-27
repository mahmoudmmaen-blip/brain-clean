enum SubscriptionPlan {
  free,
  monthlyPro,
  annualPro;

  bool get isPro => this != SubscriptionPlan.free;
}
