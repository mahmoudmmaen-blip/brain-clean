/// Assembled Static + Dynamic layers ready for an LLM provider.
class AiCoachPipelinePrompt {
  const AiCoachPipelinePrompt({
    required this.system,
    required this.user,
  });

  /// Static Layer — immutable system instructions.
  final String system;

  /// Dynamic Layer — injected context + response directive.
  final String user;
}
