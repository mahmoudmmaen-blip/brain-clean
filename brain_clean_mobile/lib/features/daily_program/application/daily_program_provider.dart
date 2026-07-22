import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/home_streak_provider.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
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
    // Select days only — full snapshot ticks every second and would
    // rebuild this provider continuously (screen jitter).
    final dayNumber = ref.watch(
      homeStreakSnapshotProvider.select((s) => s.days),
    );
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
      await ref
          .read(recoveryProtocolControllerProvider.notifier)
          .applyDailyProgramStep(step);
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

  Future<void> completeDayEnd({String? reflectionNote}) async {
    try {
      lastMicroReward = DailyProgramService.getMicroReward(DailyStep.dayEnd);
      final dayNumber = ref.read(homeStreakSnapshotProvider).days;
      final current = state.valueOrNull;
      final updated = await ref
          .read(dailyProgramRepositoryProvider)
          .completeDayEnd(reflectionNote: reflectionNote);
      state = AsyncData(
        updated.copyWith(
          dayNumber: current?.dayNumber ?? (dayNumber < 1 ? 1 : dayNumber),
        ),
      );
    } catch (_) {
      // Keep prior state on failure.
    }
  }
}
