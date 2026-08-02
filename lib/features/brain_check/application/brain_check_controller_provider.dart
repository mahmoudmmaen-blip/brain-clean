import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/brain_check_local_repository_provider.dart';
import '../domain/recovery_score_bridge.dart';
import 'brain_check_controller.dart';

/// Provides a hydrated [BrainCheckController] for later UI slices.
final brainCheckControllerProvider =
    ChangeNotifierProvider<BrainCheckController>((ref) {
  final controller = BrainCheckController(
    repository: ref.watch(brainCheckLocalRepositoryProvider),
    scoreBridge: const PendingRecoveryScoreBridge(),
  );
  // Fire-and-forget hydrate; UI slices await [isHydrated] / listen.
  // ignore: discarded_futures
  controller.hydrate();
  ref.onDispose(controller.dispose);
  return controller;
});
