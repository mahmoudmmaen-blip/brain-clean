import '../../../core/l10n/app_localizations.dart';
import '../domain/anxiety_dominant_type.dart';
import '../domain/anxiety_level.dart';
import 'safa_program_fallback.dart';

/// Local Safa program text when NVIDIA AI is unavailable.
String safaProgramFallbackForLevel(AppLocalizations loc, AnxietyLevel level) {
  return switch (level) {
    AnxietyLevel.calm => loc.safaProgramFallbackCalm,
    AnxietyLevel.moderate => loc.safaProgramFallbackModerate,
    AnxietyLevel.high => loc.safaProgramFallbackHigh,
    AnxietyLevel.severe => loc.safaProgramFallbackSevere,
  };
}

String buildSafaAnxietyUserMessage({
  required double score,
  required String levelLabel,
  required AnxietyDominantType dominantType,
}) {
  return '''
المستخدم أكمل اختبار القلق المزمن.
نسبة القلق: ${score.round()}% — مستوى: $levelLabel.
النوع الغالب: ${dominantTypeArabicLabel(dominantType)}.
اكتب له برنامج مخصص مختصر (4 جمل) يذكر:
1. تشجيع بناءً على نوع قلقه
2. أهم عادة تناسبه من البرنامج (دفتر القلق / نافذة القلق / حركة / تغذية)
3. دور صفا في المتابعة
4. جملة ختامية محفّزة
''';
}

const safaAnxietySystemPrompt = '''
أنت صفا، المساعد الذهني في تطبيق Brain Clean. ردّك دائماً بالعربية، لطيف ومشجّع،
لا تتجاوز 4 جمل. لا تقدّم نصائح طبية.
''';
