/// Pure N-back trial evaluation (fixed N, typically 2).
abstract final class NBackLogic {
  /// True when [history] has enough items and the latest cell matches N steps back.
  static bool isMatch(List<int> history, {required int nLevel}) {
    if (history.length <= nLevel) return false;
    return history[history.length - 1 - nLevel] == history.last;
  }

  /// User pressed Match.
  static bool matchResponseIsCorrect(List<int> history, {required int nLevel}) =>
      isMatch(history, nLevel: nLevel);

  /// User pressed Next (no match).
  static bool nextResponseIsCorrect(List<int> history, {required int nLevel}) =>
      !isMatch(history, nLevel: nLevel);
}

/// Mutable in-memory session for one N-back round.
class NBackSession {
  NBackSession({
    this.nLevel = 2,
    this.stimuliPerRound = 20,
  });

  final int nLevel;
  final int stimuliPerRound;

  final List<int> history = [];
  int stimulusIndex = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  int? activeCell;
  bool awaitingResponse = false;
  bool finished = false;

  bool get canRespond => awaitingResponse && activeCell != null && !finished;

  void presentStimulus(int cell) {
    if (finished) return;
    activeCell = cell;
    history.add(cell);
    awaitingResponse = true;
    stimulusIndex++;
  }

  /// Returns true if the user's Match/Next choice was correct.
  bool respondMatch() {
    if (!canRespond) return false;
    final ok = NBackLogic.matchResponseIsCorrect(history, nLevel: nLevel);
    _record(ok);
    return ok;
  }

  bool respondNext() {
    if (!canRespond) return false;
    final ok = NBackLogic.nextResponseIsCorrect(history, nLevel: nLevel);
    _record(ok);
    return ok;
  }

  void _record(bool ok) {
    if (ok) {
      correctCount++;
    } else {
      incorrectCount++;
    }
    awaitingResponse = false;
    activeCell = null;
    if (stimulusIndex >= stimuliPerRound) {
      finished = true;
    }
  }
}
