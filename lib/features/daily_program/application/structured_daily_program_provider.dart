import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../cognitive_tests/application/cognitive_test_results_provider.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../daily_session/domain/home_dashboard_metrics.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import '../data/structured_daily_program_repository_provider.dart';
import '../domain/daily_program_personalization.dart';
import '../domain/structured_daily_activity.dart';
import '../domain/structured_daily_program_builder.dart';
import '../domain/structured_daily_program_scores_resolver.dart';

/// 0-based week index from program day (day 1–7 → 0, 8–14 → 1, …).
int structuredDailyProgramWeekIndex(int programDay) {
  final day = programDay < 1 ? 1 : programDay;
  return (day - 1) ~/ 7;
}

String structuredDailyProgramDayKey(DateTime day) {
  final local = DateTime(day.year, day.month, day.day);
  return DailyDayKey.fromLocal(local);
}

class StructuredDailyProgramView {
  const StructuredDailyProgramView({
    required this.activities,
    required this.isProPersonalized,
    required this.showProLock,
    required this.coverage,
    required this.showTestsBanner,
  });

  final List<StructuredDailyActivity> activities;

  /// True when the visible list came from personalized / Pro builder.
  final bool isProPersonalized;

  /// Free users see a locked personalized-path row.
  final bool showProLock;

  final DailyProgramTestCoverage coverage;

  /// Motivational banner when no tests completed yet.
  final bool showTestsBanner;
}

final structuredDailyProgramForDayProvider = FutureProvider.autoDispose
    .family<StructuredDailyProgramView, DateTime>((ref, day) async {
  final normalized = DateTime(day.year, day.month, day.day);
  final isPro = ref.watch(isProUserProvider);
  final dashboard = ref.watch(homeDashboardProvider).valueOrNull ??
      HomeDashboardMetrics.empty;
  final weekIndex = structuredDailyProgramWeekIndex(dashboard.programDay);
  final dayKey = structuredDailyProgramDayKey(normalized);
  final dayOfYear =
      normalized.difference(DateTime(normalized.year)).inDays + 1;

  final coverage = DailyProgramTestCoverage.fromResults(
    cognitive: ref.watch(cognitiveTestResultsProvider),
    quick: ref.watch(quickTestResultsProvider),
  );

  var scores = StructuredDailyProgramScores.neutral;
  try {
    final profile = await ref.read(brainProfileRepositoryProvider).latest();
    scores = StructuredDailyProgramScoresResolver.fromProfile(profile);
  } catch (_) {
    scores = StructuredDailyProgramScores.neutral;
  }

  // Prefer score signal from completed tests when available.
  scores = StructuredDailyProgramScores(
    attention: coverage.hasFocus ? coverage.attentionScore : scores.attention,
    memory: coverage.hasMemory ? coverage.memoryScore : scores.memory,
    digitalAddiction: coverage.hasDigitalAddiction
        ? coverage.digitalAddictionScore
        : scores.digitalAddiction,
  );

  final List<StructuredDailyActivity> template;
  if (coverage.hasFullCoverage) {
    template = PersonalizedDailyProgramBuilder.build(
      coverage: coverage,
      weekIndex: weekIndex,
      dayOfYear: dayOfYear,
    );
  } else if (isPro) {
    template = StructuredDailyProgramBuilder.buildPro(
      scores: scores,
      weekIndex: weekIndex,
      dayOfYear: dayOfYear,
    );
  } else {
    template = StructuredDailyProgramBuilder.buildFree(
      weekIndex: weekIndex,
      dayOfYear: dayOfYear,
    );
  }

  Map<String, bool> completions = const {};
  try {
    completions = await ref
        .read(structuredDailyProgramRepositoryProvider)
        .loadCompletions(dayKey);
  } catch (_) {
    completions = const {};
  }

  final activities = template
      .map((a) => a.copyWith(completed: completions[a.id] == true))
      .toList(growable: false);

  return StructuredDailyProgramView(
    activities: activities,
    isProPersonalized: coverage.hasFullCoverage || isPro,
    showProLock: !isPro && !coverage.hasFullCoverage,
    coverage: coverage,
    showTestsBanner: !coverage.hasAnyTest,
  );
});

final structuredDailyProgramControllerProvider =
    Provider<StructuredDailyProgramController>((ref) {
  return StructuredDailyProgramController(ref);
});

class StructuredDailyProgramController {
  StructuredDailyProgramController(this._ref);

  final Ref _ref;

  Future<void> toggle({
    required DateTime day,
    required String activityId,
    required bool completed,
  }) async {
    try {
      final dayKey = structuredDailyProgramDayKey(day);
      await _ref.read(structuredDailyProgramRepositoryProvider).setCompleted(
            dayKey: dayKey,
            activityId: activityId,
            completed: completed,
          );
      _ref.invalidate(
        structuredDailyProgramForDayProvider(
          DateTime(day.year, day.month, day.day),
        ),
      );
      _ref.invalidate(homeDashboardProvider);
    } catch (_) {
      // Persistence best-effort — UI stays usable.
    }
  }
}
