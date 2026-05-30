import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
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
  SingleTaskState build() => _restoreFromHive();

  SingleTaskState _restoreFromHive() {
    try {
      final box = ref.read(appMetaBoxProvider);
      final isLocked =
          box.get(HiveMetaKeys.singleTaskIsLocked, defaultValue: false) as bool;
      if (!isLocked) return SingleTaskState.idle;
      return SingleTaskState(
        activeTaskId: box.get(HiveMetaKeys.singleTaskActiveId) as String?,
        activeTaskLabel: box.get(HiveMetaKeys.singleTaskActiveLabel) as String?,
        isLocked: true,
      );
    } catch (_) {
      return SingleTaskState.idle;
    }
  }

  Future<void> _persist(SingleTaskState next) async {
    try {
      final box = ref.read(appMetaBoxProvider);
      if (!next.isLocked) {
        await box.delete(HiveMetaKeys.singleTaskActiveId);
        await box.delete(HiveMetaKeys.singleTaskActiveLabel);
        await box.put(HiveMetaKeys.singleTaskIsLocked, false);
        return;
      }
      await box.put(HiveMetaKeys.singleTaskActiveId, next.activeTaskId);
      await box.put(HiveMetaKeys.singleTaskActiveLabel, next.activeTaskLabel);
      await box.put(HiveMetaKeys.singleTaskIsLocked, true);
    } catch (_) {
      // Local persistence is best-effort.
    }
  }

  void startTask(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final next = SingleTaskState(
      activeTaskId: DateTime.now().millisecondsSinceEpoch.toString(),
      activeTaskLabel: trimmed,
      isLocked: true,
    );
    state = next;
    _persist(next);
  }

  void completeTask() {
    if (!state.isLocked) return;
    ref.read(bcScoreProvider.notifier).applyBonus(10);
    ref.read(appPreferencesProvider.notifier).incrementSingleTaskComplete();
    state = SingleTaskState.idle;
    _persist(SingleTaskState.idle);
  }

  void abandonTask() {
    state = SingleTaskState.idle;
    _persist(SingleTaskState.idle);
  }
}
