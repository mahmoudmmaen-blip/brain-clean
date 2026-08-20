import 'diag_metric.dart';
import 'diag_question.dart';

/// Five quick self-report items covering four cognitive pillars.
abstract final class DiagQuestionBank {
  static const questionCount = 5;

  static const questions = <DiagQuestion>[
    DiagQuestion(
      id: 'diag_q1',
      metric: DiagMetric.attention,
      stemKey: 'diagQ1Stem',
      order: 0,
    ),
    DiagQuestion(
      id: 'diag_q2',
      metric: DiagMetric.workingMemory,
      stemKey: 'diagQ2Stem',
      order: 1,
    ),
    DiagQuestion(
      id: 'diag_q3',
      metric: DiagMetric.screenHabits,
      stemKey: 'diagQ3Stem',
      order: 2,
    ),
    DiagQuestion(
      id: 'diag_q4',
      metric: DiagMetric.screenHabits,
      stemKey: 'diagQ4Stem',
      order: 3,
    ),
    DiagQuestion(
      id: 'diag_q5',
      metric: DiagMetric.sleepQuality,
      stemKey: 'diagQ5Stem',
      order: 4,
    ),
  ];
}
