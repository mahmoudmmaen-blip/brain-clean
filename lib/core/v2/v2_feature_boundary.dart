/// Local + compile-time gate for V2 product surfaces.
///
/// Default (no dart-define): V1 shell remains the production default.
/// Internal Testing / Play release embeds V2 via `--dart-define=V2_ENABLED=true`.
/// Tests may still override at runtime without rebuilding.
abstract final class V2FeatureBoundary {
  /// Compile-time flag for release AABs (`--dart-define=V2_ENABLED=true`).
  static const bool compileTimeV2Enabled =
      bool.fromEnvironment('V2_ENABLED', defaultValue: false);

  static bool? _runtimeOverride;

  /// When false, `/v2/*` routes redirect to Home (V1 remains default).
  ///
  /// Resolution order: explicit runtime override (tests/debug) → compile-time
  /// [compileTimeV2Enabled].
  static bool get enableBrainProfileRoutes =>
      _runtimeOverride ?? compileTimeV2Enabled;

  static set enableBrainProfileRoutes(bool value) {
    _runtimeOverride = value;
  }

  /// Clears any runtime override so compile-time / default resolution applies.
  static void clearRuntimeOverride() {
    _runtimeOverride = null;
  }

  /// Temporary completion boundary until Slice 4 (Recovery Plan).
  static bool get profileReadyBoundaryEnabled => enableBrainProfileRoutes;

  /// V2 Recovery Plan routes share the Brain Profile feature gate.
  static bool get enableRecoveryPlanRoutes => enableBrainProfileRoutes;

  /// V2 onboarding shares the same local feature gate (no startup change).
  static bool get enableV2OnboardingRoutes => enableBrainProfileRoutes;

  /// HOM-01 / SES routes share the same gated V2 surface.
  static bool get enableTodaySessionRoutes => enableBrainProfileRoutes;

  /// RPT-01 / RPT-02 / RPT-03 share the same gated V2 surface.
  static bool get enableReportsRoutes => enableBrainProfileRoutes;

  /// Final V2 navigation shell shares the same gate.
  static bool get enableV2Shell => enableBrainProfileRoutes;
}
