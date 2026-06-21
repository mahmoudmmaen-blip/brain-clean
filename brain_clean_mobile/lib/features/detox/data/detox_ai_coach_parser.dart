import 'dart:convert';

import '../domain/ai_coach/ai_coach_pipeline_response.dart';

/// Strict JSON parsing — no regex extraction or markdown stripping.
abstract final class DetoxAiCoachParser {
  /// Parses raw model output with native [jsonDecode] only.
  static Object? parseAiResponse(String raw) {
    return jsonDecode(raw.trim());
  }

  /// Validates pipeline JSON shape after parse.
  static AiCoachPipelineResponse validatePipelineResponse(Object? parsed) {
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Response must be a JSON object');
    }

    final status = parsed['status'];
    if (status != 'complete' && status != 'clarify') {
      throw FormatException('Invalid status: $status');
    }

    final message = parsed['message'];
    if (message is! String || message.trim().isEmpty) {
      throw const FormatException('Missing or empty "message"');
    }

    if (status == 'complete') {
      final context = parsed['context'];
      if (context is! Map<String, dynamic>) {
        throw const FormatException('Completion requires "context" object');
      }
      final intent = context['intent'];
      final action = context['action'];
      final assembledVariables = context['assembledVariables'];
      if (intent is! String || intent.trim().isEmpty) {
        throw const FormatException('Completion requires context.intent');
      }
      if (action is! String || action.trim().isEmpty) {
        throw const FormatException('Completion requires context.action');
      }
      if (assembledVariables is! Map) {
        throw const FormatException(
          'Completion requires context.assembledVariables object',
        );
      }
      return AiCoachCompleteResponse(
        message: message,
        context: AiCoachCompleteContext(
          intent: intent,
          action: action,
          assembledVariables: Map<String, Object?>.from(assembledVariables),
        ),
      );
    }

    final questions = parsed['questions'];
    if (questions is! List || questions.isEmpty) {
      throw const FormatException(
        'Clarification requires non-empty "questions" array',
      );
    }
    final parsedQuestions = <String>[];
    for (final q in questions) {
      if (q is! String || q.trim().isEmpty) {
        throw const FormatException('Each question must be a non-empty string');
      }
      parsedQuestions.add(q);
    }
    return AiCoachClarifyResponse(
      message: message,
      questions: parsedQuestions,
    );
  }

  /// Parse + validate in one step (strict, no cleaning).
  static AiCoachPipelineResponse parseAndValidateAiResponse(String raw) {
    return validatePipelineResponse(parseAiResponse(raw));
  }
}
