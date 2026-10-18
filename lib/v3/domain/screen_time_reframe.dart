/// Result-screen reframe: hours/day → full days/year on the phone.
abstract final class ScreenTimeReframe {
  ScreenTimeReframe._();

  /// Y = round(hours × 365 / 24). Example: 6 h → 91 days.
  static int yearlyFullDays(double hoursPerDay) {
    return (hoursPerDay * 365 / 24).round();
  }
}
