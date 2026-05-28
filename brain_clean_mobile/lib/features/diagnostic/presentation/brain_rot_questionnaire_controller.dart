import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/diagnostic_model.dart';

part 'brain_rot_questionnaire_controller.g.dart';

/// In-progress Brain Rot yes/no answers (Dr. Moneam 10-item protocol).
@riverpod
class BrainRotQuestionnaire extends _$BrainRotQuestionnaire {
  @override
  BrainRotQuestionnaireState build() => const BrainRotQuestionnaireState();

  void answerQuestion(int index, bool yes) {
    if (index < 0 || index >= BrainRotTest.questionCount) return;
    final next = List<bool?>.from(state.answers);
    next[index] = yes;
    final allDone = next.every((a) => a != null);
    final nextIndex =
        index < BrainRotTest.questionCount - 1 ? index + 1 : index;
    state = state.copyWith(
      answers: next,
      currentIndex: nextIndex,
      phase: allDone ? BrainRotFlowPhase.results : state.phase,
    );
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= BrainRotTest.questionCount) return;
    state = state.copyWith(currentIndex: index, phase: BrainRotFlowPhase.questions);
  }

  void showResults() {
    if (!isComplete) return;
    state = state.copyWith(phase: BrainRotFlowPhase.results);
  }

  void continueToBhiSliders() {
    if (!isComplete) return;
    state = state.copyWith(phase: BrainRotFlowPhase.bhiSliders);
  }

  void reset() => state = const BrainRotQuestionnaireState();

  bool get isComplete =>
      state.answers.every((a) => a != null) &&
      state.answers.length == BrainRotTest.questionCount;

  List<bool> get resolvedAnswers =>
      state.answers.map((a) => a ?? false).toList();

  BrainRotInterpretation? get result =>
      isComplete ? DiagnosticModel.evaluateBrainRot(resolvedAnswers) : null;
}

class BrainRotQuestionnaireState {
  const BrainRotQuestionnaireState({
    this.answers = const [
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    ],
    this.currentIndex = 0,
    this.phase = BrainRotFlowPhase.questions,
  });

  final List<bool?> answers;
  final int currentIndex;
  final BrainRotFlowPhase phase;

  int get answeredCount => answers.where((a) => a != null).length;

  BrainRotQuestionnaireState copyWith({
    List<bool?>? answers,
    int? currentIndex,
    BrainRotFlowPhase? phase,
  }) {
    return BrainRotQuestionnaireState(
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      phase: phase ?? this.phase,
    );
  }
}

enum BrainRotFlowPhase {
  questions,
  results,
  bhiSliders,
}
