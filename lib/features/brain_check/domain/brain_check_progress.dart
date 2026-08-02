import 'brain_check_answer.dart';
import 'brain_check_mode.dart';
import 'brain_check_phase.dart';

/// In-progress / draft Brain Check session state.
class BrainCheckProgress {
  const BrainCheckProgress({
    required this.mode,
    required this.phase,
    required this.currentQuestionIndex,
    required this.currentSectionIndex,
    required this.answers,
    this.source,
    this.startedAt,
    this.updatedAt,
  });

  final BrainCheckMode mode;
  final BrainCheckPhase phase;
  final int currentQuestionIndex;
  final int currentSectionIndex;
  final Map<String, BrainCheckAnswer> answers;
  final String? source;
  final DateTime? startedAt;
  final DateTime? updatedAt;

  static BrainCheckProgress empty({
    BrainCheckMode mode = BrainCheckMode.lite,
    String? source,
  }) {
    return BrainCheckProgress(
      mode: mode,
      phase: BrainCheckPhase.empty,
      currentQuestionIndex: 0,
      currentSectionIndex: 0,
      answers: const <String, BrainCheckAnswer>{},
      source: source,
    );
  }

  bool get hasDraftProgress =>
      answers.isNotEmpty ||
      phase == BrainCheckPhase.item ||
      phase == BrainCheckPhase.sectionBreak ||
      phase == BrainCheckPhase.resumeGate ||
      (phase == BrainCheckPhase.intro && startedAt != null);

  bool get isComplete => phase == BrainCheckPhase.completed;

  int get answeredCount => answers.length;

  BrainCheckProgress copyWith({
    BrainCheckMode? mode,
    BrainCheckPhase? phase,
    int? currentQuestionIndex,
    int? currentSectionIndex,
    Map<String, BrainCheckAnswer>? answers,
    String? source,
    DateTime? startedAt,
    DateTime? updatedAt,
    bool clearSource = false,
  }) {
    return BrainCheckProgress(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      answers: answers ?? this.answers,
      source: clearSource ? null : (source ?? this.source),
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mode': mode.wireName,
        'phase': phase.name,
        'currentQuestionIndex': currentQuestionIndex,
        'currentSectionIndex': currentSectionIndex,
        'answers': answers.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        if (source != null) 'source': source,
        if (startedAt != null) 'startedAt': startedAt!.toUtc().toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
      };

  factory BrainCheckProgress.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final answers = <String, BrainCheckAnswer>{};
    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        if (value is Map) {
          answers[key.toString()] = BrainCheckAnswer.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    BrainCheckPhase phase;
    try {
      phase = BrainCheckPhase.values.byName(json['phase'] as String? ?? 'empty');
    } catch (_) {
      phase = BrainCheckPhase.empty;
    }

    return BrainCheckProgress(
      mode: BrainCheckModeX.fromWire(json['mode'] as String?),
      phase: phase,
      currentQuestionIndex:
          (json['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      currentSectionIndex: (json['currentSectionIndex'] as num?)?.toInt() ?? 0,
      answers: Map<String, BrainCheckAnswer>.unmodifiable(answers),
      source: json['source'] as String?,
      startedAt: _parseDate(json['startedAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toUtc();
    } catch (_) {
      return null;
    }
  }
}
