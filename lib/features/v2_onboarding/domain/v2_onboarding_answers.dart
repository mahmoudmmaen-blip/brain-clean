import 'v2_onboarding_progress.dart';

/// Main goal chosen during short onboarding quick setup.
enum V2OnboardingGoal {
  focus,
  sleep,
  lessScrolling,
  calm,
}

extension V2OnboardingGoalX on V2OnboardingGoal {
  String get wireName => name;

  static V2OnboardingGoal? fromWire(String? raw) {
    switch (raw) {
      case 'focus':
        return V2OnboardingGoal.focus;
      case 'sleep':
        return V2OnboardingGoal.sleep;
      case 'lessScrolling':
        return V2OnboardingGoal.lessScrolling;
      case 'calm':
        return V2OnboardingGoal.calm;
      default:
        return null;
    }
  }
}

/// Daily screen-time band for quick setup.
enum V2ScreenHoursBand {
  under2,
  from2to4,
  from4to6,
  over6,
}

extension V2ScreenHoursBandX on V2ScreenHoursBand {
  String get wireName => name;

  static V2ScreenHoursBand? fromWire(String? raw) {
    switch (raw) {
      case 'under2':
        return V2ScreenHoursBand.under2;
      case 'from2to4':
        return V2ScreenHoursBand.from2to4;
      case 'from4to6':
        return V2ScreenHoursBand.from4to6;
      case 'over6':
        return V2ScreenHoursBand.over6;
      default:
        return null;
    }
  }
}

/// Hardest time of day (reuses ritual window labels).
typedef V2HardestTime = V2RitualWindow;
