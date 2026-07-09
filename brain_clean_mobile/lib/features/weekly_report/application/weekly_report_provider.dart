import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../anxiety/data/anxiety_repository_provider.dart';
import '../../cognitive_tests/application/cognitive_test_results_provider.dart';
import '../../daily_challenge/data/daily_challenge_repository_provider.dart';
import '../../dashboard/data/daily_snapshots_repository.dart';
import '../../games/application/games_scores_provider.dart';
import '../../home/presentation/home_streak_provider.dart';
import '../../worry/data/worry_repository_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../domain/week_range.dart';
import '../domain/weekly_report_data.dart';
import '../domain/weekly_report_service.dart';

part 'weekly_report_provider.g.dart';

double _averageBciForWeek(
  List<double> values,
) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

bool _isInWeek(DateTime date, WeekRange range) => isDateInRange(date, range);

@riverpod
Future<WeeklyReportData> weeklyReport(WeeklyReportRef ref) async {
  final isArabic = ref.watch(localeProvider).languageCode == 'ar';
  final now = DateTime.now();
  final currentWeek = weekRangeContaining(now);
  final lastWeek = previousWeekRange(currentWeek);

  final weekSnapshots = <double>[];
  final lastWeekSnapshots = <double>[];

  try {
    final allSnapshots = ref.read(dailySnapshotsRepositoryProvider).loadAll();
    for (final snapshot in allSnapshots) {
      if (isPaddedSnapshotDate(snapshot.date)) continue;
      if (_isInWeek(snapshot.date, currentWeek)) {
        weekSnapshots.add(snapshot.bcsValue);
      } else if (_isInWeek(snapshot.date, lastWeek)) {
        lastWeekSnapshots.add(snapshot.bcsValue);
      }
    }
  } catch (_) {}

  final hasBciData = weekSnapshots.isNotEmpty;
  final avgBci = _averageBciForWeek(weekSnapshots);
  final lastAvgBci = _averageBciForWeek(lastWeekSnapshots);
  final bciChange = hasBciData ? (avgBci - lastAvgBci).toDouble() : 0.0;

  final gamesBest = ref.read(gamesBestScoresControllerProvider);
  final cognitive = ref.read(cognitiveTestResultsProvider);

  var gamesPlayed = 0;
  final visual = cognitive.visualAttention;
  if (visual != null && _isInWeek(visual.completedAt, currentWeek)) {
    gamesPlayed += visual.visualRoundsPlayed ?? 1;
  }
  final memory = cognitive.memorySequence;
  if (memory != null && _isInWeek(memory.completedAt, currentWeek)) {
    gamesPlayed += 1;
  }

  final dailyChallenge = await ref.read(dailyChallengeRepositoryProvider).getTodayChallenge();
  var dailyChallengesCompleted = 0;
  if (dailyChallenge != null &&
      dailyChallenge.isCompleted &&
      dailyChallenge.completedAt != null &&
      _isInWeek(dailyChallenge.completedAt!, currentWeek)) {
    dailyChallengesCompleted = 1;
    gamesPlayed += 1;
  }

  final bestGameName = WeeklyReportService.bestGameArabicName(
    nBack: gamesBest.nBack,
    speedSort: gamesBest.speedSort,
    colorWord: gamesBest.colorWord,
    numberMemory: gamesBest.numberMemory,
    patternMatch: gamesBest.patternMatch,
  );

  final streakDays = ref.read(homeStreakSnapshotProvider).days;

  final worryEntries = await ref.read(worryRepositoryProvider).getAllEntries();
  final worryEntriesCount = worryEntries
      .where((entry) => _isInWeek(entry.createdAt, currentWeek))
      .length;

  final anxietyResults =
      await ref.read(anxietyRepositoryProvider).getAllResults();
  double? anxietyScore;
  for (final result in anxietyResults.reversed) {
    if (_isInWeek(result.timestamp, currentWeek)) {
      anxietyScore = result.score;
      break;
    }
  }

  final draft = WeeklyReportData(
    weekStart: currentWeek.start,
    weekEnd: currentWeek.end,
    avgBciScore: avgBci,
    bciChange: bciChange,
    hasBciData: hasBciData,
    gamesPlayed: gamesPlayed,
    bestGameName: bestGameName,
    streakDays: streakDays,
    worryEntriesCount: worryEntriesCount,
    anxietyScore: anxietyScore,
    dailyChallengesCompleted: dailyChallengesCompleted,
    motivationalMessage: '',
  );

  return draft.copyWith(
    motivationalMessage: WeeklyReportService.getMotivationalMessage(
      draft,
      isArabic: isArabic,
    ),
  );
}
