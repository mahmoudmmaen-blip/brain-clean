/// Visual / navigation kind for a structured daily activity.
enum DailyProgramActivityKind {
  reading,
  pomodoro,
  screenFree,
  cognitiveNBack,
  cognitiveStroop,
  cognitiveDigitSpan,
  iqChallenge,
  eveningReview,
  rule,
  physical,
  nsdr,
  whiteNoise,
  other,
}

/// Maps activity id / titleKey → interaction kind.
DailyProgramActivityKind resolveDailyProgramActivityKind({
  required String id,
  required String titleKey,
}) {
  if (id.contains('reading') ||
      titleKey == 'dailyProgramReading' ||
      titleKey == 'dailyProgramActiveRecallReading') {
    return DailyProgramActivityKind.reading;
  }
  if (id.contains('pomodoro') ||
      titleKey == 'dailyProgramPomodoro' ||
      titleKey == 'dailyProgramPomodoro5010' ||
      titleKey == 'dailyProgramHeavyPomodoro' ||
      titleKey == 'dailyProgramRecovery0900') {
    return DailyProgramActivityKind.pomodoro;
  }
  if (id.contains('screen_free') ||
      id.contains('detox') ||
      id.contains('grayscale') ||
      id.contains('zero_screens') ||
      titleKey == 'dailyProgramScreenFree' ||
      titleKey == 'dailyProgramDetoxBlock' ||
      titleKey == 'dailyProgramMorningZeroScreens' ||
      titleKey == 'dailyProgramGrayscaleMode' ||
      titleKey == 'dailyProgramRecovery0700' ||
      titleKey == 'dailyProgramRecovery2100') {
    return DailyProgramActivityKind.screenFree;
  }
  if (titleKey == 'dailyProgramIqChallenge' || id.contains('iq_challenge')) {
    return DailyProgramActivityKind.iqChallenge;
  }
  if (titleKey == 'dailyProgramDigitSpan' || id.contains('digit_span')) {
    return DailyProgramActivityKind.cognitiveDigitSpan;
  }
  if (titleKey == 'dailyProgramCognitiveNBack' ||
      titleKey == 'dailyProgramNBack' ||
      id.contains('nback')) {
    return DailyProgramActivityKind.cognitiveNBack;
  }
  if (titleKey == 'dailyProgramCognitiveStroop' ||
      titleKey == 'dailyProgramStroop' ||
      id.contains('stroop')) {
    return DailyProgramActivityKind.cognitiveStroop;
  }
  if (id.contains('evening') ||
      titleKey == 'dailyProgramEveningReview' ||
      titleKey == 'dailyProgramReflection') {
    return DailyProgramActivityKind.eveningReview;
  }
  if (titleKey == 'dailyProgramPhysicalExercise' ||
      id.contains('physical')) {
    return DailyProgramActivityKind.physical;
  }
  if (titleKey == 'dailyProgramNsdrRest' ||
      id.contains('nsdr') ||
      titleKey == 'dailyProgramRecovery1200') {
    return DailyProgramActivityKind.nsdr;
  }
  if (titleKey == 'dailyProgramWhiteNoise' || id.contains('white_noise')) {
    return DailyProgramActivityKind.whiteNoise;
  }
  if (titleKey == 'adaptiveProgramBreathing' || id.contains('breathing')) {
    return DailyProgramActivityKind.nsdr;
  }
  if (titleKey == 'adaptiveProgramWeekendChallenge' ||
      id.contains('weekend')) {
    return DailyProgramActivityKind.other;
  }
  if (titleKey == 'dailyProgramNoMultitask' ||
      titleKey == 'dailyProgramSingleScreenRule' ||
      titleKey == 'dailyProgramSearchWaitRule') {
    return DailyProgramActivityKind.rule;
  }
  return DailyProgramActivityKind.other;
}
