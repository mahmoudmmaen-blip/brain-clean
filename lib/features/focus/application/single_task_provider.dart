import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../domain/task_category.dart';

part 'single_task_provider.g.dart';

class SingleTaskState {
  const SingleTaskState({
    this.activeTaskId,
    this.activeTaskLabel,
    this.category = TaskCategory.mental,
    this.difficultyStars = 1,
    this.isLocked = false,
  });

  final String? activeTaskId;
  final String? activeTaskLabel;
  final TaskCategory category;
  final int difficultyStars;
  final bool isLocked;

  static const idle = SingleTaskState();

  double get estimatedBonus =>
      taskCompletionBonus(category, difficultyStars);
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
      final categoryName =
          box.get(HiveMetaKeys.singleTaskCategory, defaultValue: 'mental')
              as String;
      final difficulty = box.get(
        HiveMetaKeys.singleTaskDifficulty,
        defaultValue: 1,
      ) as int;
      return SingleTaskState(
        activeTaskId: box.get(HiveMetaKeys.singleTaskActiveId) as String?,
        activeTaskLabel: box.get(HiveMetaKeys.singleTaskActiveLabel) as String?,
        category: TaskCategory.values.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => TaskCategory.mental,
        ),
        difficultyStars: difficulty.clamp(1, 3),
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
      await box.put(HiveMetaKeys.singleTaskCategory, next.category.name);
      await box.put(HiveMetaKeys.singleTaskDifficulty, next.difficultyStars);
    } catch (_) {
      // Local persistence is best-effort.
    }
  }

  void setCategory(TaskCategory category) {
    if (state.isLocked) return;
    state = SingleTaskState(
      category: category,
      difficultyStars: state.difficultyStars,
    );
  }

  void setDifficulty(int stars) {
    if (state.isLocked) return;
    state = SingleTaskState(
      category: state.category,
      difficultyStars: stars.clamp(1, 3),
    );
  }

  void startTask(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final next = SingleTaskState(
      activeTaskId: DateTime.now().millisecondsSinceEpoch.toString(),
      activeTaskLabel: trimmed,
      category: state.category,
      difficultyStars: state.difficultyStars,
      isLocked: true,
    );
    state = next;
    _persist(next);
  }

  void completeTask() {
    if (!state.isLocked) return;
    final bonus = taskCompletionBonus(state.category, state.difficultyStars);
    ref.read(bcScoreProvider.notifier).applyBonus(bonus);
    ref.read(appPreferencesProvider.notifier).incrementSingleTaskComplete();
    state = SingleTaskState.idle;
    _persist(SingleTaskState.idle);
  }

  /// Abandons the task and applies a partial focus penalty.
  bool abandonTask() {
    if (!state.isLocked) return false;
    ref.read(bcScoreProvider.notifier).applyPenalty(taskAbandonPenalty);
    state = SingleTaskState.idle;
    _persist(SingleTaskState.idle);
    return true;
  }
}
