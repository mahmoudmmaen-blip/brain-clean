import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recovery_plan/data/recovery_plan_repository_provider.dart';
import '../application/daily_session_controller.dart';
import 'daily_session_repository_provider.dart';

final dailySessionControllerProvider =
    ChangeNotifierProvider<DailySessionController>((ref) {
  return DailySessionController(
    sessions: ref.watch(dailySessionRepositoryProvider),
    plans: ref.watch(recoveryPlanRepositoryProvider),
  );
});
