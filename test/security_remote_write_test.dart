import 'dart:io';

import 'package:brain_clean_mobile/core/security/authenticated_session.dart';
import 'package:brain_clean_mobile/core/security/secure_remote_write.dart';
import 'package:brain_clean_mobile/core/security/secure_write_policy.dart';
import 'package:brain_clean_mobile/core/services/claude_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticatedSession', () {
    final now = DateTime.utc(2026, 8, 18, 12);

    test('rejects empty token, empty user, or missing expiry', () {
      expect(
        AuthenticatedSession.isAccessTokenLive(
          accessToken: '',
          userId: 'u1',
          expiresAtEpochSeconds: 9999999999,
          now: now,
        ),
        isFalse,
      );
      expect(
        AuthenticatedSession.isAccessTokenLive(
          accessToken: 'jwt',
          userId: '',
          expiresAtEpochSeconds: 9999999999,
          now: now,
        ),
        isFalse,
      );
      expect(
        AuthenticatedSession.isAccessTokenLive(
          accessToken: 'jwt',
          userId: 'u1',
          expiresAtEpochSeconds: null,
          now: now,
        ),
        isFalse,
      );
    });

    test('rejects tokens inside the 30s skew window', () {
      final almostGone = now.add(const Duration(seconds: 10)).millisecondsSinceEpoch ~/
          1000;
      expect(
        AuthenticatedSession.isAccessTokenLive(
          accessToken: 'jwt',
          userId: 'u1',
          expiresAtEpochSeconds: almostGone,
          now: now,
        ),
        isFalse,
      );
    });

    test('accepts a token with remaining lifetime', () {
      final later = now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;
      expect(
        AuthenticatedSession.isAccessTokenLive(
          accessToken: 'jwt',
          userId: 'u1',
          expiresAtEpochSeconds: later,
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('SecureWritePolicy covers 30 modules', () {
    test('local + jwt-gated modules total 30 unique names', () {
      final all = <String>{
        ...SecureWritePolicy.localOnlyModules,
        ...SecureWritePolicy.jwtGatedModules.keys,
      };
      expect(all.length, 30);
      expect(
        SecureWritePolicy.requiredFunction('gamification'),
        'verify-xp',
      );
      expect(
        SecureWritePolicy.requiredFunction('user_progress'),
        'write-user-state',
      );
      expect(
        SecureWritePolicy.requiredFunction('v2_safa'),
        'safa-chat',
      );
      expect(SecureWritePolicy.isLocalOnly('weekly_review'), isTrue);
    });
  });

  group('Secrets stay off the client', () {
    test('Dart lib has no NVIDIA / Claude / nvapi provider keys', () {
      final hits = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final text = entity.readAsStringSync();
        if (RegExp(
          r'nvapi-|nvidia\.com|sk-ant-|CLAUDE_API_KEY\s*=',
          caseSensitive: false,
        ).hasMatch(text)) {
          hits.add(entity.path);
        }
      }
      expect(hits, isEmpty);
    });

    test('safa-chat reads CLAUDE_API_KEY from Deno.env only', () {
      final src =
          File('supabase/functions/safa-chat/index.ts').readAsStringSync();
      expect(src, contains('Deno.env.get("CLAUDE_API_KEY")'));
      expect(src, contains('requireAuthenticatedUser'));
      expect(src.toLowerCase(), isNot(contains('nvidia')));
      expect(src, isNot(contains('nvapi-')));
    });

    test('verify-xp and write-user-state require JWT', () {
      final xp =
          File('supabase/functions/verify-xp/index.ts').readAsStringSync();
      final write =
          File('supabase/functions/write-user-state/index.ts').readAsStringSync();
      expect(xp, contains('requireAuthenticatedUser'));
      expect(write, contains('requireAuthenticatedUser'));
      expect(write, contains('user_id: caller.userId'));
      expect(File('lib/features/diagnostic/data/diagnostic_repository.dart')
          .readAsStringSync(), contains('SecureRemoteWrite'));
      expect(File('lib/features/detox/data/detox_protocol_repository.dart')
          .readAsStringSync(), contains('SecureRemoteWrite'));
      expect(File('lib/core/services/cloud_sync_service.dart').readAsStringSync(),
          contains('SecureRemoteWrite'));
      expect(File('lib/features/gamification/data/xp_sync_api.dart')
          .readAsStringSync(), contains('verify-xp'));
    });

    test('legacy Cloudflare worker no longer proxies Anthropic', () {
      final src = File('worker/index.js').readAsStringSync();
      expect(src, contains('410'));
      expect(src, isNot(contains('ANTHROPIC_API_KEY')));
      expect(src, isNot(contains('api.anthropic.com')));
    });
  });
}
