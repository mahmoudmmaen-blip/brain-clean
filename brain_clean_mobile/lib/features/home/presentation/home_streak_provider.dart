import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../recovery/presentation/recovery_protocol_controller.dart';

part 'home_streak_provider.g.dart';

/// Elapsed streak components for the home timer grid.
class HomeStreakSnapshot {
  const HomeStreakSnapshot({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;
}

/// Cumulative retrograde (e.g. −12h distraction penalty).
@Riverpod(keepAlive: true)
class HomeStreakRetrograde extends _$HomeStreakRetrograde {
  @override
  Duration build() => Duration.zero;

  void applyHours(int hours) {
    state = state + Duration(hours: hours);
  }
}

@riverpod
Stream<int> homeStreakTicker(HomeStreakTickerRef ref) {
  return Stream.periodic(const Duration(seconds: 1), (tick) => tick);
}

@riverpod
HomeStreakSnapshot homeStreakSnapshot(HomeStreakSnapshotRef ref) {
  ref.watch(homeStreakTickerProvider);
  final retrograde = ref.watch(homeStreakRetrogradeProvider);
  final recovery = ref.watch(recoveryProtocolControllerProvider);
  final anchor =
      recovery.valueOrNull?.protocolStartDate ?? DateTime.now();
  final elapsed = DateTime.now().difference(anchor) - retrograde;
  final safe = elapsed.isNegative ? Duration.zero : elapsed;

  return HomeStreakSnapshot(
    days: safe.inDays,
    hours: safe.inHours.remainder(24),
    minutes: safe.inMinutes.remainder(60),
    seconds: safe.inSeconds.remainder(60),
  );
}
