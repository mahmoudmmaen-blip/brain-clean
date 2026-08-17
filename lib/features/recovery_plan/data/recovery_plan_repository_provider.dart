import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../application/recovery_plan_generator.dart';
import 'recovery_plan_repository.dart';

final recoveryPlanRepositoryProvider =
    Provider<RecoveryPlanRepository>((ref) {
  return RecoveryPlanLocalRepository();
});

RecoveryPlanLocalRepository recoveryPlanRepositoryForBox(Box<dynamic> box) {
  return RecoveryPlanLocalRepository(box: box);
}

final recoveryPlanGeneratorProvider = Provider<RecoveryPlanGenerator>((ref) {
  return RecoveryPlanGenerator(
    planRepository: ref.watch(recoveryPlanRepositoryProvider),
    profileRepository: ref.watch(brainProfileRepositoryProvider),
  );
});

String get recoveryPlanHiveBoxName => HiveBoxes.recoveryPlan;
