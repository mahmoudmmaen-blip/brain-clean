/// Four BRI axes — higher score = more digital friction / brain rot.
enum BriAxis {
  shortFormAddiction,
  attentionScatter,
  infoFatigue,
  boredomResistance,
}

extension BriAxisX on BriAxis {
  String get titleKey => switch (this) {
        BriAxis.shortFormAddiction => 'briAxisShortForm',
        BriAxis.attentionScatter => 'briAxisAttention',
        BriAxis.infoFatigue => 'briAxisInfoFatigue',
        BriAxis.boredomResistance => 'briAxisBoredom',
      };
}

/// BRI overall band (higher BRI = worse).
enum BriBand {
  healthy, // 0–30
  mild, // 31–60
  moderate, // 61–85
  severe, // 86–100
}

BriBand briBandFor(int score) {
  if (score <= 30) return BriBand.healthy;
  if (score <= 60) return BriBand.mild;
  if (score <= 85) return BriBand.moderate;
  return BriBand.severe;
}
