import 'app_open_event.dart';

/// Peak-hour detection from recent app opens.
class SmartReminderService {
  const SmartReminderService._();

  static bool shouldSchedule(int? detectedHour) => detectedHour != null;

  static int? detectPeakHour(List<AppOpenEvent> events, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final cutoff = reference.subtract(const Duration(days: 7));

    final recent = events
        .where((event) => !event.openedAt.isBefore(cutoff))
        .toList();

    if (recent.length < 3) return null;

    final counts = <int, int>{};
    for (final event in recent) {
      counts[event.hourOfDay] = (counts[event.hourOfDay] ?? 0) + 1;
    }

    var bestHour = -1;
    var bestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount ||
          (entry.value == bestCount && entry.key < bestHour)) {
        bestCount = entry.value;
        bestHour = entry.key;
      }
    }

    if (bestCount >= 3) return bestHour;
    return null;
  }
}
