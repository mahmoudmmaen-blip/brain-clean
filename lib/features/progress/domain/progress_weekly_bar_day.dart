/// One bar in the Progress 7-day weekly chart.
class ProgressWeeklyBarDay {
  const ProgressWeeklyBarDay({
    required this.dayKey,
    required this.weekdayLabel,
    required this.completed,
  });

  final String dayKey;
  final String weekdayLabel;
  final bool completed;
}
