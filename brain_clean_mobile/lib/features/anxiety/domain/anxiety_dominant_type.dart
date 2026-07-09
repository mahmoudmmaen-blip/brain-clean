/// Dominant anxiety pattern detected from questionnaire answers.
enum AnxietyDominantType {
  nightWorry,
  rumination,
  catastrophizing,
  physical,
}

/// Detects the dominant anxiety type from 8 answers (0–3 each).
///
/// Rules: night Q1≥2, rumination avg(Q2,Q4)≥2, catastrophizing Q3≥2, physical Q6≥2.
/// If multiple qualify, highest metric wins. Default: [rumination].
AnxietyDominantType detectDominantAnxietyType(List<int> answers) {
  if (answers.length != 8) return AnxietyDominantType.rumination;

  final candidates = <AnxietyDominantType, double>{};

  if (answers[0] >= 2) {
    candidates[AnxietyDominantType.nightWorry] = answers[0].toDouble();
  }
  final ruminationAvg = (answers[1] + answers[3]) / 2;
  if (ruminationAvg >= 2) {
    candidates[AnxietyDominantType.rumination] = ruminationAvg;
  }
  if (answers[2] >= 2) {
    candidates[AnxietyDominantType.catastrophizing] = answers[2].toDouble();
  }
  if (answers[5] >= 2) {
    candidates[AnxietyDominantType.physical] = answers[5].toDouble();
  }

  if (candidates.isEmpty) return AnxietyDominantType.rumination;

  return candidates.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

String dominantTypeArabicLabel(AnxietyDominantType type) {
  return switch (type) {
    AnxietyDominantType.nightWorry => 'ليلي',
    AnxietyDominantType.rumination => 'اجترار',
    AnxietyDominantType.catastrophizing => 'توقع',
    AnxietyDominantType.physical => 'جسدي',
  };
}
