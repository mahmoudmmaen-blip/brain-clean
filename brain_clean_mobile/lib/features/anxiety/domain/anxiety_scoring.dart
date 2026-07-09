import 'anxiety_level.dart';
import 'anxiety_result.dart';

/// Scoring for the 8-item chronic anxiety questionnaire (0–3 per item).
abstract final class AnxietyScoring {
  static const questionCount = 8;
  static const maxAnswerValue = 3;
  static const maxAnswerSum = questionCount * maxAnswerValue;

  static double computeScore(List<int> answers) {
    assert(answers.length == questionCount);
    final sum = answers.fold<int>(0, (total, value) => total + value);
    return (sum / maxAnswerSum) * 100;
  }

  static AnxietyResult buildResult(List<int> answers) {
    final score = computeScore(answers);
    return AnxietyResult(
      answers: List<int>.from(answers),
      score: score,
      level: AnxietyLevelScoring.fromScore(score),
      timestamp: DateTime.now().toUtc(),
    );
  }
}
