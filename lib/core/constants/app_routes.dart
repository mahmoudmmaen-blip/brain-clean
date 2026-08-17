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

  /// ONB-09 — Today preview (not the daily-session player).
  static const v2PlanTodayPreview = '/v2/plan/today-preview';

  /// HOM-01 — V2 Today / Home tab (shell deep link `/v2/home`).
  static const v2Home = '/v2/home';

  /// Alias of [v2Home] — preserved for existing call sites.
  static const v2Today = v2Home;

  /// Contextual Brain Check entry (not a primary tab; hydrate until user starts).
  static const v2Check = '/v2/check';

  /// PRG-01 — V2 Progress proof experience.
  static const v2Progress = '/v2/progress';

  /// SES-01 prepare.
  static const v2SessionPrepare = '/v2/session/prepare';

  /// SES-02 act.
  static const v2SessionAct = '/v2/session/act';

  /// SES-03 reflect.
  static const v2SessionReflect = '/v2/session/reflect';

  /// SES-04 leave.
  static const v2SessionLeave = '/v2/session/leave';

  /// WRV-01 — Weekly Review questions (gated V2).
  static const v2WeeklyReview = '/v2/weekly-review';

  /// WRV-02 — Weekly Review summary (gated V2).
  static const v2WeeklyReviewSummary = '/v2/weekly-review/summary';

  /// RPT-01 — Reports overview (contextual nested destination; not a primary tab).
  static const v2Reports = '/v2/reports';

  /// RPT-02 — Weekly Artifact detail (gated V2). Query: id=
  static const v2ReportArtifact = '/v2/reports/artifact';

  /// RPT-03 — Recovery measurement history (gated V2).
  static const v2ReportMeasurements = '/v2/reports/measurements';

  /// Profile tab root — personal control center (shell `/v2/profile`).
  /// Brain Profile assessment reveal lives at [v2BrainProfile].
  static const v2Profile = '/v2/profile';

  /// V2 onboarding foundation ONB-01…ONB-06.
  static const v2Onboarding = '/v2/onboarding';

  /// CHK-01 entry boundary alias → [v2Check] contextual route.
  static const v2BrainCheckEntry = '/v2/brain-check/entry';

  /// CHK-02 / CHK-02B / CHK-04 questionnaire flow.
  static const v2BrainCheckFlow = '/v2/brain-check/flow';

  /// Temporary boundary after Brain Check start/resume.
  static const v2BrainCheckReadyBoundary = '/v2/brain-check/ready';

  /// Temporary post-completion boundary (before Profile reveal).
  static const v2BrainCheckCompleteBoundary = '/v2/brain-check/complete';

  /// PRE-01 — V2 Premium appreciation overview (contextual; not a tab).
  static const v2Premium = '/v2/premium';

  /// Purchase / plans surface (store offerings).
  static const v2PremiumPlans = '/v2/premium/plans';

  /// PRE-02 — Premium success.
  static const v2PremiumSuccess = '/v2/premium/success';

  /// PRE-03 — Manage / status.
  static const v2PremiumStatus = '/v2/premium/status';

  /// PRE-03 restore intent.
  static const v2PremiumRestore = '/v2/premium/restore';

  /// Canonical Premium overview with attribution [source].
  static String v2PremiumWithSource(String source) =>
      '$v2Premium?source=${Uri.encodeComponent(source)}';

  /// Canonical Premium status with attribution [source].
  static String v2PremiumStatusWithSource(String source) =>
      '$v2PremiumStatus?source=${Uri.encodeComponent(source)}';

  /// SAF-01 — Contextual Safa support (not a tab). Query: origin=, returnTo=, view=
  static const v2Safa = '/v2/safa';
}
