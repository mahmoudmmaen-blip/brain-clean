import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/clarity_check_content.dart';
import '../domain/clarity_scoring.dart';

/// Injectable façade for [ClarityScoring] (override in tests if needed).
class ClarityScoringRunner {
  const ClarityScoringRunner();

  ClarityScoreOutcome compute({
    required ClarityCheckContent content,
    required Map<String, int> answers,
    required double hoursEstimate,
  }) {
    return ClarityScoring.compute(
      content: content,
      answers: answers,
      hoursEstimate: hoursEstimate,
    );
  }
}

final clarityScoringProvider = Provider<ClarityScoringRunner>((ref) {
  return const ClarityScoringRunner();
});
