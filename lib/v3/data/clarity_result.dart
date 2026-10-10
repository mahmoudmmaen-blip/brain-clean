class ClarityAreaScores {
  const ClarityAreaScores({
    required this.focus,
    required this.control,
    required this.sleep,
    required this.calm,
  });

  final int focus;
  final int control;
  final int sleep;
  final int calm;

  Map<String, dynamic> toJson() => {
        'focus': focus,
        'control': control,
        'sleep': sleep,
        'calm': calm,
      };

  factory ClarityAreaScores.fromJson(Map<String, dynamic> json) {
    return ClarityAreaScores(
      focus: (json['focus'] as num?)?.toInt() ?? 0,
      control: (json['control'] as num?)?.toInt() ?? 0,
      sleep: (json['sleep'] as num?)?.toInt() ?? 0,
      calm: (json['calm'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClarityResult {
  const ClarityResult({
    required this.takenAt,
    required this.programDay,
    required this.score,
    required this.areas,
    required this.hoursEstimate,
    required this.answers,
  });

  final DateTime takenAt;
  final int programDay;
  final int score;
  final ClarityAreaScores areas;
  final double hoursEstimate;
  /// Question id → scale value 0..4 (includes `q_hours` as numeric hours).
  final Map<String, num> answers;

  Map<String, dynamic> toJson() => {
        'takenAt': takenAt.toIso8601String(),
        'programDay': programDay,
        'score': score,
        'areas': areas.toJson(),
        'hoursEstimate': hoursEstimate,
        'answers': answers.map((k, v) => MapEntry(k, v)),
      };

  factory ClarityResult.fromJson(Map<String, dynamic> json) {
    final answersRaw = Map<String, dynamic>.from(json['answers'] as Map? ?? {});
    final answers = <String, num>{};
    for (final entry in answersRaw.entries) {
      answers[entry.key] = entry.value as num;
    }
    return ClarityResult(
      takenAt: DateTime.parse(json['takenAt'] as String),
      programDay: (json['programDay'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      areas: ClarityAreaScores.fromJson(
        Map<String, dynamic>.from(json['areas'] as Map),
      ),
      hoursEstimate: (json['hoursEstimate'] as num).toDouble(),
      answers: answers,
    );
  }
}
