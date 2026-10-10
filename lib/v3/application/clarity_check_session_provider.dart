import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ClarityCheckMode { baseline, recheck }

class ClarityCheckSessionState {
  const ClarityCheckSessionState({
    this.mode = ClarityCheckMode.baseline,
    this.step = 0,
    this.hoursEstimate,
    this.answers = const {},
    this.previousScore,
  });

  final ClarityCheckMode mode;
  final int step;
  final double? hoursEstimate;
  final Map<String, int> answers;
  final int? previousScore;

  ClarityCheckSessionState copyWith({
    ClarityCheckMode? mode,
    int? step,
    double? hoursEstimate,
    Map<String, int>? answers,
    int? previousScore,
  }) {
    return ClarityCheckSessionState(
      mode: mode ?? this.mode,
      step: step ?? this.step,
      hoursEstimate: hoursEstimate ?? this.hoursEstimate,
      answers: answers ?? this.answers,
      previousScore: previousScore ?? this.previousScore,
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
  }) {
    state = ClarityCheckSessionState(
      mode: mode,
      previousScore: previousScore,
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
