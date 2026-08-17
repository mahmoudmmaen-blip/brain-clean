import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../daily_session/data/daily_session_repository_provider.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../progress/data/progress_repository_provider.dart';
import '../../weekly_review/data/weekly_review_repository_provider.dart';
import '../application/reports_controller.dart';

final reportsControllerProvider =
    ChangeNotifierProvider<ReportsController>((ref) {
  return ReportsController(
    sessions: ref.watch(dailySessionRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    reviews: ref.watch(weeklyReviewRepositoryProvider),
    profiles: ref.watch(brainProfileRepositoryProvider),
    isPremium: () => ref.read(isProUserProvider),
  );
});
