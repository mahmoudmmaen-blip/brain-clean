import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sukoon_daily_program_gate.g.dart';

/// Armed only when Sukoon is opened from Daily Program sukoon step.
@Riverpod(keepAlive: true)
class SukoonDailyProgramGate extends _$SukoonDailyProgramGate {
  @override
  bool build() => false;

  void arm() => state = true;

  void disarm() => state = false;

  bool consume() {
    final armed = state;
    state = false;
    return armed;
  }
}
