/// Pure N-back trial evaluation (adaptive N).
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
    int nLevel = 1,
    this.stimuliPerRound = 24,
    this.correctToLevelUp = 8,
    this.maxNLevel = 5,
  }) : _nLevel = nLevel.clamp(1, maxNLevel);

  int _nLevel;
  final int stimuliPerRound;
  final int correctToLevelUp;
  final int maxNLevel;

  final List<int> history = [];
  int stimulusIndex = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  int correctStreak = 0;
  int? activeCell;
  bool awaitingResponse = false;
  bool finished = false;

  int get nLevel => _nLevel;

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
    final ok = NBackLogic.matchResponseIsCorrect(history, nLevel: _nLevel);
    _record(ok);
    return ok;
  }

  bool respondNext() {
    if (!canRespond) return false;
    final ok = NBackLogic.nextResponseIsCorrect(history, nLevel: _nLevel);
    _record(ok);
    return ok;
  }

  void _record(bool ok) {
    if (ok) {
      correctCount++;
      correctStreak++;
      if (correctStreak >= correctToLevelUp && _nLevel < maxNLevel) {
        _nLevel++;
        correctStreak = 0;
      }
    } else {
      incorrectCount++;
      correctStreak = 0;
    }
    awaitingResponse = false;
    activeCell = null;
    if (stimulusIndex >= stimuliPerRound) {
      finished = true;
    }
  }

  void forceFinish() {
    finished = true;
    awaitingResponse = false;
    activeCell = null;
  }
}
