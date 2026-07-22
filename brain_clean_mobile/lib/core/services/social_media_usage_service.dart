import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// View-only social media foreground time via Android Usage Access.
class SocialMediaUsageService {
  SocialMediaUsageService({
    MethodChannel? channel,
    @visibleForTesting bool? platformIsAndroid,
  })  : _channel = channel ??
            const MethodChannel('com.brainclean.mobile/usage_stats'),
        _platformIsAndroid = platformIsAndroid;

  final MethodChannel _channel;
  final bool? _platformIsAndroid;

  bool get isSupported => _platformIsAndroid ?? Platform.isAndroid;

  Future<bool> hasUsageAccess() async {
    if (!isSupported) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('hasUsageAccess');
      return granted ?? false;
    } catch (error, stackTrace) {
      debugPrint('SocialMediaUsageService.hasUsageAccess failed: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }

  Future<void> openUsageAccessSettings() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('openUsageAccessSettings');
    } catch (error, stackTrace) {
      debugPrint(
        'SocialMediaUsageService.openUsageAccessSettings failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  /// Package name → whole minutes of foreground usage today (local midnight → now).
  Future<Map<String, int>> getTodaySocialMediaUsage() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Object>('getTodaySocialMediaUsage');
      if (raw is! Map) return const {};
      return raw.map(
        (key, value) => MapEntry(
          key.toString(),
          switch (value) {
            final int v => v,
            final num n => n.round(),
            _ => 0,
          },
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('SocialMediaUsageService.getTodaySocialMediaUsage failed: $error');
      debugPrint('$stackTrace');
      return const {};
    }
  }
}
