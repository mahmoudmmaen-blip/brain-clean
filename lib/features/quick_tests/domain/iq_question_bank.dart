import 'iq_question.dart';

/// Five pattern / matrix-reasoning MCQs (stems + options via arb keys).
abstract final class IqQuestionBank {
  static const questionCount = 5;

  static const questions = <IqQuestion>[
    IqQuestion(
      id: 'iq_q1',
      stemKey: 'iqQ1Stem',
      optionKeys: ['iqQ1OptA', 'iqQ1OptB', 'iqQ1OptC', 'iqQ1OptD'],
      correctIndex: 2,
      order: 0,
    ),
    IqQuestion(
      id: 'iq_q2',
      stemKey: 'iqQ2Stem',
      optionKeys: ['iqQ2OptA', 'iqQ2OptB', 'iqQ2OptC', 'iqQ2OptD'],
      correctIndex: 1,
      order: 1,
    ),
    IqQuestion(
      id: 'iq_q3',
      stemKey: 'iqQ3Stem',
      optionKeys: ['iqQ3OptA', 'iqQ3OptB', 'iqQ3OptC', 'iqQ3OptD'],
      correctIndex: 3,
      order: 2,
    ),
    IqQuestion(
      id: 'iq_q4',
      stemKey: 'iqQ4Stem',
      optionKeys: ['iqQ4OptA', 'iqQ4OptB', 'iqQ4OptC', 'iqQ4OptD'],
      correctIndex: 0,
      order: 3,
    ),
    IqQuestion(
      id: 'iq_q5',
      stemKey: 'iqQ5Stem',
      optionKeys: ['iqQ5OptA', 'iqQ5OptB', 'iqQ5OptC', 'iqQ5OptD'],
      correctIndex: 2,
      order: 4,
    ),
  ];
}
