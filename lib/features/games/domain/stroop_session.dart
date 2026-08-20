import 'dart:math';

/// Stroop round generator and scoring (10 rounds).
class StroopSession {
  StroopSession({
    this.totalRounds = 10,
    Random? random,
  }) : _random = random ?? Random();

  final int totalRounds;
  final Random _random;

  int round = 0;
  int correct = 0;
  int incorrect = 0;
  int? wordIndex;
  int? inkIndex;
  bool finished = false;

  void startRound() {
    wordIndex = _random.nextInt(4);
    inkIndex = _random.nextInt(4);
    while (inkIndex == wordIndex) {
      inkIndex = _random.nextInt(4);
    }
  }

  /// Returns true when the tapped ink index is correct.
  bool answer(int tappedInkIndex) {
    if (finished || inkIndex == null) return false;
    final ok = tappedInkIndex == inkIndex;
    if (ok) {
      correct++;
    } else {
      incorrect++;
    }
    if (round >= totalRounds - 1) {
      finished = true;
      return ok;
    }
    round++;
    startRound();
    return ok;
  }

  int get scorePercent => totalRounds == 0
      ? 0
      : ((correct / totalRounds) * 100).round();
}
