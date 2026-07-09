/// Calendar week boundaries (Monday–Sunday).
class WeekRange {
  const WeekRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

WeekRange weekRangeContaining(DateTime date) {
  final day = dateOnly(date);
  final monday = day.subtract(Duration(days: day.weekday - DateTime.monday));
  final sunday = monday.add(const Duration(days: 6));
  return WeekRange(start: monday, end: sunday);
}

WeekRange previousWeekRange(WeekRange current) {
  final priorMonday = current.start.subtract(const Duration(days: 7));
  return weekRangeContaining(priorMonday);
}

bool isDateInRange(DateTime date, WeekRange range) {
  final day = dateOnly(date.toLocal());
  return !day.isBefore(range.start) && !day.isAfter(range.end);
}

bool isPaddedSnapshotDate(DateTime date) => date.year == 2000;
