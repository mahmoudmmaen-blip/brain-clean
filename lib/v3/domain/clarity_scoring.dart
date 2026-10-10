import '../content/clarity_check_content.dart';
import '../data/clarity_result.dart';

class ClarityScoreOutcome {
  const ClarityScoreOutcome({
    required this.score,
    required this.areas,
    required this.band,
  });

  final int score;
  final ClarityAreaScores areas;
  final ClarityBand band;
}

/// Clarity Check scoring — mirrors [ClarityCheckContent.scoring] formulas.
abstract final class ClarityScoring {
  ClarityScoring._();

  static const int scaleMax = 4;
  static const int totalItemCount = 8;
  static const int maxItemSum = totalItemCount * scaleMax;

  static int itemScore(int value, {required bool reverse}) {
    assert(value >= 0 && value <= scaleMax);
    return reverse ? (scaleMax - value) : value;
  }

  static ClarityScoreOutcome compute({
    required ClarityCheckContent content,
    required Map<String, int> answers,
    required double hoursEstimate,
  }) {
    var sum = 0;
    final byArea = <String, List<int>>{};

    for (final question in content.questions) {
      final raw = answers[question.id];
      if (raw == null) {
        throw ArgumentError('Missing answer for ${question.id}');
      }
      final scored = itemScore(raw, reverse: question.reverse);
      sum += scored;
      byArea.putIfAbsent(question.area, () => []).add(scored);
    }

    final score = ((sum / maxItemSum) * 100).round();

    final areas = ClarityAreaScores(
      focus: _areaScore(byArea['focus'] ?? const []),
      control: _areaScore(byArea['control'] ?? const []),
      sleep: _areaScore(byArea['sleep'] ?? const []),
      calm: _areaScore(byArea['calm'] ?? const []),
    );

    final band = bandForScore(content, score);

    return ClarityScoreOutcome(score: score, areas: areas, band: band);
  }

  static int _areaScore(List<int> itemScores) {
    if (itemScores.isEmpty) return 0;
    final sum = itemScores.fold<int>(0, (a, b) => a + b);
    final max = scaleMax * itemScores.length;
    return ((sum / max) * 100).round();
  }

  static ClarityBand bandForScore(ClarityCheckContent content, int score) {
    for (final band in content.scoring.bands) {
      if (score >= band.min && score <= band.max) return band;
    }
    return content.scoring.bands.first;
  }

  static ClarityResult toResult({
    required ClarityScoreOutcome outcome,
    required int programDay,
    required DateTime takenAt,
    required double hoursEstimate,
    required Map<String, int> answers,
  }) {
    final mergedAnswers = <String, num>{...answers, 'q_hours': hoursEstimate};
    return ClarityResult(
      takenAt: takenAt,
      programDay: programDay,
      score: outcome.score,
      areas: outcome.areas,
      hoursEstimate: hoursEstimate,
      answers: mergedAnswers,
    );
  }
}
