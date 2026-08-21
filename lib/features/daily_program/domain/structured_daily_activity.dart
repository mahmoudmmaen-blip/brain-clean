/// One checkable activity in the structured daily program scaffold.
class StructuredDailyActivity {
  const StructuredDailyActivity({
    required this.id,
    required this.titleKey,
    required this.minutes,
    this.completed = false,
  });

  final String id;

  /// l10n getter key (resolved via [resolveStructuredDailyActivityTitle]).
  final String titleKey;
  final int minutes;
  final bool completed;

  StructuredDailyActivity copyWith({
    String? id,
    String? titleKey,
    int? minutes,
    bool? completed,
  }) {
    return StructuredDailyActivity(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      minutes: minutes ?? this.minutes,
      completed: completed ?? this.completed,
    );
  }
}

/// Pillar-style scores used by the Pro personalized builder.
class StructuredDailyProgramScores {
  const StructuredDailyProgramScores({
    required this.attention,
    required this.memory,
    required this.digitalAddiction,
  });

  final int attention;
  final int memory;
  final int digitalAddiction;

  static const neutral = StructuredDailyProgramScores(
    attention: 50,
    memory: 50,
    digitalAddiction: 40,
  );
}
