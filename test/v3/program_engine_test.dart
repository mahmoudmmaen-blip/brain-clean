import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/domain/program_engine.dart';
import 'package:flutter_test/flutter_test.dart';

DayProgress _done(int day, DateTime completedAt) {
  return DayProgress(
    day: day,
    lessonDone: true,
    practiceDone: true,
    usedEasy: false,
    challengeAccepted: true,
    completedAt: completedAt,
  );
}

void main() {
  group('currentDay', () {
    test('caps at 30 when all days complete', () {
      final progress = List.generate(
        30,
        (i) => _done(i + 1, DateTime(2025, 1, i + 1)),
      );
      expect(ProgramEngine.currentDay(progress), 30);
      expect(ProgramEngine.isProgramFinished(progress), isTrue);
    });

    test('is completed days + 1 before finish', () {
      final progress = [_done(1, DateTime(2025, 1, 1))];
      expect(ProgramEngine.currentDay(progress), 2);
    });
  });

  group('isDayUnlocked', () {
    test('next day unlocks at local midnight after completion', () {
      final progress = [_done(1, DateTime(2025, 6, 10, 18, 30))];
      expect(
        ProgramEngine.isDayUnlocked(
          day: 2,
          now: DateTime(2025, 6, 10, 23, 59),
          progress: progress,
        ),
        isFalse,
      );
      expect(
        ProgramEngine.isDayUnlocked(
          day: 2,
          now: DateTime(2025, 6, 11),
          progress: progress,
        ),
        isTrue,
      );
    });

    test('missed calendar days do not reset progress', () {
      final progress = [
        _done(1, DateTime(2025, 1, 1)),
        _done(2, DateTime(2025, 1, 15)),
      ];
      expect(ProgramEngine.currentDay(progress), 3);
      expect(
        ProgramEngine.isDayUnlocked(
          day: 3,
          now: DateTime(2025, 2, 1),
          progress: progress,
        ),
        isTrue,
      );
    });
  });

  group('isDayCompleted', () {
    test('requires lesson and practice or easy', () {
      expect(
        ProgramEngine.isDayCompleted(
          const DayProgress(
            day: 1,
            lessonDone: true,
            practiceDone: false,
            usedEasy: true,
            challengeAccepted: false,
            completedAt: null,
          ),
        ),
        isFalse,
      );
      expect(
        ProgramEngine.isDayCompleted(
          DayProgress(
            day: 1,
            lessonDone: true,
            practiceDone: false,
            usedEasy: true,
            challengeAccepted: false,
            completedAt: DateTime(2025, 1, 1),
          ),
        ),
        isTrue,
      );
    });
  });

  group('streak', () {
    test('counts consecutive completion days', () {
      final progress = [
        _done(1, DateTime(2025, 3, 10)),
        _done(2, DateTime(2025, 3, 11)),
        _done(3, DateTime(2025, 3, 12)),
      ];
      expect(
        ProgramEngine.currentStreak(
          progress: progress,
          now: DateTime(2025, 3, 12, 20),
        ),
        3,
      );
    });

    test('one rest day per 7 days preserves streak', () {
      final progress = [
        _done(1, DateTime(2025, 3, 10)),
        _done(2, DateTime(2025, 3, 12)),
      ];
      expect(
        ProgramEngine.currentStreak(
          progress: progress,
          now: DateTime(2025, 3, 12, 21),
        ),
        2,
      );
    });

    test('two missed days in a row break streak', () {
      final progress = [
        _done(1, DateTime(2025, 3, 10)),
        _done(2, DateTime(2025, 3, 13)),
      ];
      expect(
        ProgramEngine.currentStreak(
          progress: progress,
          now: DateTime(2025, 3, 13, 21),
        ),
        1,
      );
    });
  });

  group('Pro and SOS gating', () {
    test('day 7 free, day 8 locked without Pro', () {
      expect(ProgramEngine.isProLocked(day: 7, isPro: false), isFalse);
      expect(ProgramEngine.isProLocked(day: 8, isPro: false), isTrue);
      expect(ProgramEngine.isProLocked(day: 8, isPro: true), isFalse);
    });

    test('SOS is never locked', () {
      expect(ProgramEngine.isSosLocked(isPro: false), isFalse);
      expect(ProgramEngine.isSosLocked(isPro: true), isFalse);
    });
  });

  group('nextClarityCheckDay', () {
    test('returns first schedule day without a result', () {
      expect(
        ProgramEngine.nextClarityCheckDay(
          schedule: const [1, 7, 14, 21, 30],
          clarityTakenOnProgramDays: const {},
        ),
        1,
      );
      expect(
        ProgramEngine.nextClarityCheckDay(
          schedule: const [1, 7, 14, 21, 30],
          clarityTakenOnProgramDays: const {1},
        ),
        7,
      );
    });
  });
}
