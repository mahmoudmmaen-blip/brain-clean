import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../daily_session/data/daily_session_repository_provider.dart';
import '../../recovery_plan/data/recovery_plan_repository_provider.dart';
import '../../weekly_review/data/weekly_review_repository_provider.dart';
import '../application/progress_experience_controller.dart';
import 'progress_repository_provider.dart';

final progressExperienceControllerProvider =
    ChangeNotifierProvider<ProgressExperienceController>((ref) {
  return ProgressExperienceController(
    sessions: ref.watch(dailySessionRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    reviews: ref.watch(weeklyReviewRepositoryProvider),
    plans: ref.watch(recoveryPlanRepositoryProvider),
    profiles: ref.watch(brainProfileRepositoryProvider),
  );
});
