import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';

part 'streak_freeze_provider.g.dart';

class StreakFreezeState {
  const StreakFreezeState({
    required this.freezesAvailable,
    required this.isFrozen,
    this.lastFreezeUsedDate,
  });

  final int freezesAvailable;
  final bool isFrozen;
  final DateTime? lastFreezeUsedDate;

  static const initial = StreakFreezeState(
    freezesAvailable: 1,
    isFrozen: false,
  );
}

@Riverpod(keepAlive: true)
class StreakFreezeController extends _$StreakFreezeController {
  @override
  StreakFreezeState build() => _load();

  StreakFreezeState _load() {
    try {
      final box = ref.read(appMetaBoxProvider);
      final available =
          box.get(HiveMetaKeys.streakFreezesAvailable, defaultValue: 1) as int;
      final isFrozen =
          box.get(HiveMetaKeys.streakIsFrozen, defaultValue: false) as bool;
      final lastRaw = box.get(HiveMetaKeys.streakLastFreezeUsedDate) as String?;
      return StreakFreezeState(
        freezesAvailable: available,
        isFrozen: isFrozen,
        lastFreezeUsedDate:
            lastRaw != null ? DateTime.tryParse(lastRaw) : null,
      );
    } catch (_) {
      return StreakFreezeState.initial;
    }
  }

  Future<void> _persist(StreakFreezeState next) async {
    try {
      final box = ref.read(appMetaBoxProvider);
      await box.put(HiveMetaKeys.streakFreezesAvailable, next.freezesAvailable);
      await box.put(HiveMetaKeys.streakIsFrozen, next.isFrozen);
      if (next.lastFreezeUsedDate != null) {
        await box.put(
          HiveMetaKeys.streakLastFreezeUsedDate,
          next.lastFreezeUsedDate!.toIso8601String(),
        );
      }
    } catch (_) {
      // Best-effort.
    }
  }

  /// Activates streak freeze if one is available.
  bool useFreeze() {
    if (state.freezesAvailable <= 0 || state.isFrozen) return false;
    final next = StreakFreezeState(
      freezesAvailable: state.freezesAvailable - 1,
      isFrozen: true,
      lastFreezeUsedDate: DateTime.now(),
    );
    state = next;
    _persist(next);
    return true;
  }

  /// Called at midnight after a frozen day — clears freeze flag.
  Future<void> consumeFrozenDay() async {
    if (!state.isFrozen) return;
    final next = StreakFreezeState(
      freezesAvailable: state.freezesAvailable,
      isFrozen: false,
      lastFreezeUsedDate: state.lastFreezeUsedDate,
    );
    state = next;
    await _persist(next);
  }

  /// Resets weekly allowance (every Monday).
  Future<void> resetWeeklyAllowance() async {
    final next = StreakFreezeState(
      freezesAvailable: 1,
      isFrozen: state.isFrozen,
      lastFreezeUsedDate: state.lastFreezeUsedDate,
    );
    state = next;
    await _persist(next);
  }
}
