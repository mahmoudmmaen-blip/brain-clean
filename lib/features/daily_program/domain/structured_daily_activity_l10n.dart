import '../../../core/l10n/app_localizations.dart';

/// Resolves a [StructuredDailyActivity.titleKey] to a localized title.
String resolveStructuredDailyActivityTitle(
  AppLocalizations loc,
  String titleKey,
) {
  return switch (titleKey) {
    'dailyProgramMindfulness' => loc.dailyProgramMindfulness,
    'dailyProgramPomodoro' => loc.dailyProgramPomodoro,
    'dailyProgramScreenFree' => loc.dailyProgramScreenFree,
    'dailyProgramReflection' => loc.dailyProgramReflection,
    'dailyProgramCognitive' => loc.dailyProgramCognitive,
    'dailyProgramHeavyPomodoro' => loc.dailyProgramHeavyPomodoro,
    'dailyProgramStroop' => loc.dailyProgramStroop,
    'dailyProgramNBack' => loc.dailyProgramNBack,
    'dailyProgramDigitSpan' => loc.dailyProgramDigitSpan,
    'dailyProgramNoMultitask' => loc.dailyProgramNoMultitask,
    'dailyProgramDetoxBlock' => loc.dailyProgramDetoxBlock,
    'dailyProgramAppUsageReview' => loc.dailyProgramAppUsageReview,
    'dailyProgramFullRecoveryBlock' => loc.dailyProgramFullRecoveryBlock,
    'dailyProgramHourlyPlan' => loc.dailyProgramHourlyPlan,
    'dailyProgramPersonalizedLocked' => loc.dailyProgramPersonalizedLocked,
    _ => titleKey,
  };
}
