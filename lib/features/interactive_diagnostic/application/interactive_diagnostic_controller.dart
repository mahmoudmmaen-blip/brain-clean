import 'package:flutter/foundation.dart';

import '../domain/diag_question.dart';
import '../domain/diag_question_bank.dart';
import '../domain/diag_scoring.dart';

enum InteractiveDiagnosticPhase {
  intro,
  questions,
  result,
}

/// State machine for the 5-question interactive diagnostic flow.
class InteractiveDiagnosticController extends ChangeNotifier {
  InteractiveDiagnosticPhase phase = InteractiveDiagnosticPhase.intro;
  int questionIndex = 0;
  final List<int?> answers =
      List<int?>.filled(DiagQuestionBank.questionCount, null);
  DiagScoreResult? result;
  var _planUpdated = false;

  bool get planUpdated => _planUpdated;

  DiagQuestion? get currentQuestion {
    if (questionIndex < 0 ||
        questionIndex >= DiagQuestionBank.questions.length) {
      return null;
    }
    return DiagQuestionBank.questions[questionIndex];
  }

  int? get selectedAnswer =>
      questionIndex >= 0 && questionIndex < answers.length
          ? answers[questionIndex]
          : null;

  bool get canAdvance => selectedAnswer != null;

  bool get isLastQuestion =>
      questionIndex >= DiagQuestionBank.questions.length - 1;

  void startQuestions() {
    phase = InteractiveDiagnosticPhase.questions;
    questionIndex = 0;
    notifyListeners();
  }

  void selectAnswer(int value) {
    if (value < 1 || value > 5) return;
    answers[questionIndex] = value;
    notifyListeners();
  }

  void goBack() {
    if (phase == InteractiveDiagnosticPhase.questions && questionIndex > 0) {
      questionIndex -= 1;
      notifyListeners();
      return;
    }
    if (phase == InteractiveDiagnosticPhase.questions && questionIndex == 0) {
      phase = InteractiveDiagnosticPhase.intro;
      notifyListeners();
    }
  }

  void advance() {
    if (!canAdvance) return;
    if (isLastQuestion) {
      _complete();
      return;
    }
    questionIndex += 1;
    notifyListeners();
  }

  void _complete() {
    final resolved = answers.map((a) => a!).toList(growable: false);
    result = scoreFromAnswers(resolved);
    phase = InteractiveDiagnosticPhase.result;
    notifyListeners();
  }

  void markPlanUpdated() {
    _planUpdated = true;
    notifyListeners();
  }

  void reset() {
    phase = InteractiveDiagnosticPhase.intro;
    questionIndex = 0;
    for (var i = 0; i < answers.length; i++) {
      answers[i] = null;
    }
    result = null;
    _planUpdated = false;
    notifyListeners();
  }
}
