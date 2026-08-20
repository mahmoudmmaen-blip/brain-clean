import 'diag_metric.dart';
import 'diag_question_bank.dart';

class DiagMetricScore {
  const DiagMetricScore({
    required this.metric,
    required this.percent,
  });

  final DiagMetric metric;
  final int percent;
}

class DiagScoreResult {
  const DiagScoreResult({
    required this.overallPercent,
    required this.metricScores,
    required this.weakestMetric,
  });

  final int overallPercent;
  final List<DiagMetricScore> metricScores;
  final DiagMetric weakestMetric;

  DiagMetricScore scoreFor(DiagMetric metric) {
    return metricScores.firstWhere((s) => s.metric == metric);
  }
}

/// Converts five Likert answers (1–5, higher = healthier) into overall +
/// per-metric percentages and the weakest pillar.
DiagScoreResult scoreFromAnswers(List<int> answers) {
  if (answers.length != DiagQuestionBank.questionCount) {
    throw ArgumentError.value(
      answers,
      'answers',
      'Interactive diagnostic requires exactly '
      '${DiagQuestionBank.questionCount} answers.',
    );
  }
  for (var i = 0; i < answers.length; i++) {
    final value = answers[i];
    if (value < 1 || value > 5) {
      throw ArgumentError.value(
        answers,
        'answers',
        'Answer ${i + 1} must be between 1 and 5.',
      );
    }
  }

  final buckets = <DiagMetric, List<int>>{
    for (final m in DiagMetric.values) m: <int>[],
  };

  for (var i = 0; i < DiagQuestionBank.questions.length; i++) {
    final question = DiagQuestionBank.questions[i];
    buckets[question.metric]!.add(_normalizeLikert(answers[i]));
  }

  final metricScores = <DiagMetricScore>[];
  for (final metric in DiagMetric.values) {
    final values = buckets[metric]!;
    if (values.isEmpty) continue;
    final mean = values.reduce((a, b) => a + b) / values.length;
    metricScores.add(
      DiagMetricScore(metric: metric, percent: mean.round()),
    );
  }

  metricScores.sort((a, b) => a.metric.index.compareTo(b.metric.index));

  final overall = metricScores.isEmpty
      ? 0
      : (metricScores.map((s) => s.percent).reduce((a, b) => a + b) /
              metricScores.length)
          .round();

  final weakest = metricScores.reduce(
    (a, b) => a.percent <= b.percent ? a : b,
  );

  return DiagScoreResult(
    overallPercent: overall,
    metricScores: List<DiagMetricScore>.unmodifiable(metricScores),
    weakestMetric: weakest.metric,
  );
}

int _normalizeLikert(int value) {
  return (((value - 1) / 4) * 100).round();
}
