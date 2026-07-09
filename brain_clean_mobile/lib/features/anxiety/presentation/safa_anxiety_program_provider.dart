import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/services/nvidia_ai_service.dart';
import '../domain/anxiety_dominant_type.dart';
import '../domain/anxiety_result.dart';
import '../domain/safa_anxiety_program.dart';
import '../domain/safa_program_fallback.dart';

part 'safa_anxiety_program_provider.g.dart';

@riverpod
Future<String> safaAnxietyProgram(
  SafaAnxietyProgramRef ref,
  AnxietyResult result,
) async {
  final isArabic = ref.read(localeProvider).languageCode == 'ar';
  final dominant = detectDominantAnxietyType(result.answers);

  final ai = await ref.read(nvidiaAiServiceProvider).chat(
        systemPrompt: safaAnxietySystemPrompt,
        userMessage: buildSafaAnxietyUserMessage(
          score: result.score,
          levelLabel: anxietyLevelArabicLabel(result.level),
          dominantType: dominant,
        ),
      );

  if (ai != null && ai.isNotEmpty) return ai;

  return isArabic
      ? safaProgramFallbackArabic(result.level)
      : safaProgramFallbackEnglish(result.level);
}
