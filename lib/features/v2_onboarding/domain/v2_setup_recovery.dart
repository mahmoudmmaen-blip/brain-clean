import '../../../core/constants/app_routes.dart';

/// Setup recovery when Today/Plan/Profile is missing a ProfilePack or Plan.
///
/// Does not replace session/plan generation. UI maps this to existing routes.
enum V2SetupRecoveryAction {
  startBrainCheck,
  buildPlan,
  showToday,
}

abstract final class V2SetupRecovery {
  static V2SetupRecoveryAction resolve({
    required bool hasProfilePack,
    required bool hasValidPlan,
  }) {
    if (hasValidPlan) return V2SetupRecoveryAction.showToday;
    if (!hasProfilePack) return V2SetupRecoveryAction.startBrainCheck;
    return V2SetupRecoveryAction.buildPlan;
  }

  /// Existing V2 Brain Check entry (lite). [source] is attribution only.
  static String brainCheckLocation({required String source}) {
    return '${AppRoutes.v2Check}?mode=lite&source=${Uri.encodeComponent(source)}';
  }

  /// Profile recovery row: Check when pack is missing, reveal when it exists.
  static String profileBrainActionLocation({required bool hasProfilePack}) {
    if (!hasProfilePack) return brainCheckLocation(source: 'profile');
    return AppRoutes.v2BrainProfile;
  }
}
