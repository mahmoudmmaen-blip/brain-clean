import 'package:brain_clean_mobile/core/services/social_media_usage_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocialMediaUsageService', () {
    const channel = MethodChannel('com.brainclean.mobile/usage_stats');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('getTodaySocialMediaUsage parses package minute map', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getTodaySocialMediaUsage') {
          return {
            'com.instagram.android': 12,
            'com.zhiliaoapp.musically': 8,
          };
        }
        return null;
      });

      final service = SocialMediaUsageService(
        channel: channel,
        platformIsAndroid: true,
      );
      final usage = await service.getTodaySocialMediaUsage();

      expect(usage['com.instagram.android'], 12);
      expect(usage['com.zhiliaoapp.musically'], 8);
    });

    test('hasUsageAccess returns false when channel throws', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'error');
      });

      final service = SocialMediaUsageService(
        channel: channel,
        platformIsAndroid: true,
      );
      expect(await service.hasUsageAccess(), isFalse);
    });

    test('unsupported platform skips channel and returns empty', () async {
      var channelCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        channelCalled = true;
        return null;
      });

      final service = SocialMediaUsageService(
        channel: channel,
        platformIsAndroid: false,
      );

      expect(service.isSupported, isFalse);
      expect(await service.hasUsageAccess(), isFalse);
      expect(await service.getTodaySocialMediaUsage(), isEmpty);
      await service.openUsageAccessSettings();
      expect(channelCalled, isFalse);
    });

    test('Play v1 keeps Home card disabled even on Android', () {
      final service = SocialMediaUsageService(
        channel: channel,
        platformIsAndroid: true,
      );
      expect(SocialMediaUsageService.isPlayFeatureEnabled, isFalse);
      expect(service.isSupported, isTrue);
      expect(service.isHomeCardEnabled, isFalse);
    });
  });
}
