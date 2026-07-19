import 'package:brain_clean_mobile/features/daily_program/application/daily_program_provider.dart';
import 'package:brain_clean_mobile/features/daily_program/data/daily_program_repository_provider.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_repository.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_service.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_state.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_step.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_streak_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _streakSecondsProvider = StateProvider<int>((ref) => 0);
final _streakDaysProvider = StateProvider<int>((ref) => 3);

class _FakeDailyProgramRepository implements DailyProgramRepository {
  int getTodayCalls = 0;

  @override
  Future<DailyProgramState> getToday({required int dayNumber}) async {
    getTodayCalls++;
    return DailyProgramState(
      date: DateTime(2026, 7, 19),
      dayNumber: dayNumber,
      steps: DailyProgramService.buildTodaySteps(),
    );
  }

  @override
  Future<DailyProgramState> completeStep(DailyStep step) async {
    final current = await getToday(dayNumber: 3);
    return current.copyWith(
      steps: DailyProgramService.afterComplete(current.steps, step),
    );
  }

  @override
  Future<DailyProgramState> skipStep(DailyStep step) async {
    final current = await getToday(dayNumber: 3);
    return current.copyWith(
      steps: DailyProgramService.afterSkip(current.steps, step),
    );
  }
}

void main() {
  test('dailyProgramProvider ignores streak second ticks (no reload jitter)',
      () async {
    final fake = _FakeDailyProgramRepository();
    final container = ProviderContainer(
      overrides: [
        homeStreakSnapshotProvider.overrideWith((ref) {
          return HomeStreakSnapshot(
            days: ref.watch(_streakDaysProvider),
            hours: 1,
            minutes: 2,
            seconds: ref.watch(_streakSecondsProvider),
          );
        }),
        dailyProgramRepositoryProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dailyProgramProvider.future);
    expect(fake.getTodayCalls, 1);

    // Simulate home streak ticker (seconds change every frame/second).
    container.read(_streakSecondsProvider.notifier).state = 1;
    await Future<void>.delayed(Duration.zero);
    container.read(_streakSecondsProvider.notifier).state = 2;
    await Future<void>.delayed(Duration.zero);
    container.read(_streakSecondsProvider.notifier).state = 3;
    await Future<void>.delayed(Duration.zero);

    expect(
      fake.getTodayCalls,
      1,
      reason: 'select(days) must not reload Daily Program on second ticks',
    );

    // Days change should reload once.
    container.read(_streakDaysProvider.notifier).state = 4;
    await container.read(dailyProgramProvider.future);
    expect(fake.getTodayCalls, 2);
  });
}
