import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../application/app_preferences_provider.dart';
import '../providers/locale_provider.dart';
import 'app_notification_service.dart';

/// Morning / evening / night smart reminders wired to settings toggles.
class SmartNotificationService {
  SmartNotificationService(this._ref);

  final Ref _ref;

  static const morningId = 8001;
  static const eveningId = 8002;
  static const nightId = 8003;

  Future<void> rescheduleAll() async {
    try {
      tz_data.initializeTimeZones();
      final service = _ref.read(appNotificationServiceProvider);
      await service.initialize();
      await service.plugin.cancel(morningId);
      await service.plugin.cancel(eveningId);
      await service.plugin.cancel(nightId);

      final prefs = _ref.read(appPreferencesProvider);
      if (!prefs.dailyFocusReminderEnabled &&
          !prefs.emotionNotificationsEnabled) {
        return;
      }

      final isArabic = _ref.read(localeProvider).languageCode == 'ar';
      const android = AndroidNotificationDetails(
        'smart_reminders',
        'Smart Reminders',
        channelDescription: 'Daily focus and wellness reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const ios = DarwinNotificationDetails();
      const details = NotificationDetails(android: android, iOS: ios);

      if (prefs.dailyFocusReminderEnabled) {
        await _scheduleDaily(
          service: service,
          id: morningId,
          hour: 7,
          minute: 0,
          title: isArabic ? 'صباح التركيز ☀️' : 'Focus Morning ☀️',
          body: isArabic
              ? 'ابدأ يومك بمهمة واحدة فقط'
              : 'Start your day with one single task',
          details: details,
        );
        await _scheduleDaily(
          service: service,
          id: nightId,
          hour: 21,
          minute: 30,
          title: isArabic ? 'وقت الراحة 🌙' : 'Rest time 🌙',
          body: isArabic
              ? 'نم مبكراً — دماغك يحتاج 7-8 ساعات'
              : 'Sleep early — your brain needs 7-8 hours',
          details: details,
        );
      }

      if (prefs.emotionNotificationsEnabled) {
        await _scheduleDaily(
          service: service,
          id: eveningId,
          hour: 18,
          minute: 0,
          title: isArabic ? 'كيف كان يومك؟ 💭' : 'How was your day? 💭',
          body: isArabic
              ? 'سجّل إحساسك الآن في دائرة الأحاسيس'
              : 'Log your emotions in the wheel now',
          details: details,
        );
      }
    } catch (_) {
      // Best-effort scheduling.
    }
  }

  Future<void> _scheduleDaily({
    required AppNotificationService service,
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required NotificationDetails details,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await service.plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

final smartNotificationServiceProvider = Provider<SmartNotificationService>(
  (ref) => SmartNotificationService(ref),
);
