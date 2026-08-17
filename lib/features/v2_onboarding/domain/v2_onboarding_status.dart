/// Lifecycle of the V2 pre-check onboarding foundation.
enum V2OnboardingStatus {
  notStarted,
  inProgress,

  /// Finished ONB-06 and handed off to CHK-01 (Slice 5.1 terminal).
  readyForBrainCheck,

  /// Reserved for ONB-10 full FTE completion (not set by Slice 5.1 path).
  completed,

  /// Stored JSON could not be trusted; safe empty resume.
  corrupt,
}

extension V2OnboardingStatusX on V2OnboardingStatus {
  String get wireName => switch (this) {
        V2OnboardingStatus.notStarted => 'notStarted',
        V2OnboardingStatus.inProgress => 'inProgress',
        V2OnboardingStatus.readyForBrainCheck => 'readyForBrainCheck',
        V2OnboardingStatus.completed => 'completed',
        V2OnboardingStatus.corrupt => 'corrupt',
      };

  static V2OnboardingStatus fromWire(String? raw) {
    switch (raw) {
      case 'inProgress':
        return V2OnboardingStatus.inProgress;
      case 'readyForBrainCheck':
        return V2OnboardingStatus.readyForBrainCheck;
      case 'completed':
        return V2OnboardingStatus.completed;
      case 'corrupt':
        return V2OnboardingStatus.corrupt;
      case 'notStarted':
      default:
        return V2OnboardingStatus.notStarted;
    }
  }
}
