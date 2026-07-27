import '../constants/app_routes.dart';

/// Pure helpers for footer banner visibility (unit-testable, no SDK).
abstract final class AdVisibility {
  AdVisibility._();

  /// Shell tab roots and calm browsing screens where a banner may appear.
  static const Set<String> allowedShellRoutes = {
    AppRoutes.home,
    AppRoutes.exercises,
    AppRoutes.journey,
    AppRoutes.more,
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.dashboard,
    AppRoutes.accountability,
  };

  /// Routes and flows that must stay ad-free (focus, calm, support, Safa, paywall).
  static bool isBlockedRoute(String location) {
    final path = normalizedPath(location);

    if (path.startsWith(AppRoutes.safa)) return true;
    if (path == AppRoutes.proPaywall) return true;

    const blockedSegments = <String>[
      'silence-challenge',
      'single-task',
      'daily-program',
      'day-end',
      'sukoon',
      'pomodoro',
      'breathing-friction',
      'delayed-gratification',
      'emotion-oasis',
      'emotion-wheel',
      'focused-thinking',
      'recovery',
      'worry-journal',
      'worry-window',
    ];

    for (final segment in blockedSegments) {
      if (path.contains(segment)) return true;
    }

    return false;
  }

  /// Whether the shell footer banner should attempt to show.
  static bool shouldShowFooterBanner({
    required bool isPro,
    required String location,
  }) {
    if (isPro) return false;
    if (isBlockedRoute(location)) return false;

    final path = normalizedPath(location);
    if (allowedShellRoutes.contains(path)) return true;

    // Nested exercise/game routes are not "normal shell" browsing.
    if (path.startsWith('${AppRoutes.exercises}/')) return false;
    if (path.startsWith('${AppRoutes.home}/')) return false;
    if (path.startsWith('${AppRoutes.journey}/')) return false;
    if (path.startsWith('${AppRoutes.more}/')) return false;

    return false;
  }

  static String normalizedPath(String location) {
    final uri = Uri.tryParse(location);
    return (uri?.path ?? location).split('?').first;
  }
}
