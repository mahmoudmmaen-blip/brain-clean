import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/services/claude_ai_service.dart';
import 'package:brain_clean_mobile/core/services/claude_ai_service_provider.dart';
import 'package:brain_clean_mobile/features/pro_modules/presentation/screens/emotion_oasis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/localized_test_app.dart';
import '../../helpers/subscription_test_overrides.dart';

void main() {
  setUp(() {
    ClaudeAiService.lastDebugDiagnostic = null;
  });

  group('ClaudeAiService', () {
    test('returns success reply from safa-chat', () async {
      final service = ClaudeAiService(
        supabaseConfigured: true,
        supabaseInitialized: true,
        invoker: ({required functionName, required body}) async {
          expect(functionName, ClaudeAiService.functionName);
          expect(functionName, 'safa-chat');
          expect(body.containsKey('message'), isTrue);
          return FunctionResponse(
            data: {'reply': 'أنا معاكي، خدي نفس عميق.'},
            status: 200,
          );
        },
      );

      final outcome = await service.send('أشعر بالقلق');
      expect(outcome.isSuccess, isTrue);
      expect(outcome.reply, 'أنا معاكي، خدي نفس عميق.');
      expect(outcome.failure, isNull);
    });

    test('missing configuration fails without invoking', () async {
      var invoked = false;
      final service = ClaudeAiService(
        supabaseConfigured: false,
        supabaseInitialized: true,
        invoker: ({required functionName, required body}) async {
          invoked = true;
          return FunctionResponse(data: {'reply': 'x'}, status: 200);
        },
      );

      final outcome = await service.send('hello');
      expect(invoked, isFalse);
      expect(outcome.isSuccess, isFalse);
      expect(outcome.failure, SafaChatFailureKind.missingConfig);
      expect(
        ClaudeAiService.lastDebugDiagnostic,
        allOf(
          contains('missingConfig'),
          contains('safa-chat'),
          isNot(contains('hello')),
        ),
      );
    });

    test('timeout is classified and flagged', () async {
      final service = ClaudeAiService(
        supabaseConfigured: true,
        supabaseInitialized: true,
        timeout: const Duration(milliseconds: 20),
        invoker: ({required functionName, required body}) async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          return FunctionResponse(data: {'reply': 'late'}, status: 200);
        },
      );

      final outcome = await service.send('secret user text');
      expect(outcome.failure, SafaChatFailureKind.timeout);
      expect(outcome.timedOut, isTrue);
      expect(ClaudeAiService.lastDebugDiagnostic, contains('timedOut=true'));
      expect(
        ClaudeAiService.lastDebugDiagnostic,
        isNot(contains('secret user text')),
      );
    });

    test('server error status is classified', () async {
      final service = ClaudeAiService(
        supabaseConfigured: true,
        supabaseInitialized: true,
        invoker: ({required functionName, required body}) async {
          throw const FunctionException(status: 500, reasonPhrase: 'fail');
        },
      );

      final outcome = await service.send('msg');
      expect(outcome.failure, SafaChatFailureKind.serverError);
      expect(outcome.httpStatus, 500);
      expect(ClaudeAiService.lastDebugDiagnostic, contains('httpStatus=500'));
    });

    test('malformed response is classified', () async {
      final service = ClaudeAiService(
        supabaseConfigured: true,
        supabaseInitialized: true,
        invoker: ({required functionName, required body}) async {
          return FunctionResponse(data: 'not-a-map', status: 200);
        },
      );

      final outcome = await service.send('msg');
      expect(outcome.failure, SafaChatFailureKind.malformedResponse);
    });

    test('null reply from edge is emptyReply', () async {
      final service = ClaudeAiService(
        supabaseConfigured: true,
        supabaseInitialized: true,
        invoker: ({required functionName, required body}) async {
          return FunctionResponse(data: {'reply': null}, status: 200);
        },
      );

      final outcome = await service.send('msg');
      expect(outcome.failure, SafaChatFailureKind.emptyReply);
    });

    test('debug diagnostic never includes message or secrets', () async {
      const userMessage = 'PRIVATE_USER_MESSAGE_XYZ';
      const fakeKey = 'sk-ant-super-secret-key';
      final service = ClaudeAiService(
        supabaseConfigured: true,
        supabaseInitialized: true,
        invoker: ({required functionName, required body}) async {
          throw Exception('auth $fakeKey failed for $userMessage');
        },
      );

      await service.send(userMessage);
      final log = ClaudeAiService.lastDebugDiagnostic ?? '';
      expect(log, isNot(contains(userMessage)));
      expect(log, isNot(contains(fakeKey)));
      expect(log, isNot(contains('Authorization')));
      expect(log, contains('function=safa-chat'));
      expect(log, contains('kind='));
    });

    test('chat() returns null on failure', () async {
      final service = ClaudeAiService(
        supabaseConfigured: false,
        supabaseInitialized: false,
      );
      expect(await service.chat('x'), isNull);
    });
  });

  group('Safa localized unavailable copy', () {
    testWidgets('shows Arabic friendly error on failure', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const EmotionOasisScreen(),
          locale: const Locale('ar'),
          overrides: [
            localSubscriptionTestOverride(),
            claudeAiServiceProvider.overrideWith(
              (ref) => ClaudeAiService(
                supabaseConfigured: false,
                supabaseInitialized: false,
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'أشعر بالقلق');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'صفا غير متاحة مؤقتًا. تحقق من اتصالك وحاول مرة أخرى بعد قليل.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('أنا هنا معاكي'), findsNothing);
    });

    testWidgets('shows English friendly error on failure', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const EmotionOasisScreen(),
          locale: const Locale('en'),
          overrides: [
            localSubscriptionTestOverride(),
            claudeAiServiceProvider.overrideWith(
              (ref) => ClaudeAiService(
                supabaseConfigured: false,
                supabaseInitialized: false,
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'I feel anxious');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Safa is temporarily unavailable. Check your connection and try again shortly.',
        ),
        findsOneWidget,
      );
    });

    test('l10n strings match product copy', () {
      // Compiled getters are covered via widget tests; keep arb contract here.
      expect(
        AppLocalizationsEn().safaTemporarilyUnavailable,
        'Safa is temporarily unavailable. Check your connection and try again shortly.',
      );
      expect(
        AppLocalizationsAr().safaTemporarilyUnavailable,
        'صفا غير متاحة مؤقتًا. تحقق من اتصالك وحاول مرة أخرى بعد قليل.',
      );
    });
  });
}
