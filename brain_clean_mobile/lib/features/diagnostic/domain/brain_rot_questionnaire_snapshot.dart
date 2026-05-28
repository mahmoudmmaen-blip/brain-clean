import 'package:json_annotation/json_annotation.dart';

import 'bhi_pillar_json_keys.dart';
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
    this.pendingResultsTransition = false,
  });

  @JsonKey(name: BhiPillarJsonKeys.answers)
  final List<bool?> answers;

  @JsonKey(name: BhiPillarJsonKeys.currentIndex)
  final int currentIndex;

  @JsonKey(name: BhiPillarJsonKeys.phase)
  final BrainRotFlowPhase phase;

  /// UI-only: last question answered; results phase animates in next frame.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool pendingResultsTransition;

  bool get isInteractionLocked => pendingResultsTransition;

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
    bool? pendingResultsTransition,
  }) {
    return BrainRotQuestionnaireSnapshot(
      answers: answers ?? List<bool?>.from(this.answers),
      currentIndex: currentIndex ?? this.currentIndex,
      phase: phase ?? this.phase,
      pendingResultsTransition:
          pendingResultsTransition ?? this.pendingResultsTransition,
    );
  }

  factory BrainRotQuestionnaireSnapshot.fromJson(Map<String, dynamic> json) =>
      _$BrainRotQuestionnaireSnapshotFromJson(
        BhiPillarJsonKeys.normalizeIncoming(json),
      );

  Map<String, dynamic> toJson() => _$BrainRotQuestionnaireSnapshotToJson(this);
}

@JsonEnum(alwaysCreate: true)
enum BrainRotFlowPhase {
  questions,
  results,
  bhiSliders,
}
