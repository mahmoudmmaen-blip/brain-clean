/// Approved V2 onboarding steps (Build Spec §1).
///
/// Pre-check linear path: ONB-01…ONB-06.
/// Post-check milestones: ONB-07…ONB-09 (ONB-10 uses [V2OnboardingStatus.completed]).
enum V2OnboardingStep {
  /// ONB-01 Welcome
  welcome,

  /// ONB-02 Expectations
  expectations,

  /// ONB-03 Consent
  consent,

  /// ONB-04 Privacy
  privacy,

  /// ONB-05 Ritual window
  ritual,

  /// ONB-06 Brain Check intro
  checkIntro,

  /// ONB-07 Post-check Profile reveal milestone.
  profileReveal,

  /// ONB-08 Plan reveal milestone.
  planReveal,

  /// ONB-09 Today preview / handoff milestone (not the session player).
  todayPreview,
}

extension V2OnboardingStepX on V2OnboardingStep {
  String get wireName => switch (this) {
        V2OnboardingStep.welcome => 'welcome',
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
        V2OnboardingStep.expectations => 'ONB-02',
        V2OnboardingStep.consent => 'ONB-03',
        V2OnboardingStep.privacy => 'ONB-04',
        V2OnboardingStep.ritual => 'ONB-05',
        V2OnboardingStep.checkIntro => 'ONB-06',
        V2OnboardingStep.profileReveal => 'ONB-07',
        V2OnboardingStep.planReveal => 'ONB-08',
        V2OnboardingStep.todayPreview => 'ONB-09',
      };

  /// Index within the pre-check path (0–5). Post-check steps report as step 6.
  int get orderIndex => switch (this) {
        V2OnboardingStep.profileReveal ||
        V2OnboardingStep.planReveal ||
        V2OnboardingStep.todayPreview =>
          preCheckOrdered.length - 1,
        _ => index,
      };

  bool get isPreCheckStep =>
      this != V2OnboardingStep.profileReveal &&
      this != V2OnboardingStep.planReveal &&
      this != V2OnboardingStep.todayPreview;

  /// Linear pre-check order used by the onboarding shell (always 6).
  static const preCheckOrdered = <V2OnboardingStep>[
    V2OnboardingStep.welcome,
    V2OnboardingStep.expectations,
    V2OnboardingStep.consent,
    V2OnboardingStep.privacy,
    V2OnboardingStep.ritual,
    V2OnboardingStep.checkIntro,
  ];

  static const ordered = V2OnboardingStep.values;

  static V2OnboardingStep fromWire(String? raw) {
    switch (raw) {
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

  /// Pre-check navigation only — ONB-06 has no next inside the shell.
  V2OnboardingStep? get next {
    if (!isPreCheckStep || this == V2OnboardingStep.checkIntro) {
      return null;
    }
    final i = preCheckOrdered.indexOf(this);
    if (i < 0 || i + 1 >= preCheckOrdered.length) return null;
    return preCheckOrdered[i + 1];
  }

  V2OnboardingStep? get previous {
    if (this == V2OnboardingStep.profileReveal ||
        this == V2OnboardingStep.planReveal ||
        this == V2OnboardingStep.todayPreview) {
      return V2OnboardingStep.checkIntro;
    }
    final i = preCheckOrdered.indexOf(this);
    if (i <= 0) return null;
    return preCheckOrdered[i - 1];
  }
}
