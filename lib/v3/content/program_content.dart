import 'localized_text.dart';

class ProgramWeek {
  const ProgramWeek({
    required this.week,
    required this.title,
    required this.goal,
  });

  final int week;
  final LocalizedText title;
  final LocalizedText goal;

  factory ProgramWeek.fromJson(Map<String, dynamic> json) {
    final week = (json['week'] as num).toInt();
    return ProgramWeek(
      week: week,
      title: LocalizedText.fromJson(json['title'], path: 'weeks[$week].title'),
      goal: LocalizedText.fromJson(json['goal'], path: 'weeks[$week].goal'),
    );
  }
}

class ProgramLesson {
  const ProgramLesson({
    required this.title,
    required this.body,
    required this.key,
  });

  final LocalizedText title;
  final LocalizedStringList body;
  final LocalizedText key;

  factory ProgramLesson.fromJson(Map<String, dynamic> json, {String path = ''}) {
    return ProgramLesson(
      title: LocalizedText.fromJson(json['title'], path: '$path.title'),
      body: LocalizedStringList.fromJson(json['body'], path: '$path.body'),
      key: LocalizedText.fromJson(json['key'], path: '$path.key'),
    );
  }
}

class ProgramDay {
  const ProgramDay({
    required this.day,
    required this.week,
    required this.lesson,
    required this.practiceId,
    required this.challenge,
    required this.reflection,
    this.bonusId,
    this.clarityCheck = false,
    this.graduation = false,
  });

  final int day;
  final int week;
  final ProgramLesson lesson;
  final String practiceId;
  final String? bonusId;
  final LocalizedText challenge;
  final LocalizedText reflection;
  final bool clarityCheck;
  final bool graduation;

  factory ProgramDay.fromJson(Map<String, dynamic> json) {
    final day = (json['day'] as num).toInt();
    final path = 'days[$day]';
    return ProgramDay(
      day: day,
      week: (json['week'] as num).toInt(),
      lesson: ProgramLesson.fromJson(
        Map<String, dynamic>.from(json['lesson'] as Map),
        path: '$path.lesson',
      ),
      practiceId: json['practiceId'] as String,
      bonusId: json['bonusId'] as String?,
      challenge:
          LocalizedText.fromJson(json['challenge'], path: '$path.challenge'),
      reflection:
          LocalizedText.fromJson(json['reflection'], path: '$path.reflection'),
      clarityCheck: json['clarityCheck'] as bool? ?? false,
      graduation: json['graduation'] as bool? ?? false,
    );
  }
}

class ProgramContent {
  const ProgramContent({
    required this.version,
    required this.name,
    required this.dailyMinutes,
    required this.freeDays,
    required this.weeks,
    required this.days,
  });

  final int version;
  final LocalizedText name;
  final LocalizedText dailyMinutes;
  final int freeDays;
  final List<ProgramWeek> weeks;
  final List<ProgramDay> days;

  factory ProgramContent.fromJson(Map<String, dynamic> json) {
    final weeksRaw = json['weeks'] as List? ?? const [];
    final daysRaw = json['days'] as List? ?? const [];
    return ProgramContent(
      version: (json['version'] as num?)?.toInt() ?? 1,
      name: LocalizedText.fromJson(json['name'], path: 'program.name'),
      dailyMinutes: LocalizedText.fromJson(
        json['dailyMinutes'],
        path: 'program.dailyMinutes',
      ),
      freeDays: (json['freeDays'] as num?)?.toInt() ?? 7,
      weeks: weeksRaw
          .map((e) => ProgramWeek.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      days: daysRaw
          .map((e) => ProgramDay.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
    );
  }

  ProgramDay? dayByNumber(int day) {
    for (final d in days) {
      if (d.day == day) return d;
    }
    return null;
  }
}
