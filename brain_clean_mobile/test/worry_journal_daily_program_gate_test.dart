import 'package:brain_clean_mobile/features/worry/application/worry_journal_daily_program_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorryJournalDailyProgramGate', () {
    test('arm/consume/disarm behave like mood and sukoon gates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate =
          container.read(worryJournalDailyProgramGateProvider.notifier);
      expect(container.read(worryJournalDailyProgramGateProvider), isFalse);

      gate.arm();
      expect(container.read(worryJournalDailyProgramGateProvider), isTrue);
      expect(gate.consume(), isTrue);
      expect(container.read(worryJournalDailyProgramGateProvider), isFalse);
      expect(gate.consume(), isFalse);

      gate.arm();
      gate.disarm();
      expect(container.read(worryJournalDailyProgramGateProvider), isFalse);
    });

    test('completeJournalStepIfArmed is no-op when unarmed', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate =
          container.read(worryJournalDailyProgramGateProvider.notifier);
      expect(container.read(worryJournalDailyProgramGateProvider), isFalse);
      await gate.completeJournalStepIfArmed();
      expect(container.read(worryJournalDailyProgramGateProvider), isFalse);
    });

    test('completeJournalStepIfArmed consumes armed gate safely', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate =
          container.read(worryJournalDailyProgramGateProvider.notifier);
      gate.arm();
      expect(container.read(worryJournalDailyProgramGateProvider), isTrue);

      // Without a live Daily Program journal step this still consumes safely.
      await gate.completeJournalStepIfArmed();
      expect(container.read(worryJournalDailyProgramGateProvider), isFalse);
    });
  });
}
