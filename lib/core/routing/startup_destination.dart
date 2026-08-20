import '../constants/app_routes.dart';
import '../v2/v2_feature_boundary.dart';

/// Ordinary product home after splash / biometric unlock.
///
/// Shares the same gate as `/v2/*` surfaces: [V2FeatureBoundary.enableV2Shell]
/// (compile-time `V2_ENABLED` or an explicit runtime override).
abstract final class StartupDestination {
  /// Returns [AppRoutes.v2Home] when the V2 shell is enabled; otherwise
  /// [AppRoutes.home] (legacy V1).
  static String resolve() =>
      V2FeatureBoundary.enableV2Shell ? AppRoutes.v2Home : AppRoutes.home;

  /// First-run onboarding host for the active product.
  ///
  /// V2 release cold start uses `/v2/onboarding`. Legacy V1 keeps `/onboarding`.
  static String onboarding() => V2FeatureBoundary.enableV2Shell
      ? AppRoutes.v2Onboarding
      : AppRoutes.onboarding;

  /// True when [location] is the active product's onboarding host.
  static bool isOnboardingLocation(String location) {
    final path = Uri.tryParse(location)?.path ?? location;
    if (V2FeatureBoundary.enableV2Shell) {
      return path == AppRoutes.v2Onboarding;
    }
    return path == AppRoutes.onboarding;
  }

  /// Locations a first-time user may occupy before [hasSeenOnboarding].
  ///
  /// V2 allows the existing Check → Profile → Plan path. V1 allows only
  /// `/onboarding`. Splash and biometric lock are always allowed.
  static bool allowsIncompleteOnboarding(String location) {
    final path = Uri.tryParse(location)?.path ?? location;
    if (path == AppRoutes.splash || path == AppRoutes.biometricLock) {
      return true;
    }
    if (!V2FeatureBoundary.enableV2Shell) {
      return path == AppRoutes.onboarding;
    }
    if (path == AppRoutes.v2Onboarding) return true;
    // Plan reveal is contextual `/v2/plan` (not a primary tab). First-time PLN-01 uses it.
    if (path == AppRoutes.v2PlanReveal) return true;
    const firstTimePrefixes = <String>[
      AppRoutes.v2Check,
      AppRoutes.v2InteractiveDiagnostic,
      '/v2/brain-check',
      AppRoutes.v2BrainProfile,
      '/v2/plan/',
    ];
    for (final prefix in firstTimePrefixes) {
      if (prefix.endsWith('/')) {
        if (path.startsWith(prefix)) return true;
      } else if (path == prefix || path.startsWith('$prefix/')) {
        return true;
      }
    }
    return false;
  }

  /// Redirect for users who have not finished first-run. Null = stay.
  static String? redirectIfOnboardingIncomplete(String location) {
    if (allowsIncompleteOnboarding(location)) return null;
    return onboarding();
  }
}
