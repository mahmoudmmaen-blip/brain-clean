import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../daily_session/domain/home_dashboard_metrics.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../data/structured_daily_program_repository_provider.dart';
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
  });

  final List<StructuredDailyActivity> activities;

  /// True when the visible list came from [StructuredDailyProgramBuilder.buildPro].
  final bool isProPersonalized;

  /// Free users see a locked personalized-path row.
  final bool showProLock;
}

final structuredDailyProgramForDayProvider = FutureProvider.autoDispose
    .family<StructuredDailyProgramView, DateTime>((ref, day) async {
  final normalized = DateTime(day.year, day.month, day.day);
  final isPro = ref.watch(isProUserProvider);
  final dashboard = ref.watch(homeDashboardProvider).valueOrNull ??
      HomeDashboardMetrics.empty;
  final weekIndex = structuredDailyProgramWeekIndex(dashboard.programDay);
  final dayKey = structuredDailyProgramDayKey(normalized);

  var scores = StructuredDailyProgramScores.neutral;
  try {
    final profile =
        await ref.read(brainProfileRepositoryProvider).latest();
    scores = StructuredDailyProgramScoresResolver.fromProfile(profile);
  } catch (_) {
    scores = StructuredDailyProgramScores.neutral;
  }

  final template = isPro
      ? StructuredDailyProgramBuilder.buildPro(
          scores: scores,
          weekIndex: weekIndex,
        )
      : StructuredDailyProgramBuilder.buildFree(weekIndex: weekIndex);

  Map<String, bool> completions = const {};
  try {
    completions = await ref
        .read(structuredDailyProgramRepositoryProvider)
        .loadCompletions(dayKey);
  } catch (_) {
    completions = const {};
  }

  final activities = template
      .map(
        (a) => a.copyWith(completed: completions[a.id] == true),
      )
      .toList(growable: false);

  return StructuredDailyProgramView(
    activities: activities,
    isProPersonalized: isPro,
    showProLock: !isPro,
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
    } catch (_) {
      // Persistence best-effort — UI stays usable.
    }
  }
}
