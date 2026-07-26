/// Pure helpers for footer banner visibility (unit-testable, no SDK).
abstract final class AdVisibility {
  AdVisibility._();

  /// Routes where focus / emotional flow must stay ad-free.
  ///
  /// Daily Program and Day End are outside [AppShell], so they never show
  /// the shell banner. Silence + Single Task nest under `/home` and must hide.
  static bool isFocusRoute(String location) {
    final path = location.toLowerCase();
    return path.contains('silence-challenge') ||
        path.contains('single-task') ||
        path.contains('daily-program') ||
        path.contains('day-end') ||
        path.contains('/sukoon');
  }

  /// Whether the shell footer banner should attempt to show.
  static bool shouldShowFooterBanner({
    required bool isPro,
    required String location,
  }) {
    if (isPro) return false;
    if (isFocusRoute(location)) return false;
    return true;
  }
}
