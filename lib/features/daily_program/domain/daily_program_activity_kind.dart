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
  other,
}

/// Maps activity id / titleKey → interaction kind.
DailyProgramActivityKind resolveDailyProgramActivityKind({
  required String id,
  required String titleKey,
}) {
  if (id.contains('reading') || titleKey == 'dailyProgramReading') {
    return DailyProgramActivityKind.reading;
  }
  if (id.contains('pomodoro') ||
      titleKey == 'dailyProgramPomodoro' ||
      titleKey == 'dailyProgramHeavyPomodoro') {
    return DailyProgramActivityKind.pomodoro;
  }
  if (id.contains('screen_free') ||
      id.contains('detox') ||
      titleKey == 'dailyProgramScreenFree' ||
      titleKey == 'dailyProgramDetoxBlock') {
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
  if (titleKey == 'dailyProgramNoMultitask' ||
      titleKey == 'dailyProgramSingleScreenRule' ||
      titleKey == 'dailyProgramSearchWaitRule') {
    return DailyProgramActivityKind.rule;
  }
  return DailyProgramActivityKind.other;
}
