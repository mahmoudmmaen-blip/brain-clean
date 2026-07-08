import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';

const dailyReminderNotificationId = 1001;
const dailyReminderEnabledKey = 'daily_reminder_enabled';

/// Daily reminder notifications at 9:00 AM local time.
class NotificationsService {
  NotificationsService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<bool> isDailyReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(dailyReminderEnabledKey) ?? true;
    } catch (error) {
      debugPrint('NotificationsService: read preference failed: $error');
      return true;
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(dailyReminderEnabledKey, enabled);
    } catch (error) {
      debugPrint('NotificationsService: save preference failed: $error');
    }
  }

  Future<void> initialize() async {
    try {
      if (_initialized) return;

      tz_data.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );

      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      _initialized = true;
    } catch (error) {
      debugPrint('NotificationsService: initialize failed: $error');
    }
  }

  Future<void> scheduleDailyReminder({
    Locale? locale,
    String? title,
    String? body,
  }) async {
    try {
      if (!await isDailyReminderEnabled()) return;

      await initialize();

      final resolvedLocale = locale ?? _defaultLocale();
      final loc = lookupAppLocalizations(resolvedLocale);
      final notificationTitle = title ?? loc.notifDailyTitle;
      final notificationBody = body ?? loc.notifDailyBody;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        9,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      const android = AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Daily Brain Clean exercise reminder',
        importance: Importance.high,
        priority: Priority.high,
      );
      const ios = DarwinNotificationDetails();
      const details = NotificationDetails(android: android, iOS: ios);

      await _plugin.zonedSchedule(
        dailyReminderNotificationId,
        notificationTitle,
        notificationBody,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint('NotificationsService: scheduleDailyReminder failed: $error');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('NotificationsService: cancelAll failed: $error');
    }
  }

  Locale _defaultLocale() {
    try {
      final code =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (code == 'en') return const Locale('en');
    } catch (_) {}
    return const Locale('ar');
  }
}
