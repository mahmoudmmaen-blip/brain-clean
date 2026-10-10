import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content_repository.dart';
import '../data/clarity_result.dart';
import '../data/day_progress.dart';
import '../domain/program_engine.dart';
import 'v3_state_providers.dart';

class ProgramSnapshot {
  const ProgramSnapshot({
    required this.currentDay,
    required this.completedCount,
    required this.isProgramFinished,
    required this.currentStreak,
    required this.nextClarityCheckDay,
    required this.dayProgress,
    required this.clarityResults,
  });

  final int currentDay;
  final int completedCount;
  final bool isProgramFinished;
  final int currentStreak;
  final int? nextClarityCheckDay;
  final List<DayProgress> dayProgress;
  final List<ClarityResult> clarityResults;

  bool isDayUnlocked(int day, DateTime now) {
    return ProgramEngine.isDayUnlocked(
      day: day,
      now: now,
      progress: dayProgress,
    );
  }

  bool isProLocked(int day, bool isPro) {
    return ProgramEngine.isProLocked(day: day, isPro: isPro);
  }

  bool get isSosLocked => ProgramEngine.isSosLocked(isPro: false);
}

final programSnapshotProvider = FutureProvider<ProgramSnapshot>((ref) async {
  final state = await ref.watch(v3AppStateProvider.future);
  final content = await ref.watch(v3ContentProvider.future);
  final now = DateTime.now();

  final clarityTaken = state.clarityResults.map((r) => r.programDay).toSet();

  return ProgramSnapshot(
    currentDay: ProgramEngine.currentDay(state.dayProgress),
    completedCount: ProgramEngine.completedDayCount(state.dayProgress),
    isProgramFinished: ProgramEngine.isProgramFinished(state.dayProgress),
    currentStreak: ProgramEngine.currentStreak(
      progress: state.dayProgress,
      now: now,
    ),
    nextClarityCheckDay: ProgramEngine.nextClarityCheckDay(
      schedule: content.clarityCheck.schedule,
      clarityTakenOnProgramDays: clarityTaken,
    ),
    dayProgress: state.dayProgress,
    clarityResults: state.clarityResults,
  );
});
