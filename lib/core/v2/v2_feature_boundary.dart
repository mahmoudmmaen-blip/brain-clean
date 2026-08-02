/// Local-only gate for V2 product surfaces.
///
/// Production default keeps the V1 shell. Enable in tests or local builds
/// without changing startup routing or replacing main navigation.
abstract final class V2FeatureBoundary {
  /// When false, `/v2/*` routes redirect to Home (V1 remains default).
  static bool enableBrainProfileRoutes = false;

  /// Temporary completion boundary until Slice 4 (Recovery Plan).
  static bool get profileReadyBoundaryEnabled => enableBrainProfileRoutes;

  /// V2 Recovery Plan routes share the Brain Profile feature gate.
  static bool get enableRecoveryPlanRoutes => enableBrainProfileRoutes;
}
