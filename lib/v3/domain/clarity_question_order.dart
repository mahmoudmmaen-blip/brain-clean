import 'dart:math';

import '../application/clarity_check_session_provider.dart';
import '../content/clarity_check_content.dart';

/// Orders Clarity Check items for display.
///
/// Baseline keeps file order. Re-checks (days 7/14/21/30) shuffle with a seed
/// derived from the check date so the same day is stable but differs from baseline.
abstract final class ClarityQuestionOrder {
  ClarityQuestionOrder._();

  static List<ClarityQuestion> ordered({
    required List<ClarityQuestion> questions,
    required ClarityCheckMode mode,
    required DateTime checkDate,
  }) {
    if (mode == ClarityCheckMode.baseline || questions.length <= 1) {
      return List<ClarityQuestion>.unmodifiable(questions);
    }
    final seed =
        checkDate.year * 10000 + checkDate.month * 100 + checkDate.day;
    final copy = List<ClarityQuestion>.of(questions);
    copy.shuffle(Random(seed));
    return List<ClarityQuestion>.unmodifiable(copy);
  }
}
