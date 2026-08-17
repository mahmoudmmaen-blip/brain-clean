import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../application/brain_profile_generator.dart';
import 'brain_profile_repository.dart';

final brainProfileRepositoryProvider =
    Provider<BrainProfileRepository>((ref) {
  return BrainProfileLocalRepository();
});

/// Test helper — inject an open Hive box.
BrainProfileLocalRepository brainProfileRepositoryForBox(Box<dynamic> box) {
  return BrainProfileLocalRepository(box: box);
}

final brainProfileGeneratorProvider = Provider<BrainProfileGenerator>((ref) {
  return BrainProfileGenerator(
    repository: ref.watch(brainProfileRepositoryProvider),
  );
});

/// Convenience: box name for tests asserting isolation.
String get brainProfileHiveBoxName => HiveBoxes.brainProfile;
