import 'package:json_annotation/json_annotation.dart';

/// Chronic anxiety severity band derived from questionnaire score (0–100).
@JsonEnum(alwaysCreate: true)
enum AnxietyLevel {
  calm,
  moderate,
  high,
  severe,
}

extension AnxietyLevelScoring on AnxietyLevel {
  static AnxietyLevel fromScore(double score) {
    if (score <= 25) return AnxietyLevel.calm;
    if (score <= 50) return AnxietyLevel.moderate;
    if (score <= 75) return AnxietyLevel.high;
    return AnxietyLevel.severe;
  }
}
