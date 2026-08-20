import 'package:brain_clean_mobile/features/games/domain/digit_span_session.dart';
import 'package:brain_clean_mobile/features/games/domain/n_back_session.dart';
import 'package:brain_clean_mobile/features/games/domain/stroop_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NBackSession', () {
    test('2-back Match is correct when positions match', () {
      final session = NBackSession(nLevel: 2, stimuliPerRound: 5);
      session.presentStimulus(1);
      session.respondNext();
      session.presentStimulus(2);
      session.respondNext();
      session.presentStimulus(1);
      expect(session.respondMatch(), isTrue);
      expect(session.correctCount, 3);
    });

    test('Next is correct when there is no 2-back match', () {
      final session = NBackSession(nLevel: 2, stimuliPerRound: 5);
      session.presentStimulus(0);
      session.respondNext();
      session.presentStimulus(1);
      session.respondNext();
      session.presentStimulus(2);
      expect(session.respondNext(), isTrue);
      expect(session.incorrectCount, 0);
    });

    test('Match on non-match counts as incorrect', () {
      final session = NBackSession(nLevel: 2, stimuliPerRound: 3);
      session.presentStimulus(0);
      session.respondNext();
      session.presentStimulus(1);
      session.respondNext();
      session.presentStimulus(2);
      expect(session.respondMatch(), isFalse);
      expect(session.incorrectCount, 1);
    });
  });

  group('StroopSession', () {
    test('scores 10 rounds with correct and incorrect counts', () {
      final session = StroopSession(totalRounds: 10);
      session.startRound();
      for (var i = 0; i < 10; i++) {
        session.answer(session.inkIndex!);
      }
      expect(session.finished, isTrue);
      expect(session.correct, 10);
      expect(session.scorePercent, 100);
    });
  });

  group('DigitSpanSession', () {
    test('reveals digits sequentially then accepts matching input', () {
      final session = DigitSpanSession(startLength: 3);
      session.begin();
      while (session.phase == DigitSpanPhase.showing) {
        session.advanceReveal();
      }
      expect(session.phase, DigitSpanPhase.input);
      for (final ch in session.sequence.split('')) {
        session.appendDigit(ch);
      }
      expect(session.submit(), isTrue);
      expect(session.lastAttemptCorrect, isTrue);
    });
  });
}
