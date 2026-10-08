import 'localized_text.dart';

enum ExerciseTier { free, pro }

enum ExerciseMode { steps, guided, timer, focusTimer }

class ExerciseContent {
  const ExerciseContent({
    required this.id,
    required this.category,
    required this.minutes,
    required this.tier,
    required this.mode,
    required this.title,
    required this.why,
    required this.steps,
    required this.easy,
    this.input,
    this.guidedSeconds,
    this.timerMinutes,
    this.breathingPattern,
    this.triggersClarityCheck = false,
  });

  final String id;
  final String category;
  final int minutes;
  final ExerciseTier tier;
  final ExerciseMode mode;
  final LocalizedText title;
  final LocalizedText why;
  final LocalizedStringList steps;
  final LocalizedText easy;
  final String? input;
  final int? guidedSeconds;
  final int? timerMinutes;
  final List<int>? breathingPattern;
  final bool triggersClarityCheck;

  factory ExerciseContent.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final path = 'exercises[$id]';
    return ExerciseContent(
      id: id,
      category: json['category'] as String,
      minutes: (json['minutes'] as num).toInt(),
      tier: _tier(json['tier'] as String?),
      mode: _mode(json['mode'] as String?),
      title: LocalizedText.fromJson(json['title'], path: '$path.title'),
      why: LocalizedText.fromJson(json['why'], path: '$path.why'),
      steps: LocalizedStringList.fromJson(json['steps'], path: '$path.steps'),
      easy: LocalizedText.fromJson(json['easy'], path: '$path.easy'),
      input: json['input'] as String?,
      guidedSeconds: (json['guided_seconds'] as num?)?.toInt(),
      timerMinutes: (json['timer_minutes'] as num?)?.toInt(),
      breathingPattern: (json['breathing_pattern'] as List?)
          ?.map((e) => (e as num).toInt())
          .toList(growable: false),
      triggersClarityCheck: json['triggers_clarity_check'] as bool? ?? false,
    );
  }

  static ExerciseTier _tier(String? raw) => switch (raw) {
        'pro' => ExerciseTier.pro,
        _ => ExerciseTier.free,
      };

  static ExerciseMode _mode(String? raw) => switch (raw) {
        'guided' => ExerciseMode.guided,
        'timer' => ExerciseMode.timer,
        'focus_timer' => ExerciseMode.focusTimer,
        _ => ExerciseMode.steps,
      };
}

class ExercisesContent {
  const ExercisesContent({
    required this.version,
    required this.categories,
    required this.exercises,
  });

  final int version;
  final Map<String, LocalizedText> categories;
  final List<ExerciseContent> exercises;

  factory ExercisesContent.fromJson(Map<String, dynamic> json) {
    final catsRaw = Map<String, dynamic>.from(json['categories'] as Map? ?? {});
    final categories = <String, LocalizedText>{};
    for (final entry in catsRaw.entries) {
      categories[entry.key] = LocalizedText.fromJson(
        entry.value,
        path: 'categories.${entry.key}',
      );
    }
    final list = (json['exercises'] as List? ?? const [])
        .map((e) => ExerciseContent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    return ExercisesContent(
      version: (json['version'] as num?)?.toInt() ?? 1,
      categories: categories,
      exercises: list,
    );
  }

  ExerciseContent? byId(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  Set<String> get ids =>
      exercises.map((e) => e.id).toSet();
}
