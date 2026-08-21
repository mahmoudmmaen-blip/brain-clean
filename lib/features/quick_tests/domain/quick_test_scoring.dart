import 'digital_brain_rot_question_bank.dart';
import 'iq_question_bank.dart';
import 'quick_test_ids.dart';
import 'quick_test_result.dart';

/// Scores Phase 5 IQ and digital brain-rot banks into [QuickTestResult].
abstract final class QuickTestScorer {
  /// [selectedIndexes] length must match [IqQuestionBank.questionCount].
  static QuickTestResult scoreIq(
    List<int> selectedIndexes, {
    DateTime? completedAt,
  }) {
    if (selectedIndexes.length != IqQuestionBank.questionCount) {
      throw ArgumentError.value(
        selectedIndexes,
        'selectedIndexes',
        'IQ test requires ${IqQuestionBank.questionCount} answers.',
      );
    }
    var correct = 0;
    for (var i = 0; i < IqQuestionBank.questions.length; i++) {
      if (selectedIndexes[i] == IqQuestionBank.questions[i].correctIndex) {
        correct++;
      }
    }
    final percent =
        ((correct / IqQuestionBank.questionCount) * 100).round().clamp(0, 100);
    return QuickTestResult(
      testId: QuickTestIds.iq,
      scorePercent: percent,
      completedAt: (completedAt ?? DateTime.now()).toUtc(),
      correctCount: correct,
      totalCount: IqQuestionBank.questionCount,
    );
  }

  /// Likert answers 1–5; length must match [DigitalBrainRotQuestionBank.questionCount].
  /// Returns a wellness score (higher = healthier digital habits).
  static QuickTestResult scoreDigitalBrainRot(
    List<int> likertAnswers, {
    DateTime? completedAt,
  }) {
    if (likertAnswers.length != DigitalBrainRotQuestionBank.questionCount) {
      throw ArgumentError.value(
        likertAnswers,
        'likertAnswers',
        'Digital brain rot requires '
        '${DigitalBrainRotQuestionBank.questionCount} answers.',
      );
    }
    var sum = 0.0;
    for (var i = 0; i < DigitalBrainRotQuestionBank.questions.length; i++) {
      final raw = likertAnswers[i];
      if (raw < 1 || raw > 5) {
        throw ArgumentError.value(raw, 'likertAnswers[$i]', 'Must be 1–5');
      }
      final q = DigitalBrainRotQuestionBank.questions[i];
      final wellness = q.higherMeansWorse ? (6 - raw) : raw;
      sum += ((wellness - 1) / 4) * 100;
    }
    final percent =
        (sum / DigitalBrainRotQuestionBank.questionCount).round().clamp(0, 100);
    return QuickTestResult(
      testId: QuickTestIds.digitalBrainRot,
      scorePercent: percent,
      completedAt: (completedAt ?? DateTime.now()).toUtc(),
      totalCount: DigitalBrainRotQuestionBank.questionCount,
    );
  }
}
