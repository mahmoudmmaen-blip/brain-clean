import 'dart:io';

import 'package:brain_clean_mobile/core/config/app_config.dart';
import 'package:brain_clean_mobile/core/services/external_link_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig.appVersion', () {
    test('matches pubspec.yaml version name (before +build)', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match = RegExp(r'^version:\s*([^\s+]+)', multiLine: true)
          .firstMatch(pubspec);
      expect(match, isNotNull);
      expect(AppConfig.appVersion, match!.group(1));
    });
  });

  group('ExternalLinkService', () {
    const channel = MethodChannel('com.brainclean.mobile/external_links');
    late List<MethodCall> calls;

    setUp(() {
      calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('openPrivacyPolicy uses the store privacy policy URL', () async {
      final service = ExternalLinkService(channel: channel);
      final ok = await service.openPrivacyPolicy();
      expect(ok, isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'openUri');
      expect(
        calls.single.arguments,
        {
          'uri': ExternalLinkService.privacyPolicyUrl,
        },
      );
      expect(
        ExternalLinkService.privacyPolicyUrl,
        'https://mahmoudmmaen-blip.github.io/brain-clean/privacy-policy/',
      );
    });

    test('openContactEmail uses mailto brainclean.app@gmail.com', () async {
      final service = ExternalLinkService(channel: channel);
      final ok = await service.openContactEmail();
      expect(ok, isTrue);
      expect(calls.single.arguments, {
        'uri': ExternalLinkService.contactEmailUri,
      });
      expect(
        ExternalLinkService.contactEmailUri,
        'mailto:brainclean.app@gmail.com',
      );
    });
  });
}
