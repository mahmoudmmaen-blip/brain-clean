import 'dart:convert';

import '../domain/ai_coach/ai_coach_dynamic_context.dart';
import '../domain/ai_coach/ai_coach_pipeline_prompt.dart';
import '../domain/ai_coach/ai_coach_pipeline_response.dart';
import 'detox_ai_coach_parser.dart';
import 'detox_ai_coach_prompts.dart';

/// Backend that completes the assembled prompt (LLM / edge function / stub).
abstract interface class DetoxAiCoachBackend {
  Future<String> complete({
    required String system,
    required String user,
  });
}

/// Local stub — returns strict JSON for offline/dev (matches pipeline schema).
class StubDetoxAiCoachBackend implements DetoxAiCoachBackend {
  @override
  Future<String> complete({
    required String system,
    required String user,
  }) async {
    final dynamicLayerStart = user.indexOf('{');
    final dynamicLayerEnd = user.lastIndexOf('}');
    if (dynamicLayerStart < 0 || dynamicLayerEnd < dynamicLayerStart) {
      return _clarifyJson(
        message: 'Could not read dynamic context.',
        questions: const ['Please retry your check-in.'],
      );
    }

    final dynamicJson = user.substring(dynamicLayerStart, dynamicLayerEnd + 1);
    final dynamicPayload = jsonDecode(dynamicJson) as Map<String, dynamic>;
    final variables = dynamicPayload['variables'];
    if (variables is! Map) {
      return _clarifyJson(
        message: 'Missing habit variables in context.',
        questions: const ['Which detox habit did you update?'],
      );
    }

    final detoxScore = variables['detoxHabitScore'];
    final bcScore = dynamicPayload['bcScore'];
    final locale = dynamicPayload['locale'] ?? 'ar';

    return _completeJson(
      message: locale == 'ar'
          ? 'أحسنت — واصل بروتوكول الديتوكس اليوم.'
          : 'Great work — keep your detox protocol momentum today.',
      intent: 'detox_check_in',
      action: 'continue_detox_protocol',
      assembledVariables: {
        'bcScore': bcScore,
        'locale': locale,
        'detoxHabitScore': detoxScore,
        'boredomBefriended': variables['boredomBefriended'],
        'delayedGratificationCount': variables['delayedGratificationCount'],
        'bodyActivated': variables['bodyActivated'],
      },
    );
  }

  String _completeJson({
    required String message,
    required String intent,
    required String action,
    required Map<String, Object?> assembledVariables,
  }) {
    return jsonEncode({
      'status': 'complete',
      'message': message,
      'context': {
        'intent': intent,
        'action': action,
        'assembledVariables': assembledVariables,
      },
    });
  }

  String _clarifyJson({
    required String message,
    required List<String> questions,
  }) {
    return jsonEncode({
      'status': 'clarify',
      'message': message,
      'questions': questions,
    });
  }
}

/// Assembles Static + Dynamic layers and fetches machine-readable coaching insights.
class DetoxAiCoachService {
  DetoxAiCoachService({DetoxAiCoachBackend? backend})
      : _backend = backend ?? StubDetoxAiCoachBackend();

  final DetoxAiCoachBackend _backend;

  /// Static Layer — immutable system instructions.
  String getStaticLayer() => DetoxAiCoachPrompts.systemPrompt;

  /// Dynamic Layer — per-request JSON payload (matches Node `buildDynamicLayer`).
  String buildDynamicLayer(AiCoachDynamicContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(context.toJson());
  }

  /// Full prompt: Static Layer + Dynamic Layer (matches Node `assemblePipelinePrompt`).
  AiCoachPipelinePrompt assemblePipelinePrompt(AiCoachDynamicContext context) {
    return AiCoachPipelinePrompt(
      system: getStaticLayer(),
      user: [
        '## DYNAMIC CONTEXT (injected — do not echo verbatim unless needed)',
        buildDynamicLayer(context),
        '',
        'Respond with ONLY the JSON object per the system instructions.',
      ].join('\n'),
    );
  }

  /// Strict parse + schema validation (no regex cleaning).
  AiCoachPipelineResponse processModelOutput(String rawModelOutput) {
    return DetoxAiCoachParser.parseAndValidateAiResponse(rawModelOutput);
  }

  /// Pre-LLM routing hint mirroring the Completion / Clarification boundary.
  String routingHint(AiCoachDynamicContext context) {
    final msg = context.userMessage.trim();
    if (msg.isEmpty) return 'clarify';

    final vague = RegExp(
      r'^(help|مساعدة|what should i do|ماذا أفعل)\.?$',
      caseSensitive: false,
    );
    if (vague.hasMatch(msg)) return 'clarify';

    final lapsePattern = RegExp(r'lapse|هفوة|slip|ذلة|relapse|انتكاس', caseSensitive: false);
    if (lapsePattern.hasMatch(msg) && !context.variables.containsKey('lapseType')) {
      return 'clarify';
    }

    final scorePattern = RegExp(r'score|نقاط|bc_score', caseSensitive: false);
    if (scorePattern.hasMatch(msg) && context.bcScore == null) {
      return 'clarify';
    }

    return 'complete';
  }

  /// Calls the backend and validates JSON-only output.
  Future<AiCoachPipelineResponse> fetchCoachingInsight(
    AiCoachDynamicContext context,
  ) async {
    try {
      final prompt = assemblePipelinePrompt(context);
      final raw = await _backend.complete(
        system: prompt.system,
        user: prompt.user,
      );
      return processModelOutput(raw);
    } catch (e) {
      throw DetoxAiCoachException(
        'Could not fetch AI coaching insight. Your check-in is still saved.',
      );
    }
  }
}

/// User-friendly failure — never surfaces raw parser/HTTP exceptions.
class DetoxAiCoachException implements Exception {
  DetoxAiCoachException(this.message);

  final String message;

  @override
  String toString() => message;
}
