import '../../../core/l10n/app_localizations.dart';

/// Resolves a [StructuredDailyActivity.titleKey] to a localized title.
String resolveStructuredDailyActivityTitle(
  AppLocalizations loc,
  String titleKey,
) {
  return switch (titleKey) {
    'dailyProgramReading' => loc.dailyProgramReading,
    'dailyProgramPomodoro' => loc.dailyProgramPomodoro,
    'dailyProgramScreenFree' => loc.dailyProgramScreenFree,
    'dailyProgramEveningReview' => loc.dailyProgramEveningReview,
    'dailyProgramCognitive' => loc.dailyProgramCognitive,
    'dailyProgramCognitiveNBack' => loc.dailyProgramCognitiveNBack,
    'dailyProgramCognitiveStroop' => loc.dailyProgramCognitiveStroop,
    'dailyProgramHeavyPomodoro' => loc.dailyProgramHeavyPomodoro,
    'dailyProgramStroop' => loc.dailyProgramStroop,
    'dailyProgramNBack' => loc.dailyProgramNBack,
    'dailyProgramDigitSpan' => loc.dailyProgramDigitSpan,
    'dailyProgramNoMultitask' => loc.dailyProgramNoMultitask,
    'dailyProgramSingleScreenRule' => loc.dailyProgramSingleScreenRule,
    'dailyProgramSearchWaitRule' => loc.dailyProgramSearchWaitRule,
    'dailyProgramDetoxBlock' => loc.dailyProgramDetoxBlock,
    'dailyProgramAppUsageReview' => loc.dailyProgramAppUsageReview,
    'dailyProgramFullRecoveryBlock' => loc.dailyProgramFullRecoveryBlock,
    'dailyProgramHourlyPlan' => loc.dailyProgramHourlyPlan,
    'dailyProgramPersonalizedLocked' => loc.dailyProgramPersonalizedLocked,
    'dailyProgramHourly07' => loc.dailyProgramHourly07,
    'dailyProgramHourly08' => loc.dailyProgramHourly08,
    'dailyProgramHourly09' => loc.dailyProgramHourly09,
    'dailyProgramHourly10' => loc.dailyProgramHourly10,
    'dailyProgramHourly11' => loc.dailyProgramHourly11,
    'dailyProgramHourly12' => loc.dailyProgramHourly12,
    'dailyProgramHourly13' => loc.dailyProgramHourly13,
    'dailyProgramHourly14' => loc.dailyProgramHourly14,
    'dailyProgramHourly15' => loc.dailyProgramHourly15,
    'dailyProgramHourly16' => loc.dailyProgramHourly16,
    'dailyProgramHourly17' => loc.dailyProgramHourly17,
    'dailyProgramHourly18' => loc.dailyProgramHourly18,
    'dailyProgramHourly19' => loc.dailyProgramHourly19,
    'dailyProgramHourly20' => loc.dailyProgramHourly20,
    'dailyProgramHourly21' => loc.dailyProgramHourly21,
    'dailyProgramHourly22' => loc.dailyProgramHourly22,
    // Legacy keys kept for older completion maps.
    'dailyProgramMindfulness' => loc.dailyProgramReading,
    'dailyProgramReflection' => loc.dailyProgramEveningReview,
    _ => titleKey,
  };
}
