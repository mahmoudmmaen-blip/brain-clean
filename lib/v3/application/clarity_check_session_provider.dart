import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/clarity_check_content.dart';
import '../domain/clarity_question_order.dart';

enum ClarityCheckMode { baseline, recheck }

class ClarityCheckSessionState {
  const ClarityCheckSessionState({
    this.mode = ClarityCheckMode.baseline,
    this.step = 0,
    this.hoursEstimate,
    this.answers = const {},
    this.previousScore,
    this.orderedQuestions = const [],
  });

  final ClarityCheckMode mode;
  final int step;
  final double? hoursEstimate;
  final Map<String, int> answers;
  final int? previousScore;

  /// Display order for the 8 items (baseline = file order; recheck = shuffled).
  final List<ClarityQuestion> orderedQuestions;

  ClarityCheckSessionState copyWith({
    ClarityCheckMode? mode,
    int? step,
    double? hoursEstimate,
    Map<String, int>? answers,
    int? previousScore,
    List<ClarityQuestion>? orderedQuestions,
  }) {
    return ClarityCheckSessionState(
      mode: mode ?? this.mode,
      step: step ?? this.step,
      hoursEstimate: hoursEstimate ?? this.hoursEstimate,
      answers: answers ?? this.answers,
      previousScore: previousScore ?? this.previousScore,
      orderedQuestions: orderedQuestions ?? this.orderedQuestions,
    );
  }
}

final clarityCheckSessionProvider =
    NotifierProvider<ClarityCheckSession, ClarityCheckSessionState>(
  ClarityCheckSession.new,
);

class ClarityCheckSession extends Notifier<ClarityCheckSessionState> {
  @override
  ClarityCheckSessionState build() => const ClarityCheckSessionState();

  void reset({
    required ClarityCheckMode mode,
    int? previousScore,
    List<ClarityQuestion> questions = const [],
    DateTime? checkDate,
  }) {
    final ordered = questions.isEmpty
        ? const <ClarityQuestion>[]
        : ClarityQuestionOrder.ordered(
            questions: questions,
            mode: mode,
            checkDate: checkDate ?? DateTime.now(),
          );
    state = ClarityCheckSessionState(
      mode: mode,
      previousScore: previousScore,
      orderedQuestions: ordered,
    );
  }

  void setStep(int step) {
    state = state.copyWith(step: step);
  }

  void recordHours(double hours) {
    state = state.copyWith(hoursEstimate: hours, step: state.step + 1);
  }

  void recordAnswer(String questionId, int value) {
    state = state.copyWith(
      answers: {...state.answers, questionId: value},
      step: state.step + 1,
    );
  }
}
