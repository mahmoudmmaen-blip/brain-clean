import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/brain_rot_questionnaire_snapshot.dart';
import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';

part 'diagnostic_session_flow_provider.g.dart';

/// Unified questionnaire + phase state for [DiagnosticScreen].
@riverpod
class DiagnosticSessionFlow extends _$DiagnosticSessionFlow {
  /// +1 forward (answer), −1 backward (review).
  int questionSlideDirection = 1;

  @override
  BrainRotQuestionnaireSnapshot build() =>
      const BrainRotQuestionnaireSnapshot();

  void answerQuestion(int index, bool yes) {
    if (index < 0 || index >= BrainRotTest.questionCount) return;
    questionSlideDirection = 1;
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
    questionSlideDirection = index < state.currentIndex ? -1 : 1;
    state = state.copyWith(
      currentIndex: index,
      phase: BrainRotFlowPhase.questions,
    );
  }

  void continueToBhiSliders() {
    if (!state.isComplete) return;
    state = state.copyWith(phase: BrainRotFlowPhase.bhiSliders);
  }

  void reset() => state = const BrainRotQuestionnaireSnapshot();

  BrainRotInterpretation? get result => state.interpretation;

  List<bool> get resolvedAnswers => state.resolvedAnswers;

  bool get isComplete => state.isComplete;

  /// Packages flow + live inputs into a committed [DiagnosticSession].
  DiagnosticSession buildCommittedSession({
    required DiagnosticModel model,
    required DiagnosticMetrics metrics,
  }) {
    final interpretation = result;
    if (interpretation == null) {
      throw StateError('Brain Rot questionnaire is incomplete.');
    }
    return DiagnosticSession.fromAssessment(
      model: model,
      metrics: metrics,
      brainRot: interpretation,
      brainRotAnswers: resolvedAnswers,
      questionnaire: state,
    );
  }
}
