/// Machine-readable AI coach pipeline response (strict JSON schema).
sealed class AiCoachPipelineResponse {
  const AiCoachPipelineResponse({
    required this.message,
  });

  final String message;

  String get status;
}

/// Completion — context is self-contained and ready for execution.
class AiCoachCompleteResponse extends AiCoachPipelineResponse {
  const AiCoachCompleteResponse({
    required super.message,
    required this.context,
  });

  @override
  String get status => 'complete';

  final AiCoachCompleteContext context;
}

class AiCoachCompleteContext {
  const AiCoachCompleteContext({
    required this.intent,
    required this.action,
    required this.assembledVariables,
  });

  final String intent;
  final String action;
  final Map<String, Object?> assembledVariables;
}

/// Clarification — vital intent or variables are missing.
class AiCoachClarifyResponse extends AiCoachPipelineResponse {
  const AiCoachClarifyResponse({
    required super.message,
    required this.questions,
  });

  @override
  String get status => 'clarify';

  final List<String> questions;
}
