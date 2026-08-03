/// Allowed SafaResponse.responseType values (Contract §9.2).
enum SafaResponseType {
  clarification,
  encouragement,
  grounding,
  stepSimplification,
  restartSupport,
  limitedEvidenceExplanation,
  unavailableFallback,
  safetyRedirect,
}

extension SafaResponseTypeX on SafaResponseType {
  String get wireId => switch (this) {
        SafaResponseType.clarification => 'clarification',
        SafaResponseType.encouragement => 'encouragement',
        SafaResponseType.grounding => 'grounding',
        SafaResponseType.stepSimplification => 'step_simplification',
        SafaResponseType.restartSupport => 'restart_support',
        SafaResponseType.limitedEvidenceExplanation =>
          'limited_evidence_explanation',
        SafaResponseType.unavailableFallback => 'unavailable_fallback',
        SafaResponseType.safetyRedirect => 'safety_redirect',
      };

  static SafaResponseType? tryParse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'clarification':
        return SafaResponseType.clarification;
      case 'encouragement':
        return SafaResponseType.encouragement;
      case 'grounding':
        return SafaResponseType.grounding;
      case 'step_simplification':
        return SafaResponseType.stepSimplification;
      case 'restart_support':
        return SafaResponseType.restartSupport;
      case 'limited_evidence_explanation':
        return SafaResponseType.limitedEvidenceExplanation;
      case 'unavailable_fallback':
        return SafaResponseType.unavailableFallback;
      case 'safety_redirect':
        return SafaResponseType.safetyRedirect;
      default:
        return null;
    }
  }
}
