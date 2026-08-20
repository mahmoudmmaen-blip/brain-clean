import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../brain_check/data/brain_check_local_repository_provider.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../progress/data/progress_repository_provider.dart';
import '../data/daily_session_repository_provider.dart';
import '../domain/daily_day_key.dart';
import '../domain/home_dashboard_metrics.dart';

final homeDashboardProvider =
    FutureProvider.autoDispose<HomeDashboardMetrics>((ref) async {
  final sessions = ref.watch(dailySessionRepositoryProvider);
  final progress = ref.watch(progressRepositoryProvider);
  final profiles = ref.watch(brainProfileRepositoryProvider);
  final brainCheck = ref.watch(brainCheckLocalRepositoryProvider);
  final now = DateTime.now();
  final dayKey = DailyDayKey.fromLocal(now);
  return HomeDashboardMetricsLoader.load(
    profiles: profiles,
    progress: progress,
    sessions: sessions,
    todayDayKey: dayKey,
    brainCheck: brainCheck,
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
