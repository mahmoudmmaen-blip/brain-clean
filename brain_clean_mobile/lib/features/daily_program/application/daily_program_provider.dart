import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/home_streak_provider.dart';
import '../data/daily_program_repository_provider.dart';
import '../domain/daily_program_service.dart';
import '../domain/daily_program_state.dart';
import '../domain/daily_step.dart';

part 'daily_program_provider.g.dart';

@Riverpod(keepAlive: true)
class DailyProgram extends _$DailyProgram {
  String? lastMicroReward;

  @override
  Future<DailyProgramState> build() async {
    final dayNumber = ref.watch(homeStreakSnapshotProvider).days;
    return ref.read(dailyProgramRepositoryProvider).getToday(
          dayNumber: dayNumber < 1 ? 1 : dayNumber,
        );
  }

  Future<void> completeStep(DailyStep step) async {
    try {
      lastMicroReward = DailyProgramService.getMicroReward(step);
      final dayNumber = ref.read(homeStreakSnapshotProvider).days;
      final repo = ref.read(dailyProgramRepositoryProvider);
      // Preserve day number while mutating steps.
      final current = state.valueOrNull;
      final updated = await repo.completeStep(step);
      state = AsyncData(
        updated.copyWith(
          dayNumber: current?.dayNumber ?? (dayNumber < 1 ? 1 : dayNumber),
        ),
      );
    } catch (_) {
      // Keep prior state on failure.
    }
  }

  Future<void> skipStep(DailyStep step) async {
    if (step != DailyStep.journal) return;
    try {
      lastMicroReward = null;
      final dayNumber = ref.read(homeStreakSnapshotProvider).days;
      final current = state.valueOrNull;
      final updated =
          await ref.read(dailyProgramRepositoryProvider).skipStep(step);
      state = AsyncData(
        updated.copyWith(
          dayNumber: current?.dayNumber ?? (dayNumber < 1 ? 1 : dayNumber),
        ),
      );
    } catch (_) {}
  }
}
