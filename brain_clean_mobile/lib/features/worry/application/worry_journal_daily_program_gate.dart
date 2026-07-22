import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../daily_program/application/daily_program_provider.dart';
import '../../daily_program/domain/daily_step.dart';
import '../../daily_program/domain/daily_step_status.dart';

part 'worry_journal_daily_program_gate.g.dart';

/// Armed only when Worry Journal is opened from Daily Program journal step.
@Riverpod(keepAlive: true)
class WorryJournalDailyProgramGate extends _$WorryJournalDailyProgramGate {
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

  /// Completes [DailyStep.journal] only when armed and journal is still
  /// the current Daily Program step. Safe no-op otherwise.
  Future<void> completeJournalStepIfArmed() async {
    try {
      final fromDailyProgram = consume();
      if (!fromDailyProgram) return;

      final program = ref.read(dailyProgramProvider).valueOrNull;
      final current = program?.currentStep;
      if (current == null || current.step != DailyStep.journal) return;
      if (current.status != DailyStepStatus.current) return;
      await ref
          .read(dailyProgramProvider.notifier)
          .completeStep(DailyStep.journal);
    } catch (_) {
      // Daily Program sync is best-effort.
    }
  }
}
