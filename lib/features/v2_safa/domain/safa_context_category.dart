/// Optional user-selected context chip — never preselected (Contract §7 / §8).
enum SafaContextCategory {
  none,
  difficultMoment,
  clarifyStep,
  continueSupport,
  limitedEvidence,
}

extension SafaContextCategoryX on SafaContextCategory {
  String? get wireId => switch (this) {
        SafaContextCategory.none => null,
        SafaContextCategory.difficultMoment => 'difficult_moment',
        SafaContextCategory.clarifyStep => 'clarify_step',
        SafaContextCategory.continueSupport => 'continue_support',
        SafaContextCategory.limitedEvidence => 'limited_evidence',
      };

  static SafaContextCategory parse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'difficult_moment':
        return SafaContextCategory.difficultMoment;
      case 'clarify_step':
        return SafaContextCategory.clarifyStep;
      case 'continue_support':
        return SafaContextCategory.continueSupport;
      case 'limited_evidence':
        return SafaContextCategory.limitedEvidence;
      default:
        return SafaContextCategory.none;
    }
  }
}
