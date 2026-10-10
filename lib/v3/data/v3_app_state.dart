import 'clarity_result.dart';
import 'day_progress.dart';
import 'evening_check_in.dart';
import 'focus_log.dart';
import 'sos_log.dart';
import 'user_inputs.dart';
import 'user_profile.dart';

/// In-memory snapshot of everything stored in [HiveBoxes.v3State].
class V3AppState {
  const V3AppState({
    this.profile,
    this.dayProgress = const [],
    this.clarityResults = const [],
    this.eveningCheckIns = const [],
    this.sosLogs = const [],
    this.focusLogs = const [],
    this.userInputs = const UserInputs(),
    this.day7PaywallShown = false,
  });

  final UserProfile? profile;
  final List<DayProgress> dayProgress;
  final List<ClarityResult> clarityResults;
  final List<EveningCheckIn> eveningCheckIns;
  final List<SosLog> sosLogs;
  final List<FocusLog> focusLogs;
  final UserInputs userInputs;
  final bool day7PaywallShown;

  V3AppState copyWith({
    UserProfile? profile,
    List<DayProgress>? dayProgress,
    List<ClarityResult>? clarityResults,
    List<EveningCheckIn>? eveningCheckIns,
    List<SosLog>? sosLogs,
    List<FocusLog>? focusLogs,
    UserInputs? userInputs,
    bool? day7PaywallShown,
  }) {
    return V3AppState(
      profile: profile ?? this.profile,
      dayProgress: dayProgress ?? this.dayProgress,
      clarityResults: clarityResults ?? this.clarityResults,
      eveningCheckIns: eveningCheckIns ?? this.eveningCheckIns,
      sosLogs: sosLogs ?? this.sosLogs,
      focusLogs: focusLogs ?? this.focusLogs,
      userInputs: userInputs ?? this.userInputs,
      day7PaywallShown: day7PaywallShown ?? this.day7PaywallShown,
    );
  }

  DayProgress? progressForDay(int day) {
    for (final p in dayProgress) {
      if (p.day == day) return p;
    }
    return null;
  }
}
