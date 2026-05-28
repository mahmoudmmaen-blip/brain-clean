import 'package:json_annotation/json_annotation.dart';

import 'diagnostic_model.dart';

part 'brain_rot_questionnaire_snapshot.g.dart';

/// Serializable in-progress / committed Brain Rot questionnaire state.
@JsonSerializable()
class BrainRotQuestionnaireSnapshot {
  const BrainRotQuestionnaireSnapshot({
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

  @JsonKey(name: 'phase')
  final BrainRotFlowPhase phase;

  int get answeredCount => answers.where((a) => a != null).length;

  bool get isComplete =>
      answers.length == BrainRotTest.questionCount &&
      answers.every((a) => a != null);

  List<bool> get resolvedAnswers => answers.map((a) => a ?? false).toList();

  BrainRotInterpretation? get interpretation => isComplete
      ? DiagnosticModel.evaluateBrainRot(resolvedAnswers)
      : null;

  BrainRotQuestionnaireSnapshot copyWith({
    List<bool?>? answers,
    int? currentIndex,
    BrainRotFlowPhase? phase,
  }) {
    return BrainRotQuestionnaireSnapshot(
      answers: answers ?? List<bool?>.from(this.answers),
      currentIndex: currentIndex ?? this.currentIndex,
      phase: phase ?? this.phase,
    );
  }

  factory BrainRotQuestionnaireSnapshot.fromJson(Map<String, dynamic> json) =>
      _$BrainRotQuestionnaireSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$BrainRotQuestionnaireSnapshotToJson(this);
}

@JsonEnum(alwaysCreate: true)
enum BrainRotFlowPhase {
  questions,
  results,
  bhiSliders,
}
