import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../v3/application/twenty_twenty_service.dart';
import '../../v3/routing/v3_routes.dart';
import '../routing/app_navigator_key.dart';

const dailyReminderPayload = 'daily_reminder';
const eveningCheckInPayload = 'evening_check_in';

/// Shared local notifications plugin bootstrap.
class AppNotificationService {
  AppNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _tzReady = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<void> initialize({
    void Function(String? payload)? onPayload,
  }) async {
    if (_initialized) return;
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
        onPayload?.call(response.payload);
      },
    );
    _initialized = true;
  }

  void _handlePayload(String? payload) {
    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    if (payload == dailyReminderPayload ||
        payload == eveningCheckInPayload ||
        payload == twentyTwentyPayload) {
      context.go(V3Routes.today);
    }
  }

  Future<void> showSimple({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    const android = AndroidNotificationDetails(
      'brain_clean_general',
      'Brain Clean',
      channelDescription: 'General Brain Clean notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  Future<void> scheduleZoned({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    await initialize();
    const android = AndroidNotificationDetails(
      'brain_clean_twenty',
      '20-20-20',
      channelDescription: 'Eye rest reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: payload,
    );
  }

  Future<void> cancelIds(List<int> ids) async {
    await initialize();
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }
}

final appNotificationServiceProvider = Provider<AppNotificationService>(
  (ref) => AppNotificationService(),
);
