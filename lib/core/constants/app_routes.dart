/// Central route paths for [GoRouter].
abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const diagnostic = '/diagnostic';
  static const dashboard = '/dashboard';
  static const detox = '/detox';
  static const recovery = '/recovery';
  static const cognitiveHub = '/cognitive';
  static const cognitiveVisual = '/cognitive/visual';
  static const cognitiveTest = '/cognitive-test';
  static const cognitiveMemory = '/cognitive/memory';
  static const breathingFriction = '/breathing-friction';
  static const emotionWheel = '/emotion-wheel';
  static const silenceChallenge = '/silence-challenge';
  static const singleTask = '/single-task';
  static const delayedGratification = '/delayed-gratification';
  static const onboarding = '/onboarding';
  static const proPaywall = '/pro-paywall';
  static const settings = '/settings';
  static const profile = '/profile';
  static const weeklyReport = '/weekly-report';
  static const pomodoro = '/pomodoro';
  static const games = '/games';
  static const focusedThinking = '/focused-thinking';
  static const crossword = '/crossword';
  static const biometricLock = '/biometric-lock';

  // --- V2 product surfaces (gated by V2FeatureBoundary) ---
  /// CHK-03 — build ProfilePack from completed MeasurementEvent.
  static const v2BrainCheckBuilding = '/v2/brain-check/building';

  /// PRF-01 — Brain Profile reveal.
  static const v2BrainProfile = '/v2/brain-profile';

  /// Temporary completion boundary until Recovery Plan (Slice 4).
  static const v2ProfileReadyBoundary = '/v2/brain-profile/ready';

  /// PLN-00 — build Recovery Plan from ProfilePack.
  static const v2PlanBuilding = '/v2/plan/building';

  /// PLN-01 — Recovery Plan reveal.
  static const v2PlanReveal = '/v2/plan';

  /// Temporary Today-ready boundary (no session player yet).
  static const v2PlanTodayReady = '/v2/plan/today-ready';

  /// V2 onboarding foundation ONB-01…ONB-06.
  static const v2Onboarding = '/v2/onboarding';

  /// CHK-01 entry boundary (no full questionnaire UI yet).
  static const v2BrainCheckEntry = '/v2/brain-check/entry';

  /// Temporary boundary after Brain Check start/resume.
  static const v2BrainCheckReadyBoundary = '/v2/brain-check/ready';
}
