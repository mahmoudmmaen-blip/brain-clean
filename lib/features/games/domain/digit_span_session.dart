import 'dart:math';

enum DigitSpanPhase {
  intro,
  showing,
  input,
  feedback,
  finished,
}

/// Digit-span memory: sequential reveal then keypad recall.
class DigitSpanSession {
  DigitSpanSession({
    this.startLength = 3,
    this.maxMistakes = 2,
    Random? random,
  })  : _random = random ?? Random(),
        length = startLength;

  final int startLength;
  final int maxMistakes;
  final Random _random;

  int length;
  int maxDigitsReached = 3;
  int mistakes = 0;
  String sequence = '';
  String input = '';
  int digitRevealIndex = -1;
  DigitSpanPhase phase = DigitSpanPhase.intro;
  bool? lastAttemptCorrect;

  void begin() {
    maxDigitsReached = length;
    _generateSequence();
    digitRevealIndex = -1;
    input = '';
    phase = DigitSpanPhase.showing;
  }

  void _generateSequence() {
    sequence = List.generate(
      length,
      (_) => _random.nextInt(10).toString(),
    ).join();
  }

  int get digitCount => sequence.length;

  String? get currentRevealedDigit {
    if (phase != DigitSpanPhase.showing) return null;
    if (digitRevealIndex < 0 || digitRevealIndex >= sequence.length) {
      return null;
    }
    return sequence[digitRevealIndex];
  }

  /// Advance reveal; returns true when all digits were shown.
  bool advanceReveal() {
    if (phase != DigitSpanPhase.showing) return false;
    digitRevealIndex++;
    if (digitRevealIndex >= sequence.length) {
      phase = DigitSpanPhase.input;
      input = '';
      return true;
    }
    return false;
  }

  void appendDigit(String digit) {
    if (phase != DigitSpanPhase.input || input.length >= sequence.length) {
      return;
    }
    input += digit;
  }

  void backspace() {
    if (phase != DigitSpanPhase.input || input.isEmpty) return;
    input = input.substring(0, input.length - 1);
  }

  void clearInput() {
    if (phase != DigitSpanPhase.input) return;
    input = '';
  }

  /// Submit current input; returns true if sequence matched.
  bool submit() {
    if (phase != DigitSpanPhase.input) return false;
    final ok = input == sequence;
    lastAttemptCorrect = ok;
    if (ok) {
      maxDigitsReached = length;
      length++;
      phase = DigitSpanPhase.feedback;
      return true;
    }
    mistakes++;
    phase = DigitSpanPhase.feedback;
    if (mistakes >= maxMistakes) {
      phase = DigitSpanPhase.finished;
    }
    return false;
  }

  void continueAfterFeedback() {
    if (phase == DigitSpanPhase.finished) return;
    if (lastAttemptCorrect == true) {
      _generateSequence();
      digitRevealIndex = -1;
      input = '';
      phase = DigitSpanPhase.showing;
    } else if (mistakes < maxMistakes) {
      _generateSequence();
      digitRevealIndex = -1;
      input = '';
      phase = DigitSpanPhase.showing;
    } else {
      phase = DigitSpanPhase.finished;
    }
  }
}
