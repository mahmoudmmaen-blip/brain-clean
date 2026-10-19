/// Pure planner for V3 local notifications (max 2/day; 20-20-20 excluded).
enum V3NotificationKind { dailyReminder, eveningCheckIn, clarityRecheck }

class V3PlannedNotification {
  const V3PlannedNotification({
    required this.kind,
    required this.hour,
    required this.minute,
    required this.dayNumber,
  });

  final V3NotificationKind kind;
  final int hour;
  final int minute;
  /// Program day for copy (daily / clarity).
  final int dayNumber;

  int get sortMinutes => hour * 60 + minute;
}

abstract final class V3NotificationPlan {
  V3NotificationPlan._();

  static const maxPerDay = 2;
  static const eveningHour = 21;
  static const eveningMinute = 0;
  static const clarityHour = 10;
  static const clarityMinute = 0;

  /// Builds up to [maxPerDay] notifications for the local calendar day of [now].
  static List<V3PlannedNotification> build({
    required DateTime now,
    required int currentDay,
    required bool programFinished,
    required bool todayDone,
    required bool eveningEnabled,
    required bool eveningDoneToday,
    required bool isClarityRecheckDay,
    required bool clarityDoneForCurrentDay,
    required int reminderHour,
    required int reminderMinute,
  }) {
    if (programFinished) {
      // After program: only evening check-in may still fire (if enabled).
      if (eveningEnabled && !eveningDoneToday) {
        return [
          V3PlannedNotification(
            kind: V3NotificationKind.eveningCheckIn,
            hour: eveningHour,
            minute: eveningMinute,
            dayNumber: currentDay,
          ),
        ];
      }
      return const [];
    }

    final candidates = <V3PlannedNotification>[];

    // Clarity re-check replaces the daily reminder message on check days.
    if (isClarityRecheckDay && !clarityDoneForCurrentDay && !todayDone) {
      candidates.add(
        V3PlannedNotification(
          kind: V3NotificationKind.clarityRecheck,
          hour: reminderHour,
          minute: reminderMinute,
          dayNumber: currentDay,
        ),
      );
    } else if (!todayDone) {
      candidates.add(
        V3PlannedNotification(
          kind: V3NotificationKind.dailyReminder,
          hour: reminderHour,
          minute: reminderMinute,
          dayNumber: currentDay,
        ),
      );
    }

    if (eveningEnabled && !eveningDoneToday) {
      candidates.add(
        const V3PlannedNotification(
          kind: V3NotificationKind.eveningCheckIn,
          hour: eveningHour,
          minute: eveningMinute,
          dayNumber: 0,
        ),
      );
    }

    candidates.sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    if (candidates.length <= maxPerDay) return candidates;
    return candidates.take(maxPerDay).toList(growable: false);
  }

  /// True when [programDay] is a re-check day (7/14/21/30), not baseline day 1.
  static bool isClarityRecheckDay(int programDay) =>
      programDay == 7 ||
      programDay == 14 ||
      programDay == 21 ||
      programDay == 30;
}
