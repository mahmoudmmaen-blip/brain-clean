import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/brain_check_completion.dart';
import '../domain/brain_check_result.dart';
import 'brain_check_local_repository_provider.dart';

/// Shared Brain Check completion — Home / Progress / Profile must watch this.
final brainCheckCompletionProvider =
    FutureProvider.autoDispose<BrainCheckResult?>((ref) async {
  final repo = ref.watch(brainCheckLocalRepositoryProvider);
  return BrainCheckCompletion.loadResult(repo);
});

final brainCheckIsCompletedProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(brainCheckCompletionProvider).maybeWhen(
        data: BrainCheckCompletion.fromResult,
        orElse: () => false,
      );
});
