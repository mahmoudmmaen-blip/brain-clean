import '../../daily_program/domain/adaptive_program_engine.dart';
import '../../daily_program/domain/adaptive_program_protocol.dart';
import '../../daily_program/domain/daily_program_personalization.dart';
import 'bri_result.dart';

/// Recommended adaptive track after BRI (and optional cognitive scores).
class BriProgramRecommendation {
  const BriProgramRecommendation({
    required this.protocol,
    required this.titleKey,
    required this.descriptionKey,
    required this.isProRequired,
  });

  final AdaptiveProgramProtocol protocol;
  final String titleKey;
  final String descriptionKey;
  final bool isProRequired;
}

/// Maps BRI (+ optional cognition) → program recommendation for result UI.
abstract final class BriProgramRecommender {
  static BriProgramRecommendation recommend({
    required BriResult bri,
    required bool isPro,
    int memoryScore = 55,
    int focusScore = 55,
    int iqScore = 55,
    bool hasCognitiveTests = false,
  }) {
    final coverage = DailyProgramTestCoverage(
      hasFocus: hasCognitiveTests,
      hasMemory: hasCognitiveTests,
      hasIntelligence: hasCognitiveTests,
      hasDigitalAddiction: true,
      attentionScore: focusScore,
      memoryScore: memoryScore,
      iqScore: iqScore,
      digitalAddictionScore: bri.overallScore,
    );

    final protocol = AdaptiveProgramEngine.resolveProtocol(
      coverage: coverage,
      isPro: isPro,
    );

    final needsPro = !isPro &&
        AdaptiveProgramEngine.needsAscensionPro(coverage);

    return switch (protocol) {
      AdaptiveProgramProtocol.resetProtocol => BriProgramRecommendation(
          protocol: protocol,
          titleKey: 'adaptiveProgramResetTitle',
          descriptionKey: 'briRecommendResetBody',
          isProRequired: false,
        ),
      AdaptiveProgramProtocol.neuralAscension => BriProgramRecommendation(
          protocol: protocol,
          titleKey: 'adaptiveProgramAscensionTitle',
          descriptionKey: 'briRecommendAscensionBody',
          isProRequired: needsPro || !isPro,
        ),
      AdaptiveProgramProtocol.enhancedMind => BriProgramRecommendation(
          protocol: protocol,
          titleKey: 'adaptiveProgramEnhancedMindTitle',
          descriptionKey: 'briRecommendEnhancedBody',
          isProRequired: needsPro || !isPro,
        ),
      AdaptiveProgramProtocol.base => BriProgramRecommendation(
          protocol: protocol,
          titleKey: 'adaptiveProgramBaseTitle',
          descriptionKey: 'briRecommendBaseBody',
          isProRequired: false,
        ),
    };
  }
}
