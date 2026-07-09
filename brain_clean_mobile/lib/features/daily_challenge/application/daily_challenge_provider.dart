import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/daily_challenge_repository_provider.dart';
import '../domain/daily_challenge.dart';
import '../domain/daily_challenge_service.dart';

part 'daily_challenge_provider.g.dart';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

@Riverpod(keepAlive: true)
class DailyChallengeController extends _$DailyChallengeController {
  @override
  Future<DailyChallenge> build() async {
    final repo = ref.read(dailyChallengeRepositoryProvider);
    final today = _dateOnly(DateTime.now());

    final existing = await repo.getTodayChallenge();
    if (existing != null) return existing;

    final challenge = DailyChallenge(
      date: today,
      gameKey: DailyChallengeService.getGameForDate(today),
      isCompleted: false,
    );
    await repo.saveTodayChallenge(challenge);
    return challenge;
  }

  Future<void> markCompleted() async {
    final repo = ref.read(dailyChallengeRepositoryProvider);
    await repo.markCompleted();
    final updated = await repo.getTodayChallenge();
    if (updated != null) {
      state = AsyncData(updated);
    }
  }
}
