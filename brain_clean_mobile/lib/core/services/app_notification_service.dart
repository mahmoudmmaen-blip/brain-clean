import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../routing/app_navigator_key.dart';

import 'worry_window_notification_service.dart';

const weeklyReportPayload = 'weekly_report';

/// Shared local notifications plugin bootstrap.
class AppNotificationService {
  AppNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<void> initialize({
    void Function(String? payload)? onPayload,
  }) async {
    if (_initialized) return;
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

    if (payload == weeklyReportPayload) {
      context.push(AppRoutes.weeklyReport);
      return;
    }
    if (payload == worryWindowPayload || payload == AppRoutes.worryWindow) {
      context.push(AppRoutes.worryWindow);
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
}

final appNotificationServiceProvider = Provider<AppNotificationService>(
  (ref) => AppNotificationService(),
);
