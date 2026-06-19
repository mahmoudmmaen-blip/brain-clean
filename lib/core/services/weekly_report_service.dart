import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/diagnostic/presentation/bc_score_provider.dart';
import '../../features/home/presentation/home_streak_provider.dart';
import '../../features/reports/weekly_report_logic.dart';
import '../providers/locale_provider.dart';
import 'app_notification_service.dart';

const weeklyReportNotificationId = 7001;

/// Schedules a weekly report notification every Sunday at 9:00 AM.
class WeeklyReportService {
  WeeklyReportService(this._ref);

  final Ref _ref;

  Future<void> schedule() async {
    try {
      tz_data.initializeTimeZones();
      final service = _ref.read(appNotificationServiceProvider);
      await service.initialize();

      final isArabic = _ref.read(localeProvider).languageCode == 'ar';
      final streakDays = _ref.read(homeStreakSnapshotProvider).days;
      final bcs =
          (_ref.read(bcScoreSessionProvider)?.bcScore ?? 0).round();
      final title = isArabic ? 'تقرير أسبوعك 📊' : 'Your Weekly Report 📊';
      final body = weeklyNotificationBody(
        focusDays: streakDays,
        bcs: bcs,
        isArabic: isArabic,
      );

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        9,
      );
      while (scheduled.weekday != DateTime.sunday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
        if (scheduled.weekday != DateTime.sunday) continue;
      }

      const android = AndroidNotificationDetails(
        'weekly_report',
        'Weekly Report',
        channelDescription: 'Weekly progress summary',
        importance: Importance.high,
        priority: Priority.high,
      );
      const ios = DarwinNotificationDetails();
      const details = NotificationDetails(android: android, iOS: ios);

      await service.plugin.zonedSchedule(
        weeklyReportNotificationId,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: weeklyReportPayload,
      );
    } catch (_) {
      // Scheduling may fail in tests or without permissions.
    }
  }
}

final weeklyReportServiceProvider = Provider<WeeklyReportService>(
  (ref) => WeeklyReportService(ref),
);
