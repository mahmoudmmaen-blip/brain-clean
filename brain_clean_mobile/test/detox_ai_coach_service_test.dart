import 'dart:convert';

import 'package:brain_clean_mobile/features/detox/data/detox_ai_coach_parser.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_ai_coach_prompts.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_ai_coach_service.dart';
import 'package:brain_clean_mobile/features/detox/domain/ai_coach/ai_coach_dynamic_context.dart';
import 'package:brain_clean_mobile/features/detox/domain/ai_coach/ai_coach_pipeline_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DetoxAiCoachService service;

  setUp(() {
    service = DetoxAiCoachService();
  });

  group('DetoxAiCoachService — Static Layer', () {
    test('getStaticLayer matches documented JSON-only rule', () {
      expect(
        service.getStaticLayer(),
        DetoxAiCoachPrompts.systemPrompt,
      );
      expect(service.getStaticLayer(), contains('Return ONLY a valid JSON object'));
      expect(service.getStaticLayer(), contains('Failure to comply breaks the parser'));
    });
  });

  group('DetoxAiCoachService — Dynamic Layer', () {
    test('buildDynamicLayer mirrors Node pipeline payload keys', () {
      final json = service.buildDynamicLayer(
        AiCoachDynamicContext(
          userMessage: 'Daily detox check-in saved',
          locale: 'en',
          bcScore: 72,
          streakDays: 4,
          variables: const {'detoxHabitScore': 55.0},
          timestamp: DateTime.utc(2026, 5, 26, 12, 0),
        ),
      );

      final parsed = jsonDecode(json) as Map<String, dynamic>;
      expect(parsed['userMessage'], 'Daily detox check-in saved');
      expect(parsed['locale'], 'en');
      expect(parsed['bcScore'], 72);
      expect(parsed['streakDays'], 4);
      expect(parsed['history'], isA<List<dynamic>>());
      expect(parsed['variables'], isA<Map<String, dynamic>>());
      expect(parsed['timestamp'], '2026-05-26T12:00:00.000Z');
    });
  });

  group('DetoxAiCoachService — assemblePipelinePrompt', () {
    test('combines static and dynamic layers as documented', () {
      final prompt = service.assemblePipelinePrompt(
        const AiCoachDynamicContext(
          userMessage: 'Log detox check-in',
          bcScore: 65,
        ),
      );

      expect(prompt.system, DetoxAiCoachPrompts.systemPrompt);
      expect(prompt.user, startsWith('## DYNAMIC CONTEXT'));
      expect(prompt.user, contains('"bcScore": 65'));
      expect(
        prompt.user,
        endsWith('Respond with ONLY the JSON object per the system instructions.'),
      );
    });
  });

  group('DetoxAiCoachService — strict JSON gatekeeping', () {
    test('processModelOutput parses completion without cleaning', () {
      const raw = '''
{"status":"complete","message":"Keep going.","context":{"intent":"detox_check_in","action":"continue","assembledVariables":{"bcScore":70}}}''';

      final result = service.processModelOutput(raw);
      expect(result, isA<AiCoachCompleteResponse>());
      expect(result.status, 'complete');
      final complete = result as AiCoachCompleteResponse;
      expect(complete.context.intent, 'detox_check_in');
      expect(complete.context.assembledVariables['bcScore'], 70);
    });

    test('processModelOutput rejects markdown fences', () {
      const raw = '```json\n{"status":"complete","message":"x","context":{"intent":"a","action":"b","assembledVariables":{}}}\n```';
      expect(
        () => DetoxAiCoachParser.parseAndValidateAiResponse(raw),
        throwsFormatException,
      );
    });

    test('fetchCoachingInsight returns complete response via stub backend', () async {
      final insight = await service.fetchCoachingInsight(
        const AiCoachDynamicContext(
          userMessage: 'Daily detox check-in saved',
          locale: 'en',
          bcScore: 80,
          variables: {
            'boredomBefriended': true,
            'delayedGratificationCount': 1,
            'bodyActivated': false,
            'detoxHabitScore': 45.0,
          },
        ),
      );

      expect(insight, isA<AiCoachCompleteResponse>());
      expect(insight.status, 'complete');
      expect(insight.message, isNotEmpty);
    });
  });

  group('DetoxAiCoachService — routingHint', () {
    test('returns clarify for vague intent', () {
      expect(
        service.routingHint(const AiCoachDynamicContext(userMessage: 'help')),
        'clarify',
      );
    });

    test('returns complete for detox check-in context', () {
      expect(
        service.routingHint(
          const AiCoachDynamicContext(
            userMessage: 'Daily detox check-in saved',
            bcScore: 72,
          ),
        ),
        'complete',
      );
    });
  });
}
