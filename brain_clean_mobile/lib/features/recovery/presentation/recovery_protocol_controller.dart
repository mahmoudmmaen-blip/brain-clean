import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/recovery_protocol_storage.dart';
import '../data/recovery_protocol_storage_provider.dart';
import '../domain/recovery_daily_task.dart';
import '../domain/recovery_day_record.dart';
import '../domain/recovery_persistence_exception.dart';
import '../domain/recovery_protocol_constants.dart';
import '../domain/recovery_protocol_state.dart';

part 'recovery_protocol_controller.g.dart';

@Riverpod(keepAlive: true)
class RecoveryProtocolController extends _$RecoveryProtocolController {
  RecoveryProtocolStorage get _storage =>
      ref.read(recoveryProtocolStorageProvider);

  @override
  Future<RecoveryProtocolState> build() async {
    try {
      final saved = await _storage.load();
      if (saved != null) return saved;
    } on RecoveryPersistenceException {
      rethrow;
    } catch (_) {
      // Corrupt box — start a fresh protocol below.
    }

    final initial = RecoveryProtocolState(protocolStartDate: DateTime.now());
    await _persistQuietly(initial);
    return initial;
  }

  Future<void> selectDay(int dayIndex) async {
    if (dayIndex < 1 || dayIndex > RecoveryProtocolConstants.dayCount) {
      return;
    }
    final current = state.requireValue;
    await _commit(current.copyWith(selectedDayIndex: dayIndex));
  }

  Future<void> toggleTask(RecoveryDailyTask task, bool completed) async {
    final current = state.requireValue;
    final dayIndex = current.selectedDayIndex;
    final record = current.dayRecord(dayIndex).toggleTask(task, completed);
    final nextDays = Map<int, RecoveryDayRecord>.from(current.days)
      ..[dayIndex] = record;
    await _commit(current.copyWith(days: nextDays));
  }

  /// Applies penalty for missed habits on the selected day (requires confirmation in UI).
  Future<void> applyPenaltyForSelectedDay() async {
    final current = state.requireValue;
    final dayIndex = current.selectedDayIndex;
    final record = current.dayRecord(dayIndex).copyWith(penaltyApplied: true);
    final nextDays = Map<int, RecoveryDayRecord>.from(current.days)
      ..[dayIndex] = record;
    await _commit(
      current.copyWith(
        days: nextDays,
        totalPenaltyCount: current.totalPenaltyCount + 1,
      ),
    );
  }

  bool selectedDayNeedsPenalty() {
    final current = state.valueOrNull;
    if (current == null) return false;
    final record = current.dayRecord(current.selectedDayIndex);
    return record.hasMissedHabit && !record.penaltyApplied;
  }

  Future<void> reloadFromStorage() async {
    ref.invalidateSelf();
  }

  /// Resets local protocol storage and starts day 1 (used from error recovery UI).
  Future<void> resetProtocolStorage() async {
    try {
      await _storage.clear();
    } catch (_) {
      // Best-effort clear before fresh state.
    }
    state = AsyncValue.data(
      RecoveryProtocolState(protocolStartDate: DateTime.now()),
    );
    await _persistQuietly(state.requireValue);
  }

  Future<void> _commit(RecoveryProtocolState next) async {
    state = AsyncValue.data(next);
    try {
      await _storage.save(next);
    } catch (error, stackTrace) {
      state = AsyncValue<RecoveryProtocolState>.error(
        error,
        stackTrace,
      ).copyWithPrevious(AsyncValue.data(next));
    }
  }

  Future<void> _persistQuietly(RecoveryProtocolState next) async {
    try {
      await _storage.save(next);
    } catch (_) {
      // First-run save is best-effort; UI still shows fresh state.
    }
  }
}
