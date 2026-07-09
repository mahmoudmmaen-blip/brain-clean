import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../application/app_preferences_provider.dart';
import '../providers/locale_provider.dart';
import 'app_notification_service.dart';

const worryWindowNotificationId = 9001;
const worryWindowPayload = '/worry-window';

/// Daily worry-window reminder scheduled from Settings.
class WorryWindowNotificationService {
  WorryWindowNotificationService(this._ref);

  final Ref _ref;

  Future<void> reschedule() async {
    try {
      tz_data.initializeTimeZones();
      final service = _ref.read(appNotificationServiceProvider);
      await service.initialize();
      await service.plugin.cancel(worryWindowNotificationId);

      final prefs = _ref.read(appPreferencesProvider);
      if (!prefs.worryWindowReminderEnabled) return;

      final isArabic = _ref.read(localeProvider).languageCode == 'ar';
      const android = AndroidNotificationDetails(
        'worry_window_reminder',
        'Worry Window',
        channelDescription: 'Daily worry window reminder',
        importance: Importance.high,
        priority: Priority.high,
      );
      const ios = DarwinNotificationDetails();
      const details = NotificationDetails(android: android, iOS: ios);

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        prefs.worryWindowReminderHour,
        prefs.worryWindowReminderMinute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await service.plugin.zonedSchedule(
        worryWindowNotificationId,
        isArabic ? 'وقت نافذة القلق 🧠' : 'Worry window time 🧠',
        isArabic
            ? '١٠ دقايق تفرّغ دماغك — هتفضل أهدى طول الليل'
            : '10 minutes to empty your mind — sleep more peacefully tonight',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: worryWindowPayload,
      );
    } catch (_) {
      // Best-effort scheduling.
    }
  }
}

final worryWindowNotificationServiceProvider =
    Provider<WorryWindowNotificationService>(
  (ref) => WorryWindowNotificationService(ref),
);
