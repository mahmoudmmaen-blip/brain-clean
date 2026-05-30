import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';

part 'single_task_provider.g.dart';

class SingleTaskState {
  const SingleTaskState({
    this.activeTaskId,
    this.activeTaskLabel,
    this.isLocked = false,
  });

  final String? activeTaskId;
  final String? activeTaskLabel;
  final bool isLocked;

  static const idle = SingleTaskState();
}

@Riverpod(keepAlive: true)
class SingleTaskController extends _$SingleTaskController {
  @override
  SingleTaskState build() => SingleTaskState.idle;

  void startTask(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    state = SingleTaskState(
      activeTaskId: DateTime.now().millisecondsSinceEpoch.toString(),
      activeTaskLabel: trimmed,
      isLocked: true,
    );
  }

  void completeTask() {
    if (!state.isLocked) return;
    ref.read(bcScoreProvider.notifier).applyBonus(10);
    ref.read(appPreferencesProvider.notifier).incrementSingleTaskComplete();
    state = SingleTaskState.idle;
  }

  void abandonTask() {
    state = SingleTaskState.idle;
  }
}
