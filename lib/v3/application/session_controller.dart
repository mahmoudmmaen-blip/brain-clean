import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/day_progress.dart';
import '../domain/program_engine.dart';
import 'v3_state_providers.dart';

enum SessionStep { lesson, practice, challenge, completion }

class SessionViewState {
  const SessionViewState({
    required this.day,
    this.step = SessionStep.lesson,
    this.lessonDone = false,
    this.practiceDone = false,
    this.usedEasy = false,
    this.challengeAccepted = false,
    this.showEasy = false,
    this.awaitingClarityRecheck = false,
  });

  final int day;
  final SessionStep step;
  final bool lessonDone;
  final bool practiceDone;
  final bool usedEasy;
  final bool challengeAccepted;
  final bool showEasy;
  final bool awaitingClarityRecheck;

  bool get practiceSatisfied => practiceDone || usedEasy;

  bool get canCompleteDay => lessonDone && practiceSatisfied;

  SessionViewState copyWith({
    SessionStep? step,
    bool? lessonDone,
    bool? practiceDone,
    bool? usedEasy,
    bool? challengeAccepted,
    bool? showEasy,
    bool? awaitingClarityRecheck,
  }) {
    return SessionViewState(
      day: day,
      step: step ?? this.step,
      lessonDone: lessonDone ?? this.lessonDone,
      practiceDone: practiceDone ?? this.practiceDone,
      usedEasy: usedEasy ?? this.usedEasy,
      challengeAccepted: challengeAccepted ?? this.challengeAccepted,
      showEasy: showEasy ?? this.showEasy,
      awaitingClarityRecheck:
          awaitingClarityRecheck ?? this.awaitingClarityRecheck,
    );
  }
}

final sessionControllerProvider =
    NotifierProvider.family<SessionController, SessionViewState, int>(
  SessionController.new,
);

class SessionController extends FamilyNotifier<SessionViewState, int> {
  late int day;

  @override
  SessionViewState build(int arg) {
    day = arg;
    final existing =
        ref.read(v3AppStateProvider).valueOrNull?.progressForDay(day);
    if (existing == null) {
      return SessionViewState(day: day);
    }
    SessionStep step = SessionStep.lesson;
    if (existing.completedAt != null) {
      step = SessionStep.completion;
    } else if (existing.lessonDone &&
        (existing.practiceDone || existing.usedEasy)) {
      step = SessionStep.challenge;
    } else if (existing.lessonDone) {
      step = SessionStep.practice;
    }
    return SessionViewState(
      day: day,
      step: step,
      lessonDone: existing.lessonDone,
      practiceDone: existing.practiceDone,
      usedEasy: existing.usedEasy,
      challengeAccepted: existing.challengeAccepted,
    );
  }

  Future<void> _persist({DateTime? completedAt, bool clearCompleted = false}) async {
    final now = DateTime.now();
    final existing =
        ref.read(v3AppStateProvider).valueOrNull?.progressForDay(day);
    final progress = DayProgress(
      day: day,
      startedAt: existing?.startedAt ?? now,
      lessonDone: state.lessonDone,
      practiceDone: state.practiceDone,
      usedEasy: state.usedEasy,
      challengeAccepted: state.challengeAccepted,
      challengeDone: existing?.challengeDone,
      completedAt: clearCompleted
          ? null
          : (completedAt ?? existing?.completedAt),
    );
    await ref.read(v3StateRepositoryProvider).saveDayProgress(progress);
    ref.invalidate(v3AppStateProvider);
  }

  Future<void> ensureStarted() async {
    final existing =
        ref.read(v3AppStateProvider).valueOrNull?.progressForDay(day);
    if (existing?.startedAt != null) return;
    await _persist();
  }

  Future<void> completeLesson() async {
    state = state.copyWith(lessonDone: true, step: SessionStep.practice);
    await _persist();
  }

  void toggleEasy(bool value) {
    state = state.copyWith(showEasy: value);
  }

  Future<void> markEasyUsed() async {
    state = state.copyWith(
      usedEasy: true,
      step: SessionStep.challenge,
    );
    await _persist();
  }

  Future<void> completePractice() async {
    state = state.copyWith(
      practiceDone: true,
      step: SessionStep.challenge,
    );
    await _persist();
  }

  /// Skip practice step — does not mark practice done or remove credit.
  Future<void> skipPractice() async {
    state = state.copyWith(step: SessionStep.challenge);
    await _persist();
  }

  Future<void> acceptChallenge() async {
    state = state.copyWith(challengeAccepted: true);
    await _persist();
  }

  /// Completes the day when lesson + (practice or easy) are satisfied.
  Future<bool> finishDay({required DateTime now}) async {
    if (!state.canCompleteDay) return false;
    state = state.copyWith(
      challengeAccepted: true,
      step: SessionStep.completion,
      awaitingClarityRecheck: false,
    );
    await _persist(completedAt: now);
    return ProgramEngine.isDayCompleted(
      DayProgress(
        day: day,
        lessonDone: true,
        practiceDone: state.practiceDone,
        usedEasy: state.usedEasy,
        challengeAccepted: true,
        completedAt: now,
      ),
    );
  }

  void setAwaitingClarity(bool value) {
    state = state.copyWith(awaitingClarityRecheck: value);
  }

  void showCompletion() {
    state = state.copyWith(step: SessionStep.completion);
  }
}
