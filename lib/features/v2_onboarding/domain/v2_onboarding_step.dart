/// Approved ONB-01…ONB-06 steps (Build Spec §1). Post-check ONB-07…10 later.
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
}

extension V2OnboardingStepX on V2OnboardingStep {
  String get wireName => switch (this) {
        V2OnboardingStep.welcome => 'welcome',
        V2OnboardingStep.expectations => 'expectations',
        V2OnboardingStep.consent => 'consent',
        V2OnboardingStep.privacy => 'privacy',
        V2OnboardingStep.ritual => 'ritual',
        V2OnboardingStep.checkIntro => 'checkIntro',
      };

  String get screenId => switch (this) {
        V2OnboardingStep.welcome => 'ONB-01',
        V2OnboardingStep.expectations => 'ONB-02',
        V2OnboardingStep.consent => 'ONB-03',
        V2OnboardingStep.privacy => 'ONB-04',
        V2OnboardingStep.ritual => 'ONB-05',
        V2OnboardingStep.checkIntro => 'ONB-06',
      };

  int get orderIndex => index;

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
      case 'welcome':
      default:
        return V2OnboardingStep.welcome;
    }
  }

  V2OnboardingStep? get next {
    final i = index + 1;
    if (i >= V2OnboardingStep.values.length) return null;
    return V2OnboardingStep.values[i];
  }

  V2OnboardingStep? get previous {
    final i = index - 1;
    if (i < 0) return null;
    return V2OnboardingStep.values[i];
  }
}
