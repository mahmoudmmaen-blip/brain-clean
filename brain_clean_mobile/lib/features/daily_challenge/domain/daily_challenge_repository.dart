import 'daily_challenge.dart';

abstract interface class DailyChallengeRepository {
  Future<void> saveTodayChallenge(DailyChallenge challenge);

  Future<DailyChallenge?> getTodayChallenge();

  Future<void> markCompleted();
}
