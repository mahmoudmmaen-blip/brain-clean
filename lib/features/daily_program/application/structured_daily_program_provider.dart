import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../brain_rot_index/data/bri_results_provider.dart';
import '../../cognitive_tests/application/cognitive_test_results_provider.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../daily_session/domain/home_dashboard_metrics.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import '../data/adaptive_program_state_provider.dart';
import '../data/structured_daily_program_repository_provider.dart';
import '../domain/adaptive_program_engine.dart';
import '../domain/adaptive_program_protocol.dart';
import '../domain/daily_program_personalization.dart';
import '../domain/structured_daily_activity.dart';
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
    required this.plan,
  });

  final List<StructuredDailyActivity> activities;

  /// True when adaptive engine applied (Reset / Ascension).
  final bool isProPersonalized;

  /// Free users needing Pro for Neural Ascension.
  final bool showProLock;

  final DailyProgramTestCoverage coverage;

  /// Motivational banner when no tests completed yet.
  final bool showTestsBanner;

  final AdaptiveProgramPlan plan;
}

final structuredDailyProgramForDayProvider = FutureProvider.autoDispose
    .family<StructuredDailyProgramView, DateTime>((ref, day) async {
  final normalized = DateTime(day.year, day.month, day.day);
  final isPro = ref.watch(isProUserProvider);
  final dashboard = ref.watch(homeDashboardProvider).valueOrNull ??
      HomeDashboardMetrics.empty;
  final dayKey = structuredDailyProgramDayKey(normalized);
  final dayOfYear =
      normalized.difference(DateTime(normalized.year)).inDays + 1;

  var profileScores = StructuredDailyProgramScores.neutral;
  try {
    final profile = await ref.read(brainProfileRepositoryProvider).latest();
    profileScores = StructuredDailyProgramScoresResolver.fromProfile(profile);
  } catch (_) {
    profileScores = StructuredDailyProgramScores.neutral;
  }

  var coverage = DailyProgramTestCoverage.fromResults(
    cognitive: ref.watch(cognitiveTestResultsProvider),
    quick: ref.watch(quickTestResultsProvider),
    profileFallback: profileScores,
  );

  // Prefer live BRI overall as digital-addiction pressure when present.
  final bri = ref.watch(briResultsProvider);
  if (bri != null) {
    coverage = DailyProgramTestCoverage(
      hasFocus: coverage.hasFocus,
      hasMemory: coverage.hasMemory,
      hasIntelligence: coverage.hasIntelligence,
      hasDigitalAddiction: true,
      attentionScore: coverage.attentionScore,
      memoryScore: coverage.memoryScore,
      iqScore: coverage.iqScore,
      digitalAddictionScore: bri.overallScore,
    );
  }

  final engineState = ref.watch(adaptiveProgramStateProvider);
  final plan = AdaptiveProgramEngine.build(
    coverage: coverage,
    isPro: isPro,
    programDay: dashboard.programDay,
    consecutiveMissedDays: engineState.consecutiveMissedDays,
    consecutiveCompleteDays: engineState.consecutiveCompleteDays > 0
        ? engineState.consecutiveCompleteDays
        : dashboard.streakDays,
    difficultyOffset: engineState.difficultyOffset,
    dayOfWeek: normalized.weekday,
    dayOfYear: dayOfYear,
    storedWeekOverride: engineState.weekOverride,
  );

  Map<String, bool> completions = const {};
  try {
    completions = await ref
        .read(structuredDailyProgramRepositoryProvider)
        .loadCompletions(dayKey);
  } catch (_) {
    completions = const {};
  }

  final activities = plan.activities
      .map((a) => a.copyWith(completed: completions[a.id] == true))
      .toList(growable: false);

  return StructuredDailyProgramView(
    activities: activities,
    isProPersonalized: isPro &&
        plan.protocol != AdaptiveProgramProtocol.base &&
        coverage.hasAnyTest,
    showProLock: plan.showUpgradeStrip || plan.freeResetComplete,
    coverage: coverage,
    showTestsBanner: !coverage.hasAnyTest,
    plan: plan,
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

  Future<void> recordFeeling({
    required DateTime day,
    required AdaptiveSessionFeeling feeling,
  }) async {
    try {
      final dayKey = structuredDailyProgramDayKey(day);
      await _ref.read(adaptiveProgramStateProvider.notifier).recordFeeling(
            feeling: feeling,
            dayKey: dayKey,
          );
      _ref.invalidate(
        structuredDailyProgramForDayProvider(
          DateTime(day.year, day.month, day.day),
        ),
      );
    } catch (_) {}
  }
}
