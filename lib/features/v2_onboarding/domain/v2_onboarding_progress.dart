/// Optional ritual cue window (ONB-05). Null = decide later.
enum V2RitualWindow {
  morning,
  afternoon,
  evening,
}

extension V2RitualWindowX on V2RitualWindow {
  String get wireName => name;

  static V2RitualWindow? fromWire(String? raw) {
    switch (raw) {
      case 'morning':
        return V2RitualWindow.morning;
      case 'afternoon':
        return V2RitualWindow.afternoon;
      case 'evening':
        return V2RitualWindow.evening;
      default:
        return null;
    }
  }
}

/// Progress counters for accessibility / UI.
class V2OnboardingProgress {
  const V2OnboardingProgress({
    required this.currentStepIndex,
    required this.totalSteps,
  });

  final int currentStepIndex;
  final int totalSteps;

  int get displayStep => currentStepIndex + 1;
  double get fraction =>
      totalSteps <= 0 ? 0 : (currentStepIndex + 1) / totalSteps;
}
