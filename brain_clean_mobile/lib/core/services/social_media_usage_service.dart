import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// View-only social media foreground time via Android Usage Access.
///
/// **Play v1:** [isPlayFeatureEnabled] is `false` — the Home card is hidden and
/// `PACKAGE_USAGE_STATS` is not declared. Service APIs stay testable for a
/// later opt-in release with proper disclosure.
class SocialMediaUsageService {
  SocialMediaUsageService({
    MethodChannel? channel,
    @visibleForTesting bool? platformIsAndroid,
  })  : _channel = channel ??
            const MethodChannel('com.brainclean.mobile/usage_stats'),
        _platformIsAndroid = platformIsAndroid;

  final MethodChannel _channel;
  final bool? _platformIsAndroid;

  /// Master switch for shipping Usage Access UI + Play declaration.
  ///
  /// Keep `false` until Play Console Data Safety / sensitive-permission
  /// justification and an in-app opt-in disclosure are ready.
  static const bool isPlayFeatureEnabled = false;

  /// Android platform can call the usage MethodChannel (independent of Play gate).
  bool get isSupported =>
      _platformIsAndroid ??
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  /// Home card / provider may surface the feature (Play gate ∧ Android).
  bool get isHomeCardEnabled => isPlayFeatureEnabled && isSupported;

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
  ///
  /// Data stays on-device; this app does not upload usage maps to the cloud.
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
