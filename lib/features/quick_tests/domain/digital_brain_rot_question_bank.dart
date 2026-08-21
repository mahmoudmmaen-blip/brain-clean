import 'digital_brain_rot_question.dart';

/// Eight screen-habit / attention Likert items (stems via arb keys).
abstract final class DigitalBrainRotQuestionBank {
  static const questionCount = 8;

  static const questions = <DigitalBrainRotQuestion>[
    DigitalBrainRotQuestion(
      id: 'dbr_q1',
      stemKey: 'digitalBrainRotQ1Stem',
      order: 0,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q2',
      stemKey: 'digitalBrainRotQ2Stem',
      order: 1,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q3',
      stemKey: 'digitalBrainRotQ3Stem',
      order: 2,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q4',
      stemKey: 'digitalBrainRotQ4Stem',
      order: 3,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q5',
      stemKey: 'digitalBrainRotQ5Stem',
      order: 4,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q6',
      stemKey: 'digitalBrainRotQ6Stem',
      order: 5,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q7',
      stemKey: 'digitalBrainRotQ7Stem',
      order: 6,
    ),
    DigitalBrainRotQuestion(
      id: 'dbr_q8',
      stemKey: 'digitalBrainRotQ8Stem',
      order: 7,
      higherMeansWorse: false,
    ),
  ];
}
