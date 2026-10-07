/// V2 short onboarding steps (max 3 screens before first exercise).
///
/// Legacy wire names (`expectations`, `consent`, …) still decode for resume
/// migration into the short path.
enum V2OnboardingStep {
  /// Screen 1 — Welcome
  welcome,

  /// Screen 2 — Quick setup questions (one scrollable page)
  quickSetup,

  /// Screen 3 — Plan ready → Start Day 1
  planReady,

  // --- Legacy milestones (resume / history only; not shown in short shell) ---
  expectations,
  consent,
  privacy,
  ritual,
  checkIntro,
  profileReveal,
  planReveal,
  todayPreview,
}

extension V2OnboardingStepX on V2OnboardingStep {
  String get wireName => switch (this) {
        V2OnboardingStep.welcome => 'welcome',
        V2OnboardingStep.quickSetup => 'quickSetup',
        V2OnboardingStep.planReady => 'planReady',
        V2OnboardingStep.expectations => 'expectations',
        V2OnboardingStep.consent => 'consent',
        V2OnboardingStep.privacy => 'privacy',
        V2OnboardingStep.ritual => 'ritual',
        V2OnboardingStep.checkIntro => 'checkIntro',
        V2OnboardingStep.profileReveal => 'profileReveal',
        V2OnboardingStep.planReveal => 'planReveal',
        V2OnboardingStep.todayPreview => 'todayPreview',
      };

  String get screenId => switch (this) {
        V2OnboardingStep.welcome => 'ONB-01',
        V2OnboardingStep.quickSetup => 'ONB-02',
        V2OnboardingStep.planReady => 'ONB-03',
        _ => 'ONB-LEGACY',
      };

  /// Index within the short path (0–2).
  int get orderIndex {
    final i = shortPathOrdered.indexOf(normalizedForShell);
    return i < 0 ? 0 : i;
  }

  bool get isShortPathStep =>
      shortPathOrdered.contains(normalizedForShell);

  /// Legacy alias used by journey resolver / older tests.
  bool get isPreCheckStep => isShortPathStep;

  /// Maps legacy in-progress steps onto the short shell.
  V2OnboardingStep get normalizedForShell => switch (this) {
        V2OnboardingStep.welcome => V2OnboardingStep.welcome,
        V2OnboardingStep.quickSetup ||
        V2OnboardingStep.expectations ||
        V2OnboardingStep.consent ||
        V2OnboardingStep.privacy ||
        V2OnboardingStep.ritual =>
          V2OnboardingStep.quickSetup,
        V2OnboardingStep.planReady ||
        V2OnboardingStep.checkIntro ||
        V2OnboardingStep.profileReveal ||
        V2OnboardingStep.planReveal ||
        V2OnboardingStep.todayPreview =>
          V2OnboardingStep.planReady,
      };

  /// Short first-run order (always 3).
  static const shortPathOrdered = <V2OnboardingStep>[
    V2OnboardingStep.welcome,
    V2OnboardingStep.quickSetup,
    V2OnboardingStep.planReady,
  ];

  /// Alias kept for older call sites / tests.
  static const preCheckOrdered = shortPathOrdered;

  static const ordered = V2OnboardingStep.values;

  static V2OnboardingStep fromWire(String? raw) {
    switch (raw) {
      case 'quickSetup':
        return V2OnboardingStep.quickSetup;
      case 'planReady':
        return V2OnboardingStep.planReady;
      case 'expectations':
        return V2OnboardingStep.expectations;
      case 'consent':
        return V2OnboardingStep.consent;
      case 'privacy':
        return V2OnboardingStep.privacy;
      case 'ritual':
        return V2OnboardingStep.ritual;
      case 'checkIntro':
        return V2OnboardingStep.checkIntro;
      case 'profileReveal':
        return V2OnboardingStep.profileReveal;
      case 'planReveal':
        return V2OnboardingStep.planReveal;
      case 'todayPreview':
        return V2OnboardingStep.todayPreview;
      case 'welcome':
      default:
        return V2OnboardingStep.welcome;
    }
  }

  V2OnboardingStep? get next {
    final shell = normalizedForShell;
    final i = shortPathOrdered.indexOf(shell);
    if (i < 0 || i + 1 >= shortPathOrdered.length) return null;
    return shortPathOrdered[i + 1];
  }

  V2OnboardingStep? get previous {
    final shell = normalizedForShell;
    final i = shortPathOrdered.indexOf(shell);
    if (i <= 0) return null;
    return shortPathOrdered[i - 1];
  }
}
