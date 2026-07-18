import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'silence_challenge_daily_program_gate.g.dart';

/// Armed only when Silence Challenge is opened from Daily Program sukoon.
@Riverpod(keepAlive: true)
class SilenceChallengeDailyProgramGate
    extends _$SilenceChallengeDailyProgramGate {
  @override
  bool build() => false;

  void arm() => state = true;

  void disarm() => state = false;

  /// Returns whether the gate was armed, then clears it.
  bool consume() {
    final armed = state;
    state = false;
    return armed;
  }
}
