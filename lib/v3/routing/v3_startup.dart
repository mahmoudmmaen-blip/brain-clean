import 'v3_routes.dart';

/// Post-splash / post-biometric destinations for V3 (no V2 branching).
abstract final class V3Startup {
  V3Startup._();

  static String afterSplash({required bool onboardingDone}) {
    return onboardingDone ? V3Routes.today : V3Routes.welcome;
  }

  static String afterBiometricUnlock({required bool onboardingDone}) {
    return afterSplash(onboardingDone: onboardingDone);
  }
}
