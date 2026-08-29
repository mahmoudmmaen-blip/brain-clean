/// One checkable activity in the structured daily program scaffold.
class StructuredDailyActivity {
  const StructuredDailyActivity({
    required this.id,
    required this.titleKey,
    required this.minutes,
    this.completed = false,
    this.isAdaptive = false,
    this.isOptional = false,
  });

  final String id;

  /// l10n getter key (resolved via [resolveStructuredDailyActivityTitle]).
  final String titleKey;
  final int minutes;
  final bool completed;

  /// True when this item was added/modified from test-score personalization.
  final bool isAdaptive;

  /// Optional add-on (e.g. NSDR rest) — not required for day completion.
  final bool isOptional;

  StructuredDailyActivity copyWith({
    String? id,
    String? titleKey,
    int? minutes,
    bool? completed,
    bool? isAdaptive,
    bool? isOptional,
  }) {
    return StructuredDailyActivity(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      minutes: minutes ?? this.minutes,
      completed: completed ?? this.completed,
      isAdaptive: isAdaptive ?? this.isAdaptive,
      isOptional: isOptional ?? this.isOptional,
    );
  }
}

/// Pillar-style scores used by the Pro personalized builder.
class StructuredDailyProgramScores {
  const StructuredDailyProgramScores({
    required this.attention,
    required this.memory,
    required this.digitalAddiction,
    this.iq = 50,
  });

  final int attention;
  final int memory;
  final int digitalAddiction;
  final int iq;

  static const neutral = StructuredDailyProgramScores(
    attention: 50,
    memory: 50,
    digitalAddiction: 40,
    iq: 50,
  );
}
