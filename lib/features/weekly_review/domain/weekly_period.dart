/// Locale-independent local ISO calendar week (Mon–Sun).
class WeeklyPeriod {
  const WeeklyPeriod({
    required this.periodId,
    required this.startDayKey,
    required this.endDayKey,
    required this.timezoneOffsetMinutes,
    required this.materializedAt,
  });

  /// `iso_{weekYear}_Wnn`
  final String periodId;
  final String startDayKey;
  final String endDayKey;
  final int timezoneOffsetMinutes;
  final DateTime materializedAt;

  bool containsDayKey(String dayKey) =>
      dayKey.compareTo(startDayKey) >= 0 && dayKey.compareTo(endDayKey) <= 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'periodId': periodId,
        'startDayKey': startDayKey,
        'endDayKey': endDayKey,
        'timezoneOffsetMinutes': timezoneOffsetMinutes,
        'materializedAt': materializedAt.toUtc().toIso8601String(),
      };

  factory WeeklyPeriod.fromJson(Map<String, dynamic> json) {
    return WeeklyPeriod(
      periodId: json['periodId'] as String,
      startDayKey: json['startDayKey'] as String,
      endDayKey: json['endDayKey'] as String,
      timezoneOffsetMinutes: json['timezoneOffsetMinutes'] as int,
      materializedAt: DateTime.parse(json['materializedAt'] as String).toUtc(),
    );
  }
}

/// Formats / parses ISO week period IDs.
abstract final class WeeklyPeriodId {
  static final RegExp _pattern = RegExp(r'^iso_(\d{4})_W(\d{2})$');

  static String format(int isoWeekYear, int isoWeek) {
    final nn = isoWeek.toString().padLeft(2, '0');
    return 'iso_${isoWeekYear}_W$nn';
  }

  static ({int year, int week})? tryParse(String periodId) {
    final m = _pattern.firstMatch(periodId);
    if (m == null) return null;
    return (year: int.parse(m.group(1)!), week: int.parse(m.group(2)!));
  }
}
