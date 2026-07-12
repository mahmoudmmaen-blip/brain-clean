import 'package:freezed_annotation/freezed_annotation.dart';

import 'daily_step.dart';
import 'daily_step_status.dart';

part 'daily_program_state.freezed.dart';
part 'daily_program_state.g.dart';

@freezed
class DailyStepEntry with _$DailyStepEntry {
  const factory DailyStepEntry({
    required DailyStep step,
    required DailyStepStatus status,
    DateTime? completedAt,
  }) = _DailyStepEntry;

  factory DailyStepEntry.fromJson(Map<String, dynamic> json) =>
      _$DailyStepEntryFromJson(json);
}

@freezed
class DailyProgramState with _$DailyProgramState {
  const DailyProgramState._();

  const factory DailyProgramState({
    required DateTime date,
    required int dayNumber,
    required List<DailyStepEntry> steps,
  }) = _DailyProgramState;

  factory DailyProgramState.fromJson(Map<String, dynamic> json) =>
      _$DailyProgramStateFromJson(json);

  int get doneCount => steps
      .where(
        (s) =>
            s.status == DailyStepStatus.done ||
            s.status == DailyStepStatus.skipped,
      )
      .length;

  int get remainingCount => steps.length - doneCount;

  bool get isAllDone => remainingCount == 0;

  bool get isNotStarted =>
      steps.every((s) => s.status != DailyStepStatus.done) &&
      steps.any((s) => s.status == DailyStepStatus.current) &&
      steps.first.status == DailyStepStatus.current &&
      doneCount == 0;

  DailyStepEntry? get currentStep {
    for (final entry in steps) {
      if (entry.status == DailyStepStatus.current) return entry;
    }
    return null;
  }

  double get progressRatio =>
      steps.isEmpty ? 0 : doneCount / steps.length;
}
