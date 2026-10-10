class DayProgress {
  const DayProgress({
    required this.day,
    this.startedAt,
    required this.lessonDone,
    required this.practiceDone,
    required this.usedEasy,
    required this.challengeAccepted,
    this.challengeDone,
    this.completedAt,
  });

  final int day;
  final DateTime? startedAt;
  final bool lessonDone;
  final bool practiceDone;
  final bool usedEasy;
  final bool challengeAccepted;
  final bool? challengeDone;
  final DateTime? completedAt;

  bool get isCompleted =>
      lessonDone && (practiceDone || usedEasy) && completedAt != null;

  DayProgress copyWith({
    DateTime? startedAt,
    bool? lessonDone,
    bool? practiceDone,
    bool? usedEasy,
    bool? challengeAccepted,
    bool? challengeDone,
    DateTime? completedAt,
  }) {
    return DayProgress(
      day: day,
      startedAt: startedAt ?? this.startedAt,
      lessonDone: lessonDone ?? this.lessonDone,
      practiceDone: practiceDone ?? this.practiceDone,
      usedEasy: usedEasy ?? this.usedEasy,
      challengeAccepted: challengeAccepted ?? this.challengeAccepted,
      challengeDone: challengeDone ?? this.challengeDone,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'startedAt': startedAt?.toIso8601String(),
        'lessonDone': lessonDone,
        'practiceDone': practiceDone,
        'usedEasy': usedEasy,
        'challengeAccepted': challengeAccepted,
        'challengeDone': challengeDone,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DayProgress.fromJson(Map<String, dynamic> json) {
    return DayProgress(
      day: (json['day'] as num).toInt(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      lessonDone: json['lessonDone'] as bool? ?? false,
      practiceDone: json['practiceDone'] as bool? ?? false,
      usedEasy: json['usedEasy'] as bool? ?? false,
      challengeAccepted: json['challengeAccepted'] as bool? ?? false,
      challengeDone: json['challengeDone'] as bool?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
