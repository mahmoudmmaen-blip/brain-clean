import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../recovery_plan/data/recovery_plan_repository_provider.dart';
import '../application/daily_session_controller.dart';
import 'daily_session_repository_provider.dart';

final dailySessionControllerProvider =
    ChangeNotifierProvider<DailySessionController>((ref) {
  return DailySessionController(
    sessions: ref.watch(dailySessionRepositoryProvider),
    plans: ref.watch(recoveryPlanRepositoryProvider),
    profilePackExists: () async {
      try {
        final pack = await ref.read(brainProfileRepositoryProvider).latest();
        return pack != null;
      } catch (_) {
        return false;
      }
    },
  );
});
