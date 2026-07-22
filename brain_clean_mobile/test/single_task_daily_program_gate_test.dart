import 'package:brain_clean_mobile/features/focus/application/single_task_daily_program_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SingleTaskDailyProgramGate', () {
    test('arm/consume/disarm behave like mood, sukoon, and journal gates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate = container.read(singleTaskDailyProgramGateProvider.notifier);
      expect(container.read(singleTaskDailyProgramGateProvider), isFalse);

      gate.arm();
      expect(container.read(singleTaskDailyProgramGateProvider), isTrue);
      expect(gate.consume(), isTrue);
      expect(container.read(singleTaskDailyProgramGateProvider), isFalse);
      expect(gate.consume(), isFalse);

      gate.arm();
      gate.disarm();
      expect(container.read(singleTaskDailyProgramGateProvider), isFalse);
    });

    test('completeFocusTaskStepIfArmed is no-op when unarmed', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate = container.read(singleTaskDailyProgramGateProvider.notifier);
      expect(container.read(singleTaskDailyProgramGateProvider), isFalse);
      await gate.completeFocusTaskStepIfArmed();
      expect(container.read(singleTaskDailyProgramGateProvider), isFalse);
    });

    test('completeFocusTaskStepIfArmed consumes armed gate safely', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate = container.read(singleTaskDailyProgramGateProvider.notifier);
      gate.arm();
      expect(container.read(singleTaskDailyProgramGateProvider), isTrue);

      // Without a live Daily Program focusTask step this still consumes safely.
      await gate.completeFocusTaskStepIfArmed();
      expect(container.read(singleTaskDailyProgramGateProvider), isFalse);
    });
  });
}
