import 'bri_axis.dart';
import 'bri_question_bank.dart';
import 'bri_result.dart';

/// Scores BRI Likert answers (1–5) into axis + overall rot index.
abstract final class BriScorer {
  /// [likertAnswers] length must equal [BriQuestionBank.questionCount].
  static BriResult score(
    List<int> likertAnswers, {
    DateTime? completedAt,
  }) {
    if (likertAnswers.length != BriQuestionBank.questionCount) {
      throw ArgumentError.value(
        likertAnswers,
        'likertAnswers',
        'BRI requires ${BriQuestionBank.questionCount} answers.',
      );
    }

    final sums = <BriAxis, double>{
      for (final a in BriAxis.values) a: 0,
    };
    final counts = <BriAxis, int>{
      for (final a in BriAxis.values) a: 0,
    };

    for (var i = 0; i < BriQuestionBank.questions.length; i++) {
      final raw = likertAnswers[i];
      if (raw < 1 || raw > 5) {
        throw ArgumentError.value(raw, 'likertAnswers[$i]', 'Must be 1–5');
      }
      final q = BriQuestionBank.questions[i];
      // Rot intensity 0–100 (higher = worse).
      final rot = q.higherMeansWorse ? raw : (6 - raw);
      final rotPercent = ((rot - 1) / 4) * 100;
      sums[q.axis] = sums[q.axis]! + rotPercent;
      counts[q.axis] = counts[q.axis]! + 1;
    }

    final axisScores = <BriAxis, int>{};
    var overallSum = 0.0;
    for (final axis in BriAxis.values) {
      final c = counts[axis]!;
      final score = c == 0 ? 50 : (sums[axis]! / c).round().clamp(0, 100);
      axisScores[axis] = score;
      overallSum += score;
    }

    final overall = (overallSum / BriAxis.values.length).round().clamp(0, 100);

    return BriResult(
      overallScore: overall,
      axisScores: axisScores,
      completedAt: (completedAt ?? DateTime.now()).toUtc(),
    );
  }

  /// Days until free retest is allowed (0 = unlocked).
  static int daysUntilRetest(BriResult? latest, {DateTime? now}) {
    if (latest == null) return 0;
    final today = now ?? DateTime.now();
    final localDone = latest.completedAt.toLocal();
    final doneDay =
        DateTime(localDone.year, localDone.month, localDone.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final elapsed = todayDay.difference(doneDay).inDays;
    final remaining = BriQuestionBank.cooldownDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }
}
