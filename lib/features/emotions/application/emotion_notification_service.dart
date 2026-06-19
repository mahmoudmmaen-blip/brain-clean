import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_navigator_key.dart';

const emotionRecoveryDeclinePayload = 'emotion_recovery_decline';

/// Shows local notifications when emotion logging reduces recovery score.
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
    if (response.payload != emotionRecoveryDeclinePayload) return;
    final context = _navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      context.push(AppRoutes.emotionWheel);
    }
  }

  Future<void> showRecoveryDecline({
    required int newBcsRounded,
  }) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'emotion_recovery',
      'تنبيهات التعافي',
      channelDescription: 'تنبيهات تأثير المشاعر على نسبة التعافي',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      1,
      'تنبيه: تراجع نسبة التعافي',
      'مشاعرك السلبية أثّرت على نسبة تعافيك. تعافيك الحالي: $newBcsRounded%',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: emotionRecoveryDeclinePayload,
    );
  }
}

final emotionNotificationServiceProvider =
    Provider<EmotionNotificationService>((ref) {
  return EmotionNotificationService(navigatorKey: appNavigatorKey);
});
