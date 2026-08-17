import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../daily_session/data/daily_session_repository_provider.dart';
import '../../recovery_plan/data/recovery_plan_repository_provider.dart';
import '../application/progress_controller.dart';
import 'progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressLocalRepository();
});

final progressControllerProvider =
    ChangeNotifierProvider<ProgressController>((ref) {
  return ProgressController(
    sessions: ref.watch(dailySessionRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    plans: ref.watch(recoveryPlanRepositoryProvider),
  );
});
