// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Diagnostic BC Score';

  @override
  String get dashboardEmptyDiagnosticPrompt =>
      'Complete the diagnostic to see your BC_score.';

  @override
  String get dashboardEmptyTitle => 'Start your journey!';

  @override
  String get dashboardEmptySubtitle =>
      'Take your first BCI test to see your progress here';

  @override
  String get dashboardEmptyCta => 'Start Test';

  @override
  String get dashboardRetakeDiagnostic => 'Retake Diagnostic';

  @override
  String get dashboardOpenDetoxCheckIn => '7-Day Detox Check-in';

  @override
  String get dashboardOpenDetoxCheckInSubtitle =>
      'Log daily habits and boost your live BC_score';

  @override
  String dashboardCommittedAt(String date) {
    return 'Committed $date';
  }

  @override
  String get diagnosticTitle => 'Diagnostic 6-Point Test';

  @override
  String get diagnosticLiveSubtitle => 'Live · updates on every slider move';

  @override
  String get diagnosticInstructions =>
      'Rate each dimension from 1 (low) to 10 (high).';

  @override
  String get diagnosticStart => 'Start Brain Clean';

  @override
  String get diagnosticSleepQuality => 'Sleep Quality';

  @override
  String get diagnosticSustainedAttention => 'Sustained Attention';

  @override
  String get diagnosticFragmentation => 'Fragmentation';

  @override
  String get diagnosticDopamineSeeking => 'Dopamine Seeking';

  @override
  String get diagnosticTaskSwitching => 'Task Switching';

  @override
  String get diagnosticBurnout => 'Burnout';

  @override
  String get bcScoreHeroLabel => 'BRAIN CLARITY SCORE';

  @override
  String get bcScoreBreakdownTitle => 'BHI · BC_score breakdown';

  @override
  String get bcScorePillarBrainPerformance => 'Brain performance';

  @override
  String get bcScorePillarDigitalDiscipline => 'Digital discipline';

  @override
  String get bcScorePillarHealthyHabits => 'Healthy habits';

  @override
  String get bcScorePillarConsistency => 'Consistency';

  @override
  String get bcScoreLabel => 'BC_score';

  @override
  String get accountabilityAdjustment => 'ACCOUNTABILITY ADJUSTMENT';

  @override
  String get bhiScoreLabel => 'Base BHI score';

  @override
  String get finalBcScoreLabel => 'Final BC_score';

  @override
  String accountabilityDeduction(int deduction) {
    return 'Recovery accountability (−$deduction)';
  }

  @override
  String get detoxTitle => '7-Day Dopamine Detox';

  @override
  String get detoxSubtitle => 'Daily check-in';

  @override
  String get detoxLiveBcScoreTitle => 'Live BC_score';

  @override
  String get detoxLiveBcScoreSubtitle => 'Updates instantly as you log habits';

  @override
  String get detoxBoredomTitle => 'Boredom Befriended';

  @override
  String get detoxBoredomSubtitle =>
      'Sat with boredom without reaching for a screen';

  @override
  String get detoxDelayedTitle => 'Delayed Gratification';

  @override
  String detoxDelayedSubtitle(int max) {
    return 'Wins today (capped at $max)';
  }

  @override
  String get detoxBodyTitle => 'Body Activated';

  @override
  String get detoxBodySubtitle => 'Morning sun + cold shower completed';

  @override
  String detoxCount(int count) {
    return '$count';
  }

  @override
  String get detoxIncrement => 'Increase';

  @override
  String get detoxDecrement => 'Decrease';

  @override
  String get detoxReset => 'Reset today';

  @override
  String get detoxRetry => 'Retry';

  @override
  String get detoxSyncing => 'Syncing…';

  @override
  String get detoxSyncError =>
      'Could not sync. Your check-in is saved locally.';

  @override
  String get diagnosticBrainRotTitle => 'Brain Rot Test';

  @override
  String get diagnosticBhiTitle => 'BHI 6-Point Assessment';

  @override
  String get diagnosticYes => 'Yes';

  @override
  String get diagnosticNo => 'No';

  @override
  String get diagnosticPreviousQuestion => 'Previous question';

  @override
  String diagnosticBrainRotProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get diagnosticBrainRotScoreTitle => 'Brain Rot Score';

  @override
  String diagnosticBrainRotScoreOutOf(int max) {
    return 'out of $max';
  }

  @override
  String diagnosticBrainRotBandRange(int min, int max) {
    return 'Severity band: $min–$max';
  }

  @override
  String get diagnosticBrainRotInterpretationTitle => 'Clinical interpretation';

  @override
  String get diagnosticContinueToBhi => 'Continue to BHI assessment';

  @override
  String get diagnosticReviewAnswers => 'Review my answers';

  @override
  String get diagnosticBrainRotIncomplete => 'Complete all 10 questions first.';

  @override
  String get diagnosticBrainRotScoring => 'Calculating your Brain Rot score…';

  @override
  String get diagnosticSyncError =>
      'Could not save your diagnostic. Please try again.';

  @override
  String get diagnosticBrainRotQ1 =>
      'I feel my short-term memory has weakened (I forget what was said to me recently).';

  @override
  String get diagnosticBrainRotQ2 =>
      'I have difficulty focusing on one task for long enough.';

  @override
  String get diagnosticBrainRotQ3 =>
      'My thinking feels slower compared to before.';

  @override
  String get diagnosticBrainRotQ4 =>
      'I experience \"brain fog\" or have trouble organizing my thoughts.';

  @override
  String get diagnosticBrainRotQ5 =>
      'I feel mental fatigue after short periods of thinking or mental work.';

  @override
  String get diagnosticBrainRotQ6 =>
      'I have trouble finding the right words when speaking or writing.';

  @override
  String get diagnosticBrainRotQ7 =>
      'I feel scattered or my thoughts jump quickly from idea to idea.';

  @override
  String get diagnosticBrainRotQ8 =>
      'Simple decisions or planning tasks have become harder.';

  @override
  String get diagnosticBrainRotQ9 =>
      'I work slower than usual or need more time for the same tasks.';

  @override
  String get diagnosticBrainRotQ10 =>
      'These symptoms affect my daily life (work, study, or relationships).';

  @override
  String dashboardBrainRotSummary(int score) {
    return 'Brain Rot: $score/10';
  }

  @override
  String get dashboardOpenRecoveryGrid => '30-Day Recovery Grid';

  @override
  String get dashboardOpenRecoveryGridSubtitle =>
      'Five daily habits · accountability room for missed check-ins';

  @override
  String get splashTitle => 'Brain Clean';

  @override
  String get splashHydrationRetry => 'Restoring your progress…';

  @override
  String get splashInitError => 'Loading failed. Please restart the app.';

  @override
  String get homeTitle => 'Brain Clean Home';

  @override
  String get homeEmptyDiagnosticPrompt =>
      'Complete the diagnostic to unlock your live BC_score tracker.';

  @override
  String get homeChallengeProgressTitle => '30-day recovery challenge';

  @override
  String homeChallengeProgressPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get homeOpenDiagnostic => 'Diagnostic assessment';

  @override
  String get homeOpenDiagnosticSubtitle =>
      'Brain Rot questionnaire + BHI sliders';

  @override
  String get homeOpenCognitiveHub => 'Cognitive assessments';

  @override
  String get homeOpenCognitiveHubSubtitle =>
      'Visual attention test and memory mini-games';

  @override
  String get homeOpenFullDashboard => 'Full clinical dashboard';

  @override
  String get cognitiveHubTitle => 'Cognitive assessments';

  @override
  String get cognitiveHubSubtitle =>
      'Interactive modules that refine your brain performance pillar.';

  @override
  String get cognitiveHubEmptyHint => 'No tests taken yet — try one now!';

  @override
  String get cognitiveVisualTestTitle => 'Visual Cognitive Image Test';

  @override
  String get cognitiveVisualTestSubtitle =>
      'Find the odd shape or color in a timed grid';

  @override
  String get cognitiveMemoryGameTitle => 'Memory mini-games';

  @override
  String get cognitiveMemoryGameSubtitle =>
      'Recall growing color sequences on a 3×3 grid';

  @override
  String get cognitiveStartButton => 'Start test';

  @override
  String get cognitiveDoneButton => 'Save & close';

  @override
  String get cognitiveMemoryInstructions =>
      'Watch the highlighted cells, then tap them in the same order. The sequence grows each round.';

  @override
  String get cognitiveMemoryWatch => 'Watch the sequence…';

  @override
  String get cognitiveMemoryYourTurn => 'Your turn — tap the cells in order';

  @override
  String cognitiveMemoryRound(int length) {
    return 'Sequence length: $length';
  }

  @override
  String get cognitiveMemoryWrong => 'Incorrect — test ended.';

  @override
  String get cognitiveMemoryResultTitle => 'Memory test complete';

  @override
  String cognitiveMemoryResultScore(int span, int score) {
    return 'Longest sequence: $span · Score: $score%';
  }

  @override
  String get cognitiveVisualInstructions =>
      'Tap the one cell that looks different. You have a few seconds each round.';

  @override
  String get cognitiveVisualFindOdd => 'Find the odd one out';

  @override
  String cognitiveVisualRound(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String get cognitiveVisualCorrect => 'Correct!';

  @override
  String get cognitiveVisualWrong => 'Wrong';

  @override
  String get cognitiveVisualTimeout => 'Too slow';

  @override
  String get cognitiveVisualResultTitle => 'Visual attention complete';

  @override
  String cognitiveVisualResultScore(int points, int maxPoints, int score) {
    return '$points / $maxPoints points · Score: $score%';
  }

  @override
  String get cognitivePlaceholderBody =>
      'This module is scaffolded for the unified BHI evaluation engine. Complete the placeholder run to verify navigation.';

  @override
  String get cognitivePlaceholderComplete => 'Record placeholder result';

  @override
  String cognitivePlaceholderRecorded(int score) {
    return 'Placeholder score recorded: $score%';
  }

  @override
  String get recoveryGridTitle => '30-Day Recovery';

  @override
  String get recoveryGridSubtitle =>
      'Tap a day to log the five mandatory habits.';

  @override
  String recoveryDayTasksTitle(int day) {
    return 'Day $day habits';
  }

  @override
  String recoveryProgressSummary(int completed, int total) {
    return '$completed of $total protocol days complete';
  }

  @override
  String recoveryDayTasksProgress(int done, int total) {
    return '$done of $total habits logged today';
  }

  @override
  String get recoveryTaskSleepTitle => 'Regulated sleep';

  @override
  String get recoveryTaskSleepSubtitle =>
      'Consistent sleep window and wind-down routine';

  @override
  String get recoveryTaskNutritionTitle => 'Anti-inflammatory nutrition';

  @override
  String get recoveryTaskNutritionSubtitle =>
      'Brain-supportive meals without inflammatory triggers';

  @override
  String get recoveryTaskMovementTitle => '20 minutes of movement';

  @override
  String get recoveryTaskMovementSubtitle =>
      'Walk, stretch, or light exercise for at least 20 minutes';

  @override
  String get recoveryTaskDistractionTitle => 'Distraction management protocol';

  @override
  String get recoveryTaskDistractionSubtitle =>
      'Completed your daily focus-protection routine';

  @override
  String get recoveryTaskMentalTitle => 'Mental support';

  @override
  String get recoveryTaskMentalSubtitle =>
      'Journaling, breathwork, or guided recovery check-in';

  @override
  String get recoveryDayComplete => 'All five habits completed for this day.';

  @override
  String get recoveryMissedHabitsTitle => 'Incomplete check-in';

  @override
  String get recoveryMissedHabitsSubtitle =>
      'Some habits were missed. Open the accountability room to record responsibility.';

  @override
  String get recoveryOpenPenaltyBox => 'Open accountability room';

  @override
  String get recoveryDayEmptyHint =>
      'Check off each habit as you complete it today.';

  @override
  String recoveryPenaltyCount(int count) {
    return 'Accountability entries: $count';
  }

  @override
  String get recoveryPenaltyBoxTitle => 'Accountability room';

  @override
  String recoveryPenaltyBoxMessage(int deduction) {
    return 'Confirming applies a −$deduction BC_score accountability entry for missed habits today.';
  }

  @override
  String get recoveryPenaltyConfirm => 'Confirm accountability';

  @override
  String get recoveryPenaltyCancel => 'Cancel';

  @override
  String get recoveryPenaltyApplied => 'Accountability recorded for today.';

  @override
  String get recoveryStorageLoadError =>
      'Could not load your recovery progress from local storage.';

  @override
  String get recoveryStorageSaveError =>
      'Could not save your latest check-in. Your changes are kept on screen — try again.';

  @override
  String get recoveryStorageReset => 'Start fresh protocol';

  @override
  String get recoveryStorageMigratedNotice =>
      'Your saved progress was upgraded to the latest format.';

  @override
  String get recoveryStorageRecoveredNotice =>
      'Local data was reset because it could not be read. A new protocol has started.';

  @override
  String get homeStreakDays => 'Days';

  @override
  String get homeStreakHours => 'Hours';

  @override
  String get homeStreakMinutes => 'Min';

  @override
  String get homeStreakSeconds => 'Sec';

  @override
  String get homeDistractionButton => 'Temporary distraction';

  @override
  String get homeDistractionConfirmTitle => 'Confirm distraction';

  @override
  String get homeDistractionConfirmMessage =>
      'Are you sure? 12 hours will be deducted from your streak.';

  @override
  String get homeDistractionConfirm => 'Confirm';

  @override
  String get homeDistractionCancel => 'Cancel';

  @override
  String get homeOpenAccountability => 'Digital accountability room';

  @override
  String get accountabilityRoomTitle => 'Digital accountability room';

  @override
  String get accountabilityPenaltyRecorded => 'Penalty recorded ✓';

  @override
  String get accountabilityCatPhysical => 'Physical';

  @override
  String get accountabilityCatNutritional => 'Nutritional';

  @override
  String get accountabilityCatAltruistic => 'Altruistic';

  @override
  String get accountabilityCatMental => 'Mental';

  @override
  String get accountabilityPenPhysical1 => 'Skipped movement block';

  @override
  String get accountabilityPenPhysical2 => 'Poor sleep hygiene';

  @override
  String get accountabilityPenPhysical3 => 'Sedentary relapse';

  @override
  String get accountabilityPenPhysical4 => 'Missed recovery walk';

  @override
  String get accountabilityPenPhysical5 => 'Body activation skipped';

  @override
  String get accountabilityPenNutritional1 => 'Inflammatory meal';

  @override
  String get accountabilityPenNutritional2 => 'Skipped brain-support meal';

  @override
  String get accountabilityPenNutritional3 => 'Excess sugar intake';

  @override
  String get accountabilityPenNutritional4 => 'Hydration neglect';

  @override
  String get accountabilityPenNutritional5 => 'Late-night eating';

  @override
  String get accountabilityPenAltruistic1 => 'Missed kindness act';

  @override
  String get accountabilityPenAltruistic2 => 'Social withdrawal';

  @override
  String get accountabilityPenAltruistic3 => 'Ignored support request';

  @override
  String get accountabilityPenAltruistic4 => 'Self-focused relapse';

  @override
  String get accountabilityPenAltruistic5 => 'Community check-in skipped';

  @override
  String get accountabilityPenMental1 => 'Skipped breathwork';

  @override
  String get accountabilityPenMental2 => 'Avoided journaling';

  @override
  String get accountabilityPenMental3 => 'Rumination spiral';

  @override
  String get accountabilityPenMental4 => 'Missed mental check-in';

  @override
  String get accountabilityPenMental5 => 'Escalated screen binge';

  @override
  String get breathingInhale => 'Inhale…';

  @override
  String get breathingHold => 'Hold…';

  @override
  String get breathingExhale => 'Exhale…';

  @override
  String breathingCountdownSeconds(int seconds) {
    return '$seconds seconds remaining';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonOk => 'OK';

  @override
  String get commonGreat => 'Great';

  @override
  String get commonBack => 'Back';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPage1Title => 'Welcome to Brain Clean';

  @override
  String get onboardingPage1Body => 'Restore your digital awareness in 21 days';

  @override
  String get onboardingPage2Title => 'Track your focus daily';

  @override
  String get onboardingPage2Body =>
      'Real science-based formulas to measure brain health';

  @override
  String get onboardingPage3Title => 'Start your journey now';

  @override
  String get onboardingPage3Body =>
      'Answer 10 questions to assess your brain rot level';

  @override
  String get onboardingStartQuiz => 'Start assessment';

  @override
  String get proPaywallTitle => 'Brain Clean Pro';

  @override
  String get proPaywallSubtitle => 'Unlock your mind\'s full potential';

  @override
  String get proFeatureAdvancedBcs => 'Advanced Brain Clarity Score engine';

  @override
  String get proFeatureSevenDayChart => '7-day progress chart';

  @override
  String get proFeatureEmotionWheel => 'Emotion wheel & recovery impact';

  @override
  String get proFeatureFocusChallenges => 'Advanced focus challenges';

  @override
  String get proFeatureCloudSync => 'Secure cloud sync';

  @override
  String get proFeatureColorThemes => '4 exclusive Pro color themes';

  @override
  String get proWelcomeSnack => 'Welcome to Pro! 🎉';

  @override
  String get proPriceMonthly => 'SAR 19 / month';

  @override
  String get proPriceHint => 'Less than one meal';

  @override
  String get proSubscribeNow => 'Subscribe now';

  @override
  String get proRestorePurchase => 'Restore purchase';

  @override
  String get proBadgeLabel => 'Pro';

  @override
  String get proPlanMonthly => 'Monthly';

  @override
  String get proPlanAnnual => 'Annual';

  @override
  String get proPlanLifetime => 'Lifetime';

  @override
  String get proBestValueBadge => 'Best value';

  @override
  String get proAlreadyProTitle => 'You\'re already Pro';

  @override
  String get proAlreadyProBody =>
      'Enjoy unlimited access to all premium features.';

  @override
  String get proRestoreSuccess => 'Purchases restored successfully';

  @override
  String get proRestoreNone => 'No previous purchases found';

  @override
  String get proPurchaseError =>
      'Something went wrong completing your purchase. Please try again.';

  @override
  String get proPlansUnavailable =>
      'Plans are unavailable right now. Please try again later.';

  @override
  String get paywallRetryLoad => 'Retry';

  @override
  String get paywallLifetimeLabel => 'One-time forever';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsProActive => 'Brain Clean Pro ✓';

  @override
  String get settingsUpgradeToPro => 'Upgrade to Pro';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get colorThemeMidnightName => 'Midnight';

  @override
  String get colorThemeAuroraName => 'Aurora';

  @override
  String get colorThemePineName => 'Pine';

  @override
  String get colorThemeSolarName => 'Solar';

  @override
  String get colorThemeSlateName => 'Slate';

  @override
  String get colorThemeDaylightName => 'Daylight';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsEmotionNotifications => 'Negative emotion alerts';

  @override
  String get settingsDailyFocusReminder => 'Daily focus reminder';

  @override
  String get settingsDailyReminder => 'Daily Reminder';

  @override
  String get settingsDailyReminderSub => 'Daily reminder at 9:00 AM';

  @override
  String get notifDailyTitle => 'Time for your daily exercise 🧠';

  @override
  String get notifDailyBody => 'Open Brain Clean and start your day with focus';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsResetData => 'Reset all data';

  @override
  String get settingsResetDataConfirmTitle => 'Reset all data';

  @override
  String get settingsResetDataConfirmBody =>
      'All local data will be deleted. Are you sure?';

  @override
  String get settingsExportData => 'Export my data';

  @override
  String get settingsComingSoon => 'Coming soon…';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsContactUs => 'Contact us';

  @override
  String get emotionWheelTitle => 'Emotion wheel';

  @override
  String get emotionImpactDialogTitle => 'Log emotion';

  @override
  String get emotionLogDialogBody =>
      'Logging this emotion helps you understand your day and track your progress gently. Do you want to log it?';

  @override
  String get emotionIgnore => 'No, ignore';

  @override
  String get emotionConfirmLog => 'Yes, log it';

  @override
  String get emotionGateNegative => 'I feel something negative';

  @override
  String get emotionGateNeutral => 'I feel something neutral';

  @override
  String get emotionGatePositive => 'I feel something positive';

  @override
  String get silenceChallengeTitle => 'Silence challenge';

  @override
  String silenceChallengeSubtitle(int minutes) {
    return 'Don\'t touch the screen for $minutes minutes';
  }

  @override
  String silenceChallengeLevel(int level, int minutes) {
    return 'Level $level — $minutes minutes required';
  }

  @override
  String get silenceChallengeFailedTitle => 'Challenge failed';

  @override
  String get silenceChallengeFailedBody =>
      'You touched the screen or left the app.';

  @override
  String get silenceChallengeSuccessTitle => 'Well done! 🎉';

  @override
  String get silenceChallengeSuccessBody =>
      'You completed the silence challenge.';

  @override
  String get silenceChallengeDurationLabel => 'Session length';

  @override
  String silenceChallengeDurationOption(int minutes) {
    return '$minutes min';
  }

  @override
  String get singleTaskPauseTitle => 'Pause task';

  @override
  String get singleTaskPauseBody =>
      'Stop the current task? You won\'t earn a reward.';

  @override
  String get singleTaskModeTitle => 'Single-task mode';

  @override
  String get singleTaskFocusRewardSnack => 'Great! +10 focus points';

  @override
  String get singleTaskHint => 'Write your task now…';

  @override
  String get singleTaskStartFocus => 'Start focus';

  @override
  String get singleTaskFocusing => 'Focusing…';

  @override
  String get singleTaskCompleted => 'Task done ✓';

  @override
  String get singleTaskPauseButton => 'Pause';

  @override
  String get delayedGratTitle => 'Delayed gratification';

  @override
  String get delayedGratSubtitle =>
      'Hold 20 minutes before opening social media';

  @override
  String get delayedGratQuoteUnder5 => 'Patience is the key to relief';

  @override
  String get delayedGratQuoteUnder10 => 'Your brain thanks you now';

  @override
  String get delayedGratQuoteUnder15 => 'You\'re stronger than the algorithm';

  @override
  String get delayedGratQuoteDefault => 'Almost there — keep going';

  @override
  String get delayedGratGiveUpTitle => 'Give up';

  @override
  String get delayedGratGiveUpBody =>
      'Give up now? You won\'t earn the reward.';

  @override
  String get delayedGratGiveUpButton => 'Give up';

  @override
  String get delayedGratVictoryTitle => 'You beat yourself! 🏆';

  @override
  String get delayedGratVictoryBody => '+25 focus points added.';

  @override
  String get chartSevenDayTitle => 'Your 7-day progress';

  @override
  String get chartDaySat => 'Sat';

  @override
  String get chartDaySun => 'Sun';

  @override
  String get chartDayMon => 'Mon';

  @override
  String get chartDayTue => 'Tue';

  @override
  String get chartDayWed => 'Wed';

  @override
  String get chartDayThu => 'Thu';

  @override
  String get chartDayFri => 'Fri';

  @override
  String get proGatedChartTitle => '7-day progress chart';

  @override
  String get proGatedChartSubtitle => 'Available in Brain Clean Pro';

  @override
  String get visualCognitiveBack => 'Back';

  @override
  String visualCognitiveRound(int round) {
    return 'Round $round / 5';
  }

  @override
  String get visualCognitiveInstruction =>
      'Tap the square with a different color';

  @override
  String visualCognitiveScore(int score) {
    return 'Score: $score';
  }

  @override
  String get diagnosticCognitiveTestButton => 'Test your focus 🎯';

  @override
  String get homeQuickEmotion => 'How do you feel? 💭';

  @override
  String get homeQuickSilence => 'Silence challenge 🔇';

  @override
  String get homeQuickSingleTask => 'Single task 🎯';

  @override
  String get homeQuickDelayedGrat => 'Delayed gratification ⏳';

  @override
  String get homeQuickCognitiveTest => 'Test your focus 🧪';

  @override
  String get homeAccountabilityBox => 'Accountability box';

  @override
  String get homeDistractionConfirmAction => 'Confirm distraction';

  @override
  String get splashSubtitle => 'Reset your brain';

  @override
  String get profileDefaultName => 'Brain Clean user';

  @override
  String get profileProBadge => 'Pro ⭐';

  @override
  String get profileStatFocusDays => 'focus days';

  @override
  String get profileStatBcs => 'BCS';

  @override
  String get profileStatEmotions => 'emotions';

  @override
  String get profileRecentEmotions => 'Recent emotions';

  @override
  String get profileNoEmotionsYet => 'No emotions logged yet';

  @override
  String get profileAchievements => 'Your achievements';

  @override
  String get profileBadgeStreak7 => '7-day streak';

  @override
  String get profileBadgeCleanBrain => 'Clean brain';

  @override
  String get profileBadgeSilenceHero => 'Silence hero';

  @override
  String get profileBadgeSingleTask => 'Single task';

  @override
  String get profileBadgeEmotionAwake => 'Emotion aware';

  @override
  String get profileBadgeProMember => 'Pro Member';

  @override
  String get accountabilityModalCatPhysical => 'Physical fitness';

  @override
  String get accountabilityModalCatNutritional => 'Healthy nutrition';

  @override
  String get accountabilityModalCatAltruistic => 'Altruistic acts';

  @override
  String get accountabilityModalCatMental => 'Mental challenge';

  @override
  String get accountabilityModalPenPhysical1 => '30-minute workout';

  @override
  String get accountabilityModalPenPhysical2 => 'Strength training';

  @override
  String get accountabilityModalPenPhysical3 => '5,000 steps walk';

  @override
  String get accountabilityModalPenPhysical4 => 'Morning stretch';

  @override
  String get accountabilityModalPenPhysical5 => 'Outdoor activity';

  @override
  String get accountabilityModalPenNutritional1 => 'Avoid sugar';

  @override
  String get accountabilityModalPenNutritional2 => 'Balanced meal';

  @override
  String get accountabilityModalPenNutritional3 => 'Drink 2L water';

  @override
  String get accountabilityModalPenNutritional4 => 'Reduce caffeine';

  @override
  String get accountabilityModalPenNutritional5 => 'Protein meal';

  @override
  String get accountabilityModalPenAltruistic1 => 'Help a neighbor';

  @override
  String get accountabilityModalPenAltruistic2 => 'Small donation';

  @override
  String get accountabilityModalPenAltruistic3 => 'Thank-you message';

  @override
  String get accountabilityModalPenAltruistic4 => 'Community service';

  @override
  String get accountabilityModalPenAltruistic5 => 'Support a friend';

  @override
  String get accountabilityModalPenMental1 => 'Read 20 minutes';

  @override
  String get accountabilityModalPenMental2 => 'Solve a puzzle';

  @override
  String get accountabilityModalPenMental3 => 'Learn a new word';

  @override
  String get accountabilityModalPenMental4 => 'Guided meditation';

  @override
  String get accountabilityModalPenMental5 => 'Journal writing';

  @override
  String get breathingInhaleSlow => 'Inhale slowly…';

  @override
  String get breathingExhaleFull => 'Exhale fully…';

  @override
  String get asyncErrorRetry => 'Something went wrong. Please try again.';

  @override
  String get chartEmptyState => 'No data yet — start your journey today';

  @override
  String get homeStreakMotivation => 'Start your first focus session now 🚀';

  @override
  String get dailyQuoteSource => 'Neuroscience';

  @override
  String get streakFreezeConfirm =>
      'Use streak freeze? Available once per week';

  @override
  String get shareProgressLabel => 'Share Progress';

  @override
  String shareScoreText(int score) {
    return 'I scored $score on Brain Clean! 🧠\nDownload the app and start your journey:';
  }

  @override
  String shareProfileText(int level) {
    return 'I\'m at level $level in Brain Clean! 🏆\nJoin me:';
  }

  @override
  String levelPointsToNext(int points) {
    return '$points points to next level';
  }

  @override
  String get weeklyReportTitle => 'Weekly Report';

  @override
  String get weeklyReportStreakDays => 'Focus days this week';

  @override
  String get weeklyReportAvgBcs => 'Average BCS';

  @override
  String get weeklyReportBestEmotion => 'Top emotion';

  @override
  String get weeklyReportChallenges => 'Challenges completed';

  @override
  String get weeklyReportEmpty => 'No data this week — keep going!';

  @override
  String get weeklyReportEmptyCta => 'Back to Home';

  @override
  String get pomodoroTitle => 'Pomodoro';

  @override
  String get pomodoroPhaseFocus => 'Focus Time 🎯';

  @override
  String get pomodoroPhaseShortBreak => 'Short Break ☕';

  @override
  String get pomodoroPhaseLongBreak => 'Long Break 🌿';

  @override
  String get pomodoroReset => 'Reset';

  @override
  String get pomodoroSkip => 'Skip';

  @override
  String pomodoroSessionsToday(int count) {
    return 'Today\'s sessions: $count';
  }

  @override
  String get homeQuickPomodoro => 'Pomodoro ⏱️';

  @override
  String get homeQuickGames => 'Games 🎮';

  @override
  String get taskCategoryMental => '🧠 Mental';

  @override
  String get taskCategoryPhysical => '💪 Physical';

  @override
  String get taskCategoryCreative => '🎨 Creative';

  @override
  String get taskCategoryEducational => '📚 Educational';

  @override
  String get taskCategoryHousehold => '🏠 Household';

  @override
  String singleTaskEstimatedBonus(String points) {
    return 'Completing this task adds +$points points';
  }

  @override
  String singleTaskFocusRewardSnackBonus(String points) {
    return 'Great! +$points focus points';
  }

  @override
  String get singleTaskAbandonSnack => 'Incomplete tasks slightly weaken focus';

  @override
  String get gamesHubTitle => 'Brain Games 🎮';

  @override
  String get gamePatternMatchTitle => 'Pattern Match';

  @override
  String get gamePatternMatchDesc => 'Memorize and recreate the grid pattern';

  @override
  String get gameNumberMemoryTitle => 'Number Memory';

  @override
  String get gameNumberMemoryDesc => 'Remember growing digit sequences';

  @override
  String get gameColorWordTitle => 'Color Word';

  @override
  String get gameColorWordDesc => 'Tap the ink color, not the word';

  @override
  String gamesBestScore(int score) {
    return 'Best score: $score';
  }

  @override
  String gamesBestDigits(int digits) {
    return 'Best digits: $digits';
  }

  @override
  String gameRoundLabel(int current, int total) {
    return 'Round $current / $total';
  }

  @override
  String gameFinalScore(int score) {
    return 'Score: $score';
  }

  @override
  String get gameSubmitRound => 'Submit';

  @override
  String get gameEnterSequence => 'Enter the sequence you saw';

  @override
  String gameNumberMemoryResult(int digits) {
    return 'Max digits reached: $digits';
  }

  @override
  String get gameColorWordPrompt => 'Tap the color of the ink';

  @override
  String get focusedThinkingTitle => 'Focused Thinking Challenge';

  @override
  String get focusedThinkingSubtitle =>
      'Pick one topic and think about it deeply';

  @override
  String get focusedThinkingDurationLabel => 'Duration';

  @override
  String get focusedThinkingStart => 'Start thinking';

  @override
  String get focusedThinkingGuideTitle => 'Thinking Guide';

  @override
  String focusedThinkingStillThinking(String topic) {
    return 'Still thinking about $topic?';
  }

  @override
  String get focusedThinkingYes => 'Yes ✓';

  @override
  String get focusedThinkingNo => 'Drifted ✗';

  @override
  String focusedThinkingFocusScore(int percent) {
    return '$percent% of the time you stayed focused';
  }

  @override
  String focusedThinkingDistractions(int count) {
    return 'Distractions logged: $count';
  }

  @override
  String focusedThinkingInsightsSaved(int count) {
    return 'Insights saved: $count';
  }

  @override
  String get focusedThinkingInsightsHint => 'Note your key insights';

  @override
  String get focusedThinkingSaveInsight => 'Save insight';

  @override
  String get homeQuickFocusedThinking => 'Deep thinking 🧠';

  @override
  String get homeQuickCrossword => 'Crossword ✏️';

  @override
  String get crosswordTitle => 'Crossword';

  @override
  String get crosswordDesc => 'Brain-themed Arabic crossword puzzles';

  @override
  String get crosswordPlayNow => 'Play now';

  @override
  String get crosswordTabAcross => 'Across ↔';

  @override
  String get crosswordTabDown => 'Down ↕';

  @override
  String get crosswordEnterLetter => 'Enter letter';

  @override
  String get gameNBackTitle => 'N-Back 🧠';

  @override
  String get gameNBackDesc =>
      'Strongest science-backed working memory training';

  @override
  String get gameNBackIntro =>
      'This is scientifically the strongest game for working memory';

  @override
  String gameNBackLevel(int n, int current, int total) {
    return 'N=$n — $current/$total';
  }

  @override
  String get gameNBackMatch => 'Match!';

  @override
  String gameNBackResult(int n) {
    return 'Max N reached: $n';
  }

  @override
  String gameNBackBonus(String points) {
    return '+$points BCS earned';
  }

  @override
  String gamesBestNLevel(int n) {
    return 'Best N: $n';
  }

  @override
  String get gameSpeedSortTitle => 'Speed Sort';

  @override
  String get gameSpeedSortDesc => 'Sort falling numbers into even/odd buckets';

  @override
  String get gameSpeedSortEven => 'Even';

  @override
  String get gameSpeedSortOdd => 'Odd';

  @override
  String gameSpeedSortCorrect(int count) {
    return 'Correct: $count';
  }

  @override
  String gameSpeedSortResult(int correct, int wrong) {
    return 'Done! $correct correct, $wrong wrong';
  }

  @override
  String get gameStart => 'Start';

  @override
  String get bciCardTitle => 'Brain Clarity (BCI)';

  @override
  String get bciCardTitleEn => 'BRAIN CLARITY INDEX';

  @override
  String get bciCardSubtitle => 'BCI Engine · Live update';

  @override
  String get bciCardAssessmentLabel => 'Weekly assessment';

  @override
  String get bciCardAdherenceLabel => 'Daily adherence';

  @override
  String get bciCardWeightAssessment => '60%';

  @override
  String get bciCardWeightAdherence => '40%';

  @override
  String get bciCardStatusHigh => 'Peak focus';

  @override
  String get bciCardStatusStable => 'Stable focus';

  @override
  String get bciCardStatusMild => 'Mild fog';

  @override
  String get bciCardStatusWarning => 'Warning — review your habits';

  @override
  String get bciCardNoAssessment =>
      'Complete the weekly assessment for full BCI';

  @override
  String get bciCardLoading => 'Calculating BCI...';

  @override
  String get bciOneLiner =>
      '60% weekly assessment + 40% daily adherence over the last 7 days';

  @override
  String get bciFullExplanation =>
      'Brain Clarity (BCI) is a live 0–100 score that updates daily. 60% comes from your weekly assessment (BHI test and mental clarity), and 40% from how consistently you followed your recovery protocol over the last 7 days. If you haven’t completed the weekly assessment yet, the score is based on adherence only.';

  @override
  String get calmIndexOneLiner =>
      'The inverse of your anxiety test — less anxiety means more calm';

  @override
  String get calmIndexFullExplanation =>
      'The Calm Index is calculated from your anxiety test: 100 minus your anxiety score. It appears on the chart once you have at least two anxiety test results, and days between tests are estimated with a gradual fill.';

  @override
  String get metricInfoA11yLabel => 'What does this number mean?';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get settingsBiometricLock => 'Biometric app lock';

  @override
  String get settingsBiometricLockSubtitle =>
      'Require authentication when opening the app (device PIN fallback)';

  @override
  String get settingsBiometricUnavailable =>
      'Biometric authentication is not available on this device';

  @override
  String get biometricLockTitle => 'App locked';

  @override
  String get biometricLockSubtitle =>
      'Use your fingerprint or device PIN to continue';

  @override
  String get biometricLockButton => 'Unlock Brain Clean';

  @override
  String get biometricFallbackPin => 'Use PIN instead';

  @override
  String get securityCompromisedBanner =>
      'Warning: this device may be compromised. Local data only — cloud sync is disabled.';

  @override
  String get emotionOasisTitle => 'Emotion Oasis — Safa';

  @override
  String get emotionOasisHint => 'Share how you\'re feeling right now...';

  @override
  String get emotionOasisAnalyze => 'Talk to Safa';

  @override
  String get emotionOasisPromptLabel => 'What\'s on your mind?';

  @override
  String get navTabHome => 'Home';

  @override
  String get navTabExercises => 'Exercises';

  @override
  String get navTabSafa => 'Safa';

  @override
  String get navTabJourney => 'My Journey';

  @override
  String get navTabMore => 'More';

  @override
  String get sosFabTooltip => 'SOS Emergency';

  @override
  String get exercisesTabTitle => 'Exercises';

  @override
  String get exercisesCardCognitiveHubTitle => 'Exercise Library';

  @override
  String get exercisesCardCognitiveHubSubtitle => '20 science-backed exercises';

  @override
  String get exercisesCardPomodoroTitle => 'Pomodoro';

  @override
  String get exercisesCardPomodoroSubtitle => '25-minute focus';

  @override
  String get exercisesCardBreathingTitle => 'Breathing Exercise';

  @override
  String get exercisesCardBreathingSubtitle => '4·4·4·4 box breathing';

  @override
  String get exercisesCardGamesTitle => 'Cognitive Games';

  @override
  String get exercisesCardGamesSubtitle => 'Challenge your brain';

  @override
  String get exercisesCardSingleTaskTitle => 'Single Task';

  @override
  String get exercisesCardSingleTaskSubtitle => 'Single-point focus';

  @override
  String get exercisesCardDeepThinkingTitle => 'Deep Thinking';

  @override
  String get exercisesCardDeepThinkingSubtitle => '10 distraction-free minutes';

  @override
  String get exercisesCardSukoonTitle => 'Sukoon';

  @override
  String get exercisesCardSukoonSubtitle => 'Wakeful rest — clear your mind';

  @override
  String get safaTabTitle => 'Safa';

  @override
  String get safaTabSubtitle => 'Your AI guide · here when you need her';

  @override
  String get safaTalkButton => 'Talk to Safa';

  @override
  String get safaOasisButton => 'Emotion Oasis';

  @override
  String get safaTrialExpiredMessage =>
      'Your free Safa trial has ended — continue with her by subscribing to Pro';

  @override
  String get safaMedicalDisclaimer =>
      'Safa is AI-powered emotional support, not a substitute for a doctor or licensed therapist. If things feel bigger than this, please consult a professional.';

  @override
  String get journeyTabTitle => 'My Journey';

  @override
  String get journeyCardBciTitle => 'Brain Clarity Index (BCI)';

  @override
  String get journeyCardDiagnosticTitle => 'Diagnostic';

  @override
  String get journeyCardWeeklyReportTitle => 'Weekly Report';

  @override
  String get journeyQuickLinksTitle => 'Quick links';

  @override
  String get moreTabTitle => 'More';

  @override
  String get moreProfile => 'Profile';

  @override
  String get moreSettings => 'Settings';

  @override
  String get morePro => 'Brain Clean Pro';

  @override
  String get moreAccountability => 'Accountability Partner';

  @override
  String get moreVersion => 'Version 1.0.0';

  @override
  String get homeGreetingMorning => 'Good morning ☀️';

  @override
  String get homeGreetingAfternoon => 'Good afternoon 🌤️';

  @override
  String get homeGreetingEvening => 'Good evening 🌙';

  @override
  String get homeHeroName => 'Champion';

  @override
  String get homeStreakLabel => 'day streak';

  @override
  String get homeBciLabel => 'Brain Clarity Index';

  @override
  String get homeBciTrend => '↑ this week';

  @override
  String get homeActivitiesTitle => 'Today\'s activities';

  @override
  String get homeActivitiesOf => 'of';

  @override
  String get homeSafaMessage => 'Proud of you! Keep going 💚';

  @override
  String get homeProFeature => 'Charts + advanced AI';

  @override
  String get homeActivityExercise => 'Exercise';

  @override
  String get homeActivityWater => 'Water';

  @override
  String get homeActivitySleep => 'Sleep';

  @override
  String get homeActivityMovement => 'Movement';

  @override
  String get settingsSubscriptionSection => 'Subscription';

  @override
  String get anxietyScreenTitle => 'Anxiety Assessment';

  @override
  String get anxietyResultTitle => 'Your Anxiety Result';

  @override
  String anxietyProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get anxietyQ1 => 'Do you overthink a lot before sleep?';

  @override
  String get anxietyQ2 =>
      'Do you replay scenarios in your head more than once?';

  @override
  String get anxietyQ3 => 'Do you often expect the worst?';

  @override
  String get anxietyQ4 => 'Is it hard for you to stop thinking?';

  @override
  String get anxietyQ5 => 'Do you feel like your mind is always running?';

  @override
  String get anxietyQ6 =>
      'Do you notice physical tension (tight shoulders, stomach, fast breathing)?';

  @override
  String get anxietyQ7 =>
      'Do you avoid tasks or situations because of anxiety?';

  @override
  String get anxietyQ8 =>
      'Does anxiety affect your focus or sleep on a daily basis?';

  @override
  String get anxietyOptionNever => 'Never';

  @override
  String get anxietyOptionSometimes => 'Sometimes';

  @override
  String get anxietyOptionOften => 'Often';

  @override
  String get anxietyOptionAlways => 'Always';

  @override
  String get anxietyLevelCalm => 'Calm';

  @override
  String get anxietyLevelModerate => 'Moderate';

  @override
  String get anxietyLevelHigh => 'High';

  @override
  String get anxietyLevelSevere => 'Severe';

  @override
  String get anxietyInterpretationCalm =>
      'Your anxiety is in a normal range — keep up your current pace.';

  @override
  String get anxietyInterpretationModerate =>
      'Early signs of chronic anxiety — an anxiety journal can help a lot.';

  @override
  String get anxietyInterpretationHigh =>
      'Anxiety is affecting your life — Safa will guide you step by step.';

  @override
  String get anxietyInterpretationSevere =>
      'We recommend seeing a specialist + start the anxiety program with Safa.';

  @override
  String get anxietyStartProgramCta => 'Start the program with Safa';

  @override
  String get anxietyRetakeTest => 'Retake the test';

  @override
  String get anxietyJourneyCardTitle => 'Anxiety Assessment';

  @override
  String get anxietyJourneyCardSubtitle =>
      '8 questions · chronic anxiety screening';

  @override
  String anxietyJourneyCardLatestScore(int score) {
    return 'Latest score: $score%';
  }

  @override
  String get anxietySaveError =>
      'Could not save your result. Please try again.';

  @override
  String get anxietyLoadError => 'Could not load your result.';

  @override
  String get anxietyNoResultYet => 'No result yet. Take the assessment first.';

  @override
  String get worryWindowTitle => 'Worry Window';

  @override
  String get worryJournalTitle => 'Worry Journal';

  @override
  String get worrySafaPrompt =>
      'Write what\'s on your mind right now — it doesn\'t have to be organized, just get it out 🌿';

  @override
  String get worryJournalHint => 'What\'s worrying you today?';

  @override
  String get worryDurationTen => '10 min';

  @override
  String get worryDurationFifteen => '15 min';

  @override
  String get worryRuleReminder => '💡 Not before bedtime';

  @override
  String get worryTimerStart => 'Start';

  @override
  String get worryTimerPause => 'Pause';

  @override
  String get worryTimerReset => 'Reset';

  @override
  String get worryWindowCompleteMessage =>
      'Well done — you emptied your mind 💚 Sleep will be calmer tonight.';

  @override
  String get worrySaveAndClose => 'Save & close';

  @override
  String get worrySaveFab => 'Save';

  @override
  String get worrySavedSnackbar => '✓ Saved';

  @override
  String get worryPastEntriesTitle => 'Today\'s entries';

  @override
  String get worryNoEntriesToday => 'No entries yet today.';

  @override
  String get worryLoadError => 'Could not load entries.';

  @override
  String get worryDiscardTitle => 'Discard writing?';

  @override
  String get worryDiscardBody => 'You have unsaved text. Close without saving?';

  @override
  String get worrySettingsSectionTitle => 'Daily Worry Window';

  @override
  String get worrySettingsReminderTime => 'Reminder time';

  @override
  String get worrySettingsReminderEnabled => 'Enable reminder';

  @override
  String get worryTimingWarning =>
      '⚠️ Worry window should be before bedtime — pick an earlier time.';

  @override
  String get worryNotifTitle => 'Worry window time 🧠';

  @override
  String get worryNotifBody =>
      '10 minutes to empty your mind — you\'ll stay calmer all night';

  @override
  String get homeActivityWorryJournal => '✍️ Worry Journal';

  @override
  String get homeActivityWorryWindow => '⏱️ Worry Window';

  @override
  String get safaProgramTitle => 'Your program with Safa 🌿';

  @override
  String get safaProgramCta => 'Start with Safa';

  @override
  String get safaProgramLoadError => 'Could not load your program.';

  @override
  String get safaProgramFallbackCalm =>
      'Your anxiety is under control — keep your current pace. Use the worry journal if pressure builds. Safa is here if you need support. You are on the right path 💚';

  @override
  String get safaProgramFallbackModerate =>
      'Early chronic anxiety signs — the worry journal will help a lot. Try a daily worry window at 5 PM. Safa will check in weekly. Small daily steps make a difference 🌿';

  @override
  String get safaProgramFallbackHigh =>
      'Anxiety is affecting your days — start a daily worry window and add light movement. Safa will build a weekly plan with you. You are stronger than anxiety 💪';

  @override
  String get safaProgramFallbackSevere =>
      'Anxiety is high — consider seeing a specialist alongside the program. Start the worry journal daily. Safa is with you every step. You do not have to face this alone 🤝';

  @override
  String get calmIndexLegendBci => 'Brain Clarity (BCI)';

  @override
  String get calmIndexLegendCalm => 'Calm Index';

  @override
  String get safaCheckinIcon => '🌙';

  @override
  String get safaCheckinTitle => 'A note from Safa';

  @override
  String get safaCheckinBody =>
      'I noticed you journal worries at night often — that can affect your sleep. Would you like to move your worry window to the afternoon?';

  @override
  String get safaCheckinAction => 'Change time';

  @override
  String get safaCheckinTimeUpdated => 'Worry window reminder updated.';

  @override
  String get dailyChallengeIcon => '🧠';

  @override
  String get dailyChallengeTitle => 'Today\'s challenge';

  @override
  String get dailyChallengeCompleted => 'Done ✓';

  @override
  String get dailyChallengeStart => 'Start challenge';

  @override
  String get dailyChallengeReplay => 'Replay challenge 🔄';

  @override
  String get dailyChallengeGameNBack => 'N-Back Memory';

  @override
  String get dailyChallengeGameSpeedSort => 'Speed Sort';

  @override
  String get dailyChallengeGameColorWord => 'Color Word';

  @override
  String get dailyChallengeGameNumberMemory => 'Number Memory';

  @override
  String get dailyChallengeGamePatternMatch => 'Pattern Match';

  @override
  String get dailyChallengeGameCrossword => 'Crossword';

  @override
  String get dailyChallengeSubtitleNBack => 'Train your working memory';

  @override
  String get dailyChallengeSubtitleSpeedSort =>
      'Speed up your logical thinking';

  @override
  String get dailyChallengeSubtitleColorWord => 'Challenge your visual focus';

  @override
  String get dailyChallengeSubtitleNumberMemory =>
      'Strengthen your number memory';

  @override
  String get dailyChallengeSubtitlePatternMatch =>
      'Sharpen your visual discrimination';

  @override
  String get dailyChallengeSubtitleCrossword => 'Expand your Arabic vocabulary';

  @override
  String get weeklyReportEntryIcon => '📊';

  @override
  String get weeklyReportEntryTitle => 'Weekly Report';

  @override
  String get weeklyReportEntrySubtitle => 'See your progress this week';

  @override
  String get weeklyReportLoadError => 'Could not load your weekly report.';

  @override
  String get weeklyReportBciLabel => 'Brain Clarity Index';

  @override
  String get weeklyReportBciNoData => 'No data recorded this week';

  @override
  String weeklyReportBciUp(String percent) {
    return '↑ +$percent%';
  }

  @override
  String weeklyReportBciDown(String percent) {
    return '↓ -$percent%';
  }

  @override
  String get weeklyReportBciFlat => '→ Steady';

  @override
  String get weeklyReportActivityTitle => 'Activity summary';

  @override
  String get weeklyReportStatGamesIcon => '🎮';

  @override
  String get weeklyReportStatGames => 'games';

  @override
  String get weeklyReportStatChallengesIcon => '🧩';

  @override
  String get weeklyReportStatChallenges => 'challenges';

  @override
  String weeklyReportStatChallengesValue(int count) {
    return '$count/7';
  }

  @override
  String get weeklyReportStatWorryIcon => '✍️';

  @override
  String get weeklyReportStatWorry => 'worry notes';

  @override
  String get weeklyReportStatStreakIcon => '🔥';

  @override
  String get weeklyReportStatStreak => 'streak days';

  @override
  String get weeklyReportBestGameTitle => 'Star of the week 🏆';

  @override
  String get weeklyReportBestGameSubtitle => 'Best performance this week';

  @override
  String get weeklyReportCalmTitle => 'Calm Index';

  @override
  String get weeklyReportSafaAvatar => 'S';

  @override
  String get smartReminderSectionTitle => 'Smart reminder';

  @override
  String get smartReminderToggle => 'Smart reminder';

  @override
  String smartReminderStatusDetected(int hour) {
    return 'Reminder will arrive at $hour:00 based on your habit 🎯';
  }

  @override
  String get smartReminderStatusLearning =>
      'Open the app 3 days in a row so we can learn your favorite time';

  @override
  String get smartReminderInfoChip => 'Learns from your behavior automatically';

  @override
  String get dailyProgramTitle => 'Daily Program';

  @override
  String get dailyProgramLoadError => 'Could not load today\'s program.';

  @override
  String get dailyProgramGreetingGeneric => 'Good morning 🌿';

  @override
  String dailyProgramGreetingNamed(String name) {
    return 'Good morning, $name 🌿';
  }

  @override
  String dailyProgramDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String dailyProgramRemaining(int count) {
    return '$count steps left';
  }

  @override
  String get dailyProgramRemainingZero => 'All steps done';

  @override
  String dailyProgramProgressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get dailyProgramDoneCta => 'Done ✅';

  @override
  String get dailyProgramChooseMood => 'Choose your mood';

  @override
  String get dailyProgramOpenEmotionWheel => 'Open Emotion Wheel';

  @override
  String get dailyProgramOpenCalmExercise => 'Open Calm Exercise';

  @override
  String get dailyProgramOpenSingleTask => 'Open Single Task';

  @override
  String get dailyProgramOpenWorryJournal => 'Open Worry Journal';

  @override
  String get dailyProgramSkip => 'Skip';

  @override
  String get dailyProgramAllStepsTitle => 'All steps today';

  @override
  String get dailyProgramCompleteTitle =>
      '🏁 You finished today\'s journey! Proud of you 💚';

  @override
  String get dailyProgramViewReport => 'See today\'s report';

  @override
  String get dailyProgramHomeIcon => '🌿';

  @override
  String get dailyProgramHomeTitle => 'My Daily Program';

  @override
  String get dailyProgramHomeStart => 'Start your day journey';

  @override
  String dailyProgramHomeInProgress(int count) {
    return '$count steps left';
  }

  @override
  String get dailyProgramHomeDone => 'You finished today\'s journey ✅';

  @override
  String get dailyProgramWaterSheetTitle =>
      '💧 Did you drink a glass of water?';

  @override
  String get dailyProgramWaterSheetSubtitle =>
      'Water helps your brain work better';

  @override
  String get dailyProgramWaterConfirm => 'Yes, I drank ✅';

  @override
  String get dailyProgramWaterLater => 'Not yet — I\'ll drink now';

  @override
  String get dailyProgramMovementSheetTitle => '🚶 Did you move today?';

  @override
  String get dailyProgramMovementSheetSubtitle =>
      'Even 5 minutes of walking helps';

  @override
  String get dailyProgramMovementConfirm => 'Yes ✅';

  @override
  String get dailyProgramMovementDoNow => 'I\'ll do it now';

  @override
  String get dailyProgramMovementSkipToday => 'Not able today';

  @override
  String get dayEndTitle => 'You finished your day 💚';

  @override
  String get dayEndSubtitle =>
      'Every step you took today brings you closer to mental clarity.';

  @override
  String get dayEndSummaryTitle => 'Your day summary';

  @override
  String get dayEndReflection0 =>
      'What was the best thing that happened today?';

  @override
  String get dayEndReflection1 => 'What do you want to do again tomorrow?';

  @override
  String get dayEndReflection2 => 'What did you feel today?';

  @override
  String get dayEndReflection3 => 'One thing you\'re grateful for today?';

  @override
  String get dayEndClosingMessage =>
      'Sleep well 🌙 Your brain will recharge tonight.';

  @override
  String get dayEndFinishButton => 'Close the day';

  @override
  String get sukoonTitle => 'Sukoon';

  @override
  String get sukoonIntro =>
      'Sit in stillness. Let your mind wander — think, drift, or think of nothing at all.\nScience shows these quiet moments restore your attention.';

  @override
  String get sukoonDurationLabel => 'Duration';

  @override
  String get sukoonDuration3 => '3 minutes';

  @override
  String get sukoonDuration5 => '5 minutes';

  @override
  String get sukoonDuration10 => '10 minutes';

  @override
  String get sukoonDuration15 => '15 minutes';

  @override
  String sukoonDurationOption(int minutes) {
    return '$minutes min';
  }

  @override
  String get sukoonStart => 'Start';

  @override
  String get sukoonPause => 'Pause';

  @override
  String get sukoonContinue => 'Continue';

  @override
  String get sukoonRestart => 'Start over';

  @override
  String get sukoonReset => 'Reset';

  @override
  String get sukoonInterruptedMessage =>
      'Stillness was interrupted — no problem. You can continue or start fresh 🌿';

  @override
  String sukoonCompleteTitle(int minutes) {
    return 'You finished $minutes minutes of stillness 🌿 Your mind rested.';
  }

  @override
  String get sukoonWanderHint => 'Where did your mind go? (optional)';

  @override
  String get sukoonSave => 'Save';

  @override
  String get sukoonSkip => 'Skip';
}
