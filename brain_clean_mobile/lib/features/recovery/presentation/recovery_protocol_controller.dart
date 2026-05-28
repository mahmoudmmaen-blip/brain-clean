import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/recovery_daily_task.dart';
import '../domain/recovery_day_record.dart';
import '../domain/recovery_protocol_constants.dart';
import '../domain/recovery_protocol_state.dart';

part 'recovery_protocol_controller.g.dart';

@riverpod
class RecoveryProtocolController extends _$RecoveryProtocolController {
  @override
  RecoveryProtocolState build() {
    return RecoveryProtocolState(
      protocolStartDate: DateTime.now(),
    );
  }

  void selectDay(int dayIndex) {
    if (dayIndex < 1 || dayIndex > RecoveryProtocolConstants.dayCount) {
      return;
    }
    state = state.copyWith(selectedDayIndex: dayIndex);
  }

  void toggleTask(RecoveryDailyTask task, bool completed) {
    final dayIndex = state.selectedDayIndex;
    final record = state.dayRecord(dayIndex).toggleTask(task, completed);
    final nextDays = Map<int, RecoveryDayRecord>.from(state.days)
      ..[dayIndex] = record;
    state = state.copyWith(days: nextDays);
  }

  /// Applies penalty for missed habits on the selected day (requires confirmation in UI).
  void applyPenaltyForSelectedDay() {
    final dayIndex = state.selectedDayIndex;
    final record = state.dayRecord(dayIndex).copyWith(penaltyApplied: true);
    final nextDays = Map<int, RecoveryDayRecord>.from(state.days)
      ..[dayIndex] = record;
    state = state.copyWith(
      days: nextDays,
      totalPenaltyCount: state.totalPenaltyCount + 1,
    );
  }

  bool selectedDayNeedsPenalty() {
    final record = state.dayRecord(state.selectedDayIndex);
    return record.hasMissedHabit && !record.penaltyApplied;
  }
}

@riverpod
RecoveryProtocolState recoveryProtocolData(RecoveryProtocolDataRef ref) {
  return ref.watch(recoveryProtocolControllerProvider);
}
