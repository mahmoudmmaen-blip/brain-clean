import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../brain_check/data/brain_check_local_repository_provider.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../daily_program/application/structured_daily_program_provider.dart';
import '../../daily_program/data/structured_daily_program_repository_provider.dart';
import '../../daily_program/domain/structured_daily_program_builder.dart';
import '../../daily_program/domain/structured_daily_program_scores_resolver.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../progress/data/progress_repository_provider.dart';
import '../../progress/domain/progress_statistics.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import '../../weekly_review/data/weekly_review_repository_provider.dart';
import '../data/daily_session_repository_provider.dart';
import '../domain/daily_day_key.dart';
import '../domain/home_dashboard_metrics.dart';

final homeDashboardProvider =
    FutureProvider.autoDispose<HomeDashboardMetrics>((ref) async {
  final sessions = ref.watch(dailySessionRepositoryProvider);
  final progress = ref.watch(progressRepositoryProvider);
  final profiles = ref.watch(brainProfileRepositoryProvider);
  final brainCheck = ref.watch(brainCheckLocalRepositoryProvider);
  final weeklyReviews = ref.watch(weeklyReviewRepositoryProvider);
  final quickTests = ref.watch(quickTestResultsProvider);
  final now = DateTime.now();
  final dayKey = DailyDayKey.fromLocal(now);

  var programCompletionPercent = 0;
  try {
    final snapshot = await progress.latest();
    final stats = snapshot?.statistics ?? ProgressStatistics.empty;
    final programDay = (stats.completedDays + 1).clamp(1, kHomeProgramTotalDays);
    final weekIndex = structuredDailyProgramWeekIndex(programDay);
    final dayOfYear = now.difference(DateTime(now.year)).inDays + 1;
    final isPro = ref.watch(isProUserProvider);

    var scores = StructuredDailyProgramScoresResolver.fromProfile(
      await profiles.latest(),
    );
    final template = isPro
        ? StructuredDailyProgramBuilder.buildPro(
            scores: scores,
            weekIndex: weekIndex,
            dayOfYear: dayOfYear,
          )
        : StructuredDailyProgramBuilder.buildFree(
            weekIndex: weekIndex,
            dayOfYear: dayOfYear,
          );
    final completions = await ref
        .read(structuredDailyProgramRepositoryProvider)
        .loadCompletions(dayKey);
    if (template.isNotEmpty) {
      final done =
          template.where((a) => completions[a.id] == true).length;
      programCompletionPercent =
          ((done / template.length) * 100).round();
    }
  } catch (_) {
    programCompletionPercent = 0;
  }

  return HomeDashboardMetricsLoader.load(
    profiles: profiles,
    progress: progress,
    sessions: sessions,
    todayDayKey: dayKey,
    brainCheck: brainCheck,
    weeklyReviews: weeklyReviews,
    digitalBrainRotResult: quickTests.digitalBrainRot,
    localNow: now,
    programCompletionPercent: programCompletionPercent,
  );
});

/// Time-of-day greeting key resolver for l10n.
enum HomeGreetingPeriod { morning, afternoon, evening }

HomeGreetingPeriod homeGreetingPeriodFor(DateTime local) {
  final hour = local.hour;
  if (hour >= 5 && hour < 12) return HomeGreetingPeriod.morning;
  if (hour >= 12 && hour < 17) return HomeGreetingPeriod.afternoon;
  return HomeGreetingPeriod.evening;
}

/// Resolves display name from preferences with localized fallback.
String homeDisplayName(AppPreferencesState prefs, String fallbackLabel) {
  final stored = prefs.profileDisplayName.trim();
  return stored.isEmpty ? fallbackLabel : stored;
}
