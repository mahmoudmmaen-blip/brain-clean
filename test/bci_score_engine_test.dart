import 'package:brain_clean_mobile/features/bci/domain/bci_adherence_calculator.dart';
import 'package:brain_clean_mobile/features/bci/domain/bci_score_engine.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_day_record.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BciAdherenceCalculator', () {
    RecoveryProtocolState protocolWithDays({
      required int dayCount,
      required RecoveryDayRecord Function(int dayIndex) buildDay,
    }) {
      final days = <int, RecoveryDayRecord>{};
      for (var dayIndex = 1; dayIndex <= dayCount; dayIndex++) {
        days[dayIndex] = buildDay(dayIndex);
      }
      return RecoveryProtocolState(
        protocolStartDate: DateTime.now().subtract(Duration(days: dayCount - 1)),
        days: days,
      );
    }

    RecoveryDayRecord fullDay(int dayIndex) => RecoveryDayRecord(
          dayIndex: dayIndex,
          taskCompleted: List<bool>.filled(5, true),
          sleepCompleted: true,
          waterCompleted: true,
        );

    test('lastSevenDayRecords returns at most 7 records', () {
      final state = protocolWithDays(dayCount: 10, buildDay: fullDay);
      final records = BciAdherenceCalculator.lastSevenDayRecords(state);
      expect(records.length, 7);
      expect(records.first.dayIndex, 4);
      expect(records.last.dayIndex, 10);
    });

    test('averageDailyBcsScore returns 100 for fully completed days', () {
      final records = List.generate(7, (i) => fullDay(i + 1));
      expect(BciAdherenceCalculator.averageDailyBcsScore(records), 100);
    });
  });

  group('BciScoreEngine', () {
    DiagnosticSession committedSession({int brainRotScore = 2}) {
      return DiagnosticSession.fromAssessment(
        model: const DiagnosticModel(
          brainPerformance: 80,
          digitalDiscipline: 80,
          healthyHabits: 80,
          consistency: 80,
        ),
        metrics: const DiagnosticMetrics(),
        brainRot: BrainRotTest.evaluate(
          List<bool>.filled(brainRotScore, true) +
              List<bool>.filled(
                BrainRotTest.questionCount - brainRotScore,
                false,
              ),
        ),
        brainRotAnswers: List<bool>.filled(brainRotScore, true) +
            List<bool>.filled(
              BrainRotTest.questionCount - brainRotScore,
              false,
            ),
      );
    }

    test('total score blends 60% assessment and 40% adherence', () {
      final session = committedSession();
      final adherence = BciAdherenceCalculator.fromProtocolState(
        RecoveryProtocolState(
          protocolStartDate: DateTime.now().subtract(const Duration(days: 6)),
          days: {
            for (var i = 1; i <= 7; i++)
              i: RecoveryDayRecord(
                dayIndex: i,
                taskCompleted: List<bool>.filled(5, true),
                sleepCompleted: true,
                waterCompleted: true,
              ),
          },
        ),
      );

      final result = BciScoreEngine.calculate(
        session: session,
        adherence: adherence,
      );

      expect(result.hasCommittedAssessment, isTrue);
      expect(result.adherenceScore, 100);
      expect(result.adherenceDaysSampled, 7);
      expect(
        result.totalScore,
        closeTo(
          result.assessmentScore * 0.60 + result.adherenceScore * 0.40,
          0.01,
        ),
      );
    });

    test('returns adherence-only score when diagnostic is missing', () {
      final adherence = BciAdherenceCalculator.fromProtocolState(
        RecoveryProtocolState(
          protocolStartDate: DateTime.now(),
          days: {
            1: RecoveryDayRecord(
              dayIndex: 1,
              taskCompleted: const [true, true, true, false, false],
            ),
          },
        ),
      );

      final result = BciScoreEngine.calculate(adherence: adherence);

      expect(result.hasCommittedAssessment, isFalse);
      expect(result.assessmentScore, 0);
      expect(result.adherenceScore, 36);
      expect(result.totalScore, closeTo(14.4, 0.01));
    });
  });
}
