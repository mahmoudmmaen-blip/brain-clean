import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_navigator_key.dart';
import '../../../core/utils/date_format_utils.dart';

const emotionBreathingSupportPayload = 'emotion_breathing_support';

/// Local notifications after emotion logging (supportive, no score penalty).
class EmotionNotificationService {
  EmotionNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _navigatorKey = navigatorKey;

  final FlutterLocalNotificationsPlugin _plugin;
  final GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != emotionBreathingSupportPayload) return;
    final context = _navigatorKey?.currentContext;
    if (context == null || !context.mounted) return;
    final day = DateFormatUtils.dayKey(DateTime.now());
    context.push(
      '${AppRoutes.v2DailyProgramTimer}'
      '?activityId=emotion_breathing_60'
      '&minutes=1'
      '&title=${Uri.encodeComponent('')}'
      '&day=$day',
    );
  }

  Future<void> showBreathingSupport({
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
  }) async {
    await initialize();
    final androidDetails = AndroidNotificationDetails(
      'emotion_support',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      1,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: emotionBreathingSupportPayload,
    );
  }
}

final emotionNotificationServiceProvider =
    Provider<EmotionNotificationService>((ref) {
  return EmotionNotificationService(navigatorKey: appNavigatorKey);
});
