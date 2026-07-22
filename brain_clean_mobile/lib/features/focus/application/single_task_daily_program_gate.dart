import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../daily_program/application/daily_program_provider.dart';
import '../../daily_program/domain/daily_step.dart';
import '../../daily_program/domain/daily_step_status.dart';

part 'single_task_daily_program_gate.g.dart';

/// Armed only when Single Task is opened from Daily Program focusTask step.
@Riverpod(keepAlive: true)
class SingleTaskDailyProgramGate extends _$SingleTaskDailyProgramGate {
  @override
  bool build() => false;

  void arm() => state = true;

  void disarm() => state = false;

  /// Returns whether the gate was armed, then clears it.
  bool consume() {
    final armed = state;
    state = false;
    return armed;
  }

  /// Completes [DailyStep.focusTask] only when armed and focusTask is still
  /// the current Daily Program step. Safe no-op otherwise.
  Future<void> completeFocusTaskStepIfArmed() async {
    try {
      final fromDailyProgram = consume();
      if (!fromDailyProgram) return;

      final program = ref.read(dailyProgramProvider).valueOrNull;
      final current = program?.currentStep;
      if (current == null || current.step != DailyStep.focusTask) return;
      if (current.status != DailyStepStatus.current) return;
      await ref
          .read(dailyProgramProvider.notifier)
          .completeStep(DailyStep.focusTask);
    } catch (_) {
      // Daily Program sync is best-effort.
    }
  }
}
