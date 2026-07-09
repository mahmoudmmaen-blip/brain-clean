import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/app_notification_service.dart';

const smartReminderNotificationId = 42;
const smartReminderPayload = AppRoutes.home;

class SmartReminderNotificationScheduler {
  SmartReminderNotificationScheduler(this._ref);

  final Ref _ref;

  Future<void> scheduleAtHour(int hour) async {
    try {
      tz_data.initializeTimeZones();
      final service = _ref.read(appNotificationServiceProvider);
      await service.initialize();
      await service.plugin.cancel(smartReminderNotificationId);

      final isArabic = _ref.read(localeProvider).languageCode == 'ar';
      final copy = _copyForWeekday(DateTime.now().weekday, isArabic: isArabic);

      const android = AndroidNotificationDetails(
        'smart_reminder_behavior',
        'Smart Reminder',
        channelDescription: 'Behavior-based daily reminder',
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
        hour,
        0,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await service.plugin.zonedSchedule(
        smartReminderNotificationId,
        copy.title,
        copy.body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: smartReminderPayload,
      );
    } catch (_) {
      // Best-effort scheduling.
    }
  }

  Future<void> cancel() async {
    try {
      final service = _ref.read(appNotificationServiceProvider);
      await service.initialize();
      await service.plugin.cancel(smartReminderNotificationId);
    } catch (_) {}
  }
}

class _NotificationCopy {
  const _NotificationCopy({required this.title, required this.body});

  final String title;
  final String body;
}

_NotificationCopy _copyForWeekday(int weekday, {required bool isArabic}) {
  if (isArabic) {
    return switch (weekday) {
      DateTime.saturday =>
        const _NotificationCopy(
          title: 'وقتك المفضل 🧠',
          body: 'دماغك جاهز — افتح Brain Clean',
        ),
      DateTime.sunday => const _NotificationCopy(
          title: 'لحظتك اليومية ✨',
          body: 'خطوة صغيرة تفرق — ابدأ دلوقتي',
        ),
      DateTime.monday => const _NotificationCopy(
          title: 'أسبوع جديد 🌿',
          body: 'ابدأ الأسبوع بصفاء ذهن',
        ),
      DateTime.tuesday => const _NotificationCopy(
          title: 'تحدي اليوم 🎮',
          body: 'تحدي دماغك اليومي مستنياك',
        ),
      DateTime.wednesday => const _NotificationCopy(
          title: 'منتصف الأسبوع 💪',
          body: 'كمّل — نص الطريق عدى',
        ),
      DateTime.thursday => const _NotificationCopy(
          title: 'يوم قوي 🔥',
          body: 'سجّل يومك واحتفل بتقدمك',
        ),
      DateTime.friday => const _NotificationCopy(
          title: 'ختام الأسبوع 🏆',
          body: 'شوف تقرير أسبوعك — عملت حاجة كويسة',
        ),
      _ => const _NotificationCopy(
          title: 'وقتك المفضل 🧠',
          body: 'دماغك جاهز — افتح Brain Clean',
        ),
    };
  }

  return switch (weekday) {
    DateTime.saturday => const _NotificationCopy(
        title: 'Your favorite time 🧠',
        body: 'Your brain is ready — open Brain Clean',
      ),
    DateTime.sunday => const _NotificationCopy(
        title: 'Your daily moment ✨',
        body: 'A small step matters — start now',
      ),
    DateTime.monday => const _NotificationCopy(
        title: 'New week 🌿',
        body: 'Start the week with a clear mind',
      ),
    DateTime.tuesday => const _NotificationCopy(
        title: "Today's challenge 🎮",
        body: 'Your daily brain challenge is waiting',
      ),
    DateTime.wednesday => const _NotificationCopy(
        title: 'Midweek 💪',
        body: 'Keep going — you are halfway there',
      ),
    DateTime.thursday => const _NotificationCopy(
        title: 'Strong day 🔥',
        body: 'Log your day and celebrate progress',
      ),
    DateTime.friday => const _NotificationCopy(
        title: 'Week wrap-up 🏆',
        body: 'Check your weekly report — you did well',
      ),
    _ => const _NotificationCopy(
        title: 'Your favorite time 🧠',
        body: 'Your brain is ready — open Brain Clean',
      ),
  };
}

final smartReminderNotificationSchedulerProvider =
    Provider<SmartReminderNotificationScheduler>(
  (ref) => SmartReminderNotificationScheduler(ref),
);
