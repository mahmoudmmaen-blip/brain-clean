import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../daily_session/data/daily_session_repository_provider.dart';
import '../../progress/data/progress_repository_provider.dart';
import '../../recovery_plan/data/recovery_plan_repository_provider.dart';
import '../application/weekly_review_controller.dart';
import 'weekly_review_repository_provider.dart';

final weeklyReviewControllerProvider =
    ChangeNotifierProvider<WeeklyReviewController>((ref) {
  return WeeklyReviewController(
    sessions: ref.watch(dailySessionRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    reviews: ref.watch(weeklyReviewRepositoryProvider),
    plans: ref.watch(recoveryPlanRepositoryProvider),
  );
});
