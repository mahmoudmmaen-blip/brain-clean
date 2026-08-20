import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../progress/data/pillar_metrics_repository_provider.dart';
import '../../recovery_plan/data/recovery_plan_repository_provider.dart';
import '../application/interactive_diagnostic_profile_bridge.dart';

final interactiveDiagnosticProfileBridgeProvider =
    Provider<InteractiveDiagnosticProfileBridge>((ref) {
  return InteractiveDiagnosticProfileBridge(
    profileRepository: ref.watch(brainProfileRepositoryProvider),
    planGenerator: ref.watch(recoveryPlanGeneratorProvider),
    pillarMetricsRepository: ref.watch(pillarMetricsRepositoryProvider),
  );
});
