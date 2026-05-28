import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/diagnostic_local_repository_provider.dart';
import '../domain/brain_rot_questionnaire_snapshot.dart';
import '../domain/diagnostic_model.dart';
import 'diagnostic_controller.dart';

part 'diagnostic_session_flow_provider.g.dart';

/// Duration matching question exit animation before results dashboard.
const Duration kBrainRotResultsTransitionDelay = Duration(milliseconds: 420);

/// Unified questionnaire + phase state for [DiagnosticScreen].
@Riverpod(keepAlive: true)
class DiagnosticSessionFlow extends _$DiagnosticSessionFlow {
  /// +1 forward (answer), −1 backward (review).
  int questionSlideDirection = 1;

  Timer? _resultsTransitionTimer;
  int _resultsTransitionGeneration = 0;

  @override
  BrainRotQuestionnaireSnapshot build() {
    ref.onDispose(() => _resultsTransitionTimer?.cancel());
    return const BrainRotQuestionnaireSnapshot();
  }

  /// Records نعم/لا, validates via [DiagnosticController.validateLiveSession], and
  /// on the 10th answer schedules a smooth handoff to the results dashboard.
  void answerQuestion(int index, bool yes) {
    if (state.isInteractionLocked) return;
    if (index < 0 || index >= BrainRotTest.questionCount) return;

    _resultsTransitionTimer?.cancel();

    questionSlideDirection = 1;
    final nextAnswers = List<bool?>.from(state.answers);
    nextAnswers[index] = yes;
    final allDone = nextAnswers.every((a) => a != null);
    final nextIndex =
        index < BrainRotTest.questionCount - 1 ? index + 1 : index;

    final nextSnapshot = state.copyWith(
      answers: nextAnswers,
      currentIndex: nextIndex,
      pendingResultsTransition: false,
    );

    if (!allDone) {
      _commitSnapshot(
        nextSnapshot.copyWith(
          phase: BrainRotFlowPhase.questions,
          pendingResultsTransition: false,
        ),
      );
      return;
    }

    // 10th answer: validate full session, hold questions phase, then results.
    final pending = nextSnapshot.copyWith(
      phase: BrainRotFlowPhase.questions,
      pendingResultsTransition: true,
    );
    _commitSnapshot(
      pending,
      requireComplete: true,
      validateAsync: true,
    );

    final generation = ++_resultsTransitionGeneration;
    _resultsTransitionTimer = Timer(kBrainRotResultsTransitionDelay, () {
      if (generation != _resultsTransitionGeneration) return;
      final resultsSnapshot = pending.copyWith(
        phase: BrainRotFlowPhase.results,
        pendingResultsTransition: false,
      );
      _commitSnapshot(resultsSnapshot, requireComplete: true);
    });
  }

  void goToQuestion(int index) {
    if (state.isInteractionLocked) return;
    if (index < 0 || index >= BrainRotTest.questionCount) return;
    _resultsTransitionTimer?.cancel();
    questionSlideDirection = index < state.currentIndex ? -1 : 1;
    _commitSnapshot(
      state.copyWith(
        currentIndex: index,
        phase: BrainRotFlowPhase.questions,
        pendingResultsTransition: false,
      ),
    );
  }

  void continueToBhiSliders() {
    if (!state.isComplete) return;
    _commitSnapshot(
      state.copyWith(phase: BrainRotFlowPhase.bhiSliders),
      requireComplete: true,
    );
  }

  void restoreFromPersistence(BrainRotQuestionnaireSnapshot snapshot) {
    _resultsTransitionTimer?.cancel();
    state = snapshot;
  }

  void reset() {
    _resultsTransitionTimer?.cancel();
    _resultsTransitionGeneration++;
    state = const BrainRotQuestionnaireSnapshot();
    ref.read(diagnosticLocalRepositoryProvider).saveDraft(
          questionnaire: state,
        );
  }

  BrainRotInterpretation? get result => state.interpretation;

  List<bool> get resolvedAnswers => state.resolvedAnswers;

  bool get isComplete => state.isComplete;

  void _commitSnapshot(
    BrainRotQuestionnaireSnapshot snapshot, {
    bool requireComplete = false,
    bool validateAsync = false,
  }) {
    state = snapshot;
    ref.read(diagnosticLocalRepositoryProvider).saveDraft(
          questionnaire: snapshot,
        );
    final controller = ref.read(diagnosticControllerProvider.notifier);
    if (!validateAsync) {
      controller.validateLiveSession(
        questionnaire: snapshot,
        requireComplete: requireComplete,
      );
      return;
    }
    final generation = _resultsTransitionGeneration;
    scheduleMicrotask(() {
      if (generation != _resultsTransitionGeneration) return;
      controller.validateLiveSession(
        questionnaire: state,
        requireComplete: requireComplete,
      );
    });
  }
}
