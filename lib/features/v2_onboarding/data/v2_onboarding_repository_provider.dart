import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../application/v2_onboarding_controller.dart';
import 'v2_onboarding_repository.dart';

final v2OnboardingRepositoryProvider = Provider<V2OnboardingRepository>((ref) {
  return V2OnboardingLocalRepository();
});

V2OnboardingLocalRepository v2OnboardingRepositoryForBox(Box<dynamic> box) {
  return V2OnboardingLocalRepository(box: box);
}

final v2OnboardingControllerProvider =
    ChangeNotifierProvider<V2OnboardingController>((ref) {
  return V2OnboardingController(
    repository: ref.watch(v2OnboardingRepositoryProvider),
  );
});

String get v2OnboardingHiveBoxName => HiveBoxes.v2Onboarding;
