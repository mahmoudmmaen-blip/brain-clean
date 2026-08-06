import '../constants/app_routes.dart';
import '../v2/v2_feature_boundary.dart';

/// Ordinary product home after splash / biometric unlock.
///
/// Shares the same gate as `/v2/*` surfaces: [V2FeatureBoundary.enableV2Shell]
/// (compile-time `V2_ENABLED` or an explicit runtime override).
abstract final class StartupDestination {
  /// Returns [AppRoutes.v2Home] when the V2 shell is enabled; otherwise
  /// [AppRoutes.home] (legacy V1).
  static String resolve() => V2FeatureBoundary.enableV2Shell
      ? AppRoutes.v2Home
      : AppRoutes.home;
}
