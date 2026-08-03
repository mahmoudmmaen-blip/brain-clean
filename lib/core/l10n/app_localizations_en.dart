// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Brain Clean Dashboard';

  @override
  String get dashboardEmptyDiagnosticPrompt =>
      'Complete the diagnostic to see your BC_score.';

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
  String get emotionImpactDialogTitle => 'Impact on your recovery';

  @override
  String emotionImpactNegative(String emotion, String pct) {
    return 'Feeling $emotion will reduce your recovery by $pct%.\nLog it?';
  }

  @override
  String emotionImpactPositive(String emotion, String pct) {
    return 'Feeling $emotion will improve your recovery by $pct%.\nLog it?';
  }

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
  String get bciCardTitle => 'Brain Clarity Index';

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
  String get securityCompromisedBanner =>
      'Warning: this device may be compromised. Local data only — cloud sync is disabled.';

  @override
  String get brainCheckTitle => 'Brain Check';

  @override
  String get brainCheckIntroNonMedical =>
      'This is a self-check, not a medical diagnosis.';

  @override
  String get brainCheckStart => 'Start Brain Check';

  @override
  String get brainCheckContinue => 'Continue';

  @override
  String get brainCheckStartOver => 'Start over';

  @override
  String get brainCheckEmptyState => 'Start Brain Check to build your profile.';

  @override
  String brainCheckQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String brainCheckSectionProgress(int current, int total) {
    return 'Part $current of $total';
  }

  @override
  String get brainCheckComplete => 'Check complete';

  @override
  String get brainCheckResumeTitle => 'Continue your Brain Check?';

  @override
  String get brainCheckSaveError =>
      'Could not save your answers. They are still on this screen.';

  @override
  String get brainCheckLoading => 'Loading Brain Check…';

  @override
  String get brainCheckExit => 'Exit Brain Check';

  @override
  String get brainCheckBack => 'Back';

  @override
  String get brainCheckSaving => 'Saving…';

  @override
  String get brainCheckFinish => 'Finish check';

  @override
  String get brainCheckSelectAnswerHint => 'Choose an answer to continue.';

  @override
  String get brainCheckAutosaveHint =>
      'Your answers save on this device as you go.';

  @override
  String get brainCheckAnswerChoices => 'Answer choices';

  @override
  String get brainCheckAnswerSelected => 'Selected';

  @override
  String get brainCheckAnswerUnselected => 'Not selected';

  @override
  String get brainCheckAnswerYes => 'Yes';

  @override
  String get brainCheckAnswerNo => 'No';

  @override
  String get brainCheckLikert1 => 'Strongly disagree';

  @override
  String get brainCheckLikert2 => 'Disagree';

  @override
  String get brainCheckLikert3 => 'Neutral';

  @override
  String get brainCheckLikert4 => 'Agree';

  @override
  String get brainCheckLikert5 => 'Strongly agree';

  @override
  String get brainCheckFrequency1 => 'Never';

  @override
  String get brainCheckFrequency2 => 'Rarely';

  @override
  String get brainCheckFrequency3 => 'Sometimes';

  @override
  String get brainCheckFrequency4 => 'Often';

  @override
  String get brainCheckFrequency5 => 'Very often';

  @override
  String get brainCheckBreakTitle => 'A short pause';

  @override
  String brainCheckBreakBody(String sectionTitle) {
    return 'Next: $sectionTitle';
  }

  @override
  String get brainCheckCompletionBody =>
      'Thanks for finishing this self-report. Your check is ready to save on this device.';

  @override
  String get brainCheckConfigError =>
      'Brain Check questions are unavailable right now.';

  @override
  String get brainCheckRestartTitle => 'Start over?';

  @override
  String get brainCheckRestartBody =>
      'This clears your unfinished Brain Check answers on this device. Onboarding progress and past completed profiles stay untouched.';

  @override
  String get brainCheckRestartCancel => 'Keep going';

  @override
  String get brainCheckRestartConfirm => 'Start over';

  @override
  String get brainCheckCompleteBoundaryTitle => 'Brain Check saved';

  @override
  String get brainCheckCompleteBoundaryBody =>
      'Your self-report is stored on this device. Continue to build your Brain Profile snapshot.';

  @override
  String get brainCheckCompleteBoundaryContinue => 'Build Brain Profile';

  @override
  String get brainProfileTitle => 'Brain Profile';

  @override
  String get brainProfileBuilding => 'Building your Brain Profile…';

  @override
  String get brainProfileLoading => 'Loading Brain Profile';

  @override
  String get brainProfileMissing => 'No Brain Profile yet';

  @override
  String get brainProfileEmptyHint =>
      'Complete a Brain Check to create your first snapshot.';

  @override
  String get brainProfileUnavailable =>
      'Profile calculation is unavailable right now.';

  @override
  String get brainProfileRetry => 'Try again';

  @override
  String get brainProfileGoHome => 'Back to Home';

  @override
  String get brainProfileOrientation => 'A calm look at your snapshot';

  @override
  String get brainProfileScoreHeading => 'Recovery Score estimate';

  @override
  String get brainProfileScorePendingLabel => 'Estimate pending';

  @override
  String get brainProfileScorePendingSemantics =>
      'Recovery Score estimate is pending. Domain summaries are available from your answers.';

  @override
  String brainProfileScoreSemantics(String value) {
    return 'Recovery Score estimate: $value';
  }

  @override
  String get brainProfileConfidenceHeading => 'Confidence';

  @override
  String get brainProfileConfidenceProvisional => 'Provisional';

  @override
  String get brainProfileConfidenceModerate => 'Moderate';

  @override
  String get brainProfileConfidenceSolid => 'Strong';

  @override
  String get brainProfileBandHeading => 'Current band';

  @override
  String get brainProfileBandMeaning =>
      'A calm product label for this self-report estimate — not a clinical severity.';

  @override
  String get brainProfileMeansHeading => 'What this means';

  @override
  String get brainProfileMeansBody =>
      'This is a self-reported starting snapshot. It highlights stronger reported areas and current support priorities based on your Brain Check answers.';

  @override
  String get brainProfileDoesNotMeanHeading => 'What this does not mean';

  @override
  String get brainProfileScoreUnavailableLabel => 'Estimate unavailable';

  @override
  String get brainProfileScoreUnavailableSemantics =>
      'Recovery Score estimate is unavailable. No number is shown.';

  @override
  String get brainProfileScoreUnavailableBody =>
      'A Recovery Score could not be estimated from this check. Your answers remain saved. Complete a valid Brain Check to continue to a Recovery Plan.';

  @override
  String get brainProfileContinueUnavailable =>
      'A Recovery Plan needs a valid Recovery Score estimate.';

  @override
  String get brainProfileMissingEvent => 'Complete a Brain Check first.';

  @override
  String get brainProfileBuildingHint =>
      'Preparing your self-report snapshot on this device…';

  @override
  String get brainProfileDomainEstimateHeading => 'Current estimate';

  @override
  String get brainProfileDomainStrongerLabel => 'Stronger reported area';

  @override
  String get brainProfileDomainSupportLabel => 'Current support priority';

  @override
  String get brainProfileDomainNeutralLabel => 'Based on your current answers';

  @override
  String get brainProfileDomainBasedOnAnswers =>
      'Based on themes from your current Brain Check answers — not raw scores.';

  @override
  String get brainProfileDomainNonMedical =>
      'Not a medical diagnosis. Not brain-damage detection. Not an intelligence score.';

  @override
  String get brainProfileDomainPlanPreviewHint =>
      'A gentle Recovery Plan step may focus here next — that comes after you continue.';

  @override
  String get brainProfileDomainsHeading => 'Domain summary';

  @override
  String get brainProfileDomainNoData => 'No answers in this area yet';

  @override
  String brainProfileDomainMean(String value) {
    return 'Reported average: $value';
  }

  @override
  String get brainProfileDomainClose => 'Close';

  @override
  String get brainProfileExplainHeading => 'What this means';

  @override
  String get brainProfileContinue => 'Continue to Recovery Plan';

  @override
  String get brainProfileReadyTitle => 'Your Brain Profile is ready';

  @override
  String get brainProfileReadyBody =>
      'Your Recovery Plan is the next calm step when you continue from your Profile.';

  @override
  String get brainProfileHistoricalBadge => 'Earlier snapshot';

  @override
  String get recoveryPlanTitle => 'Recovery Plan';

  @override
  String get recoveryPlanBuilding => 'Building your Recovery Plan…';

  @override
  String get recoveryPlanLoading => 'Loading Recovery Plan';

  @override
  String get recoveryPlanReady => 'Your Recovery Plan is ready';

  @override
  String get recoveryPlanStarterReady => 'A calm starter plan is ready';

  @override
  String get recoveryPlanMissing => 'No Recovery Plan yet';

  @override
  String get recoveryPlanMissingProfile =>
      'Complete a Brain Check and Brain Profile first.';

  @override
  String get recoveryPlanScoreUnavailable =>
      'A full plan needs a valid Recovery Score estimate. A starter plan may still be available.';

  @override
  String get recoveryPlanUnsupportedVersion =>
      'This plan model is not supported on this version.';

  @override
  String get recoveryPlanGenerationError =>
      'Could not build your plan right now. Try again.';

  @override
  String get recoveryPlanRetry => 'Try again';

  @override
  String get recoveryPlanGoHome => 'Back to Home';

  @override
  String get recoveryPlanBuildCta => 'Build Recovery Plan';

  @override
  String get recoveryPlanMainFocus => 'Main focus';

  @override
  String get recoveryPlanPrioritiesHeading => 'Priority support';

  @override
  String get recoveryPlanNoPriorities =>
      'No priority domains in this starter plan';

  @override
  String get recoveryPlanStrongerHeading => 'Already helping';

  @override
  String get recoveryPlanConfidenceHeading => 'Confidence';

  @override
  String get recoveryPlanTimeHeading => 'Daily time';

  @override
  String recoveryPlanTimeRange(String min, String max) {
    return 'About $min–$max minutes';
  }

  @override
  String get recoveryPlanIntensityLabel => 'Intensity';

  @override
  String get recoveryPlanMinimumPath => 'Minimum path';

  @override
  String get recoveryPlanStandardPath => 'Standard path';

  @override
  String get recoveryPlanBecauseHeading => 'Why this plan today';

  @override
  String get recoveryPlanTodayPreview => 'Today preview';

  @override
  String get recoveryPlanContinueToday => 'Continue to Today';

  @override
  String get recoveryPlanSkipHint =>
      'Skipping a step never counts as a penalty.';

  @override
  String get recoveryPlanOptionalTag => 'optional';

  @override
  String get recoveryPlanNoSteps => 'No steps listed';

  @override
  String get recoveryPlanStarterBadge => 'Starter plan';

  @override
  String get recoveryPlanTodayReadyTitle => 'Today is ready to begin';

  @override
  String get recoveryPlanTodayReadyBody =>
      'Your daily session player arrives in a later step. Your Recovery Plan is saved on this device.';

  @override
  String get recoveryPlanCalmOrientation => 'Your Recovery Plan';

  @override
  String get recoveryPlanCalmOrientationBody =>
      'This plan is a practical estimate based on your current Brain Profile. It is not a diagnosis or treatment. You can adjust it later.';

  @override
  String get recoveryPlanFitsProfile =>
      'It matches the priorities in your current profile estimate.';

  @override
  String get v2TodayPreviewTitle => 'Your first Today';

  @override
  String get v2TodayPreviewLoading => 'Loading Today preview';

  @override
  String get v2TodayPreviewHeading => 'Today preview';

  @override
  String get v2TodayPreviewOrientation =>
      'Your day starts with one clear step. Completing it later will mark the day on your plan.';

  @override
  String get v2TodayPreviewActHeading => 'First step';

  @override
  String get v2TodayPreviewFallbackTitle => 'Today’s practice';

  @override
  String get v2TodayPreviewBecauseHeading => 'Why this step today';

  @override
  String get v2TodayPreviewCompletionMeaning =>
      'Finishing this step later will count as your day done. Skipping stays allowed with no penalty.';

  @override
  String get v2TodayPreviewContinueCta => 'Continue — first step ready';

  @override
  String get v2TodayPreviewMissingAct =>
      'Today’s step is not available yet. Rebuild your Recovery Plan.';

  @override
  String get v2TodayReadyLoading => 'Preparing your first step';

  @override
  String get v2TodayReadyFirstStepTitle => 'Your first step is ready';

  @override
  String get v2TodayReadyFirstStepBody =>
      'Your Recovery Plan is saved. Open Today to begin your first daily session when you are ready. You can leave and return without losing progress.';

  @override
  String get v2TodayReadyJourneySaved =>
      'First-time setup is complete on this device.';

  @override
  String get v2TodayReadyProgressSaved =>
      'Your progress is saved on this device.';

  @override
  String get v2TodayReadyPrimaryCta => 'Open Today';

  @override
  String get v2TodayReadyReviewPreview => 'Review Today preview';

  @override
  String get v2TodayReadyCorruptPlan =>
      'This plan could not be read safely. Rebuild it calmly when you are ready.';

  @override
  String get v2TodayReadyPersistFailed =>
      'Could not save progress right now. Try again.';

  @override
  String get v2TodayHomeTitle => 'Today';

  @override
  String get v2TodayHomeLoading => 'Loading Today';

  @override
  String get v2TodayHomeOrientation => 'Your day';

  @override
  String get v2TodayHomeOrientationBody =>
      'One clear action from your Recovery Plan. Nothing extra.';

  @override
  String get v2TodayHomeStandardPathHint =>
      'The standard path adds approved optional depth when you want it.';

  @override
  String get v2TodayHomeStatusHeading => 'Status';

  @override
  String get v2TodayHomeStatusReady => 'Ready when you are';

  @override
  String get v2TodayHomeStatusInProgress => 'Session in progress';

  @override
  String get v2TodayHomeStatusReflect => 'Almost done — finish check-in';

  @override
  String get v2TodayHomeStatusDone => 'Done for today';

  @override
  String get v2TodayHomeStatusPartial => 'Attempt saved — no penalty';

  @override
  String get v2TodayHomeCtaStart => 'Start today’s session';

  @override
  String get v2TodayHomeCtaContinue => 'Continue session';

  @override
  String get v2TodayHomeCtaViewCompleted => 'View completed session';

  @override
  String get v2TodayHomeViewPlan => 'View Recovery Plan';

  @override
  String get v2SessionPrepareTitle => 'Prepare';

  @override
  String get v2SessionPreparePurpose =>
      'A short guided practice from your plan.';

  @override
  String get v2SessionPrepareIncludes => 'This session includes:';

  @override
  String get v2SessionPathHeading => 'Choose your path';

  @override
  String get v2SessionPathNoShame =>
      'Minimum is complete and useful. Standard adds optional depth.';

  @override
  String get v2SessionA11yHint =>
      'Each step offers an accessibility alternative.';

  @override
  String get v2SessionStartCta => 'Start';

  @override
  String get v2SessionClose => 'Close';

  @override
  String get v2SessionActTitle => 'Today’s Session';

  @override
  String v2SessionProgress(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get v2SessionOptionalLabel => 'Optional';

  @override
  String get v2SessionRequiredLabel => 'Required';

  @override
  String get v2SessionStartTimer => 'Start optional timer';

  @override
  String v2SessionTimerContext(String seconds) {
    return 'About $seconds seconds left on the optional timer';
  }

  @override
  String get v2SessionMarkDone => 'Mark step done';

  @override
  String get v2SessionSkipOptional => 'Skip optional step';

  @override
  String get v2SessionEndEarly => 'End and check in';

  @override
  String get v2SessionReflectTitle => 'Quick check-in';

  @override
  String get v2SessionReflectPrompt => 'How did today’s session feel?';

  @override
  String get v2SessionReflectManageable => 'How manageable was it?';

  @override
  String get v2SessionReflectHelped => 'Did it help you pause or focus?';

  @override
  String get v2SessionReflectObstacle => 'Any obstacle? (optional)';

  @override
  String get v2SessionChipEasy => 'Manageable';

  @override
  String get v2SessionChipOk => 'Okay';

  @override
  String get v2SessionChipHard => 'Hard';

  @override
  String get v2SessionChipYes => 'Yes';

  @override
  String get v2SessionChipSomewhat => 'Somewhat';

  @override
  String get v2SessionChipNotYet => 'Not yet';

  @override
  String get v2SessionChipNone => 'None';

  @override
  String get v2SessionChipDistraction => 'Distraction';

  @override
  String get v2SessionChipLowEnergy => 'Low energy';

  @override
  String get v2SessionChipTime => 'Time';

  @override
  String get v2SessionReflectSave => 'Save check-in';

  @override
  String get v2SessionReflectSkipChips => 'Continue without chips';

  @override
  String get v2SessionSaving => 'Saving…';

  @override
  String get v2SessionLeaveSuccess => 'Well done — you’re done for today';

  @override
  String get v2SessionLeavePartial => 'You paused with care — nothing was lost';

  @override
  String v2SessionLeavePath(String path) {
    return 'Path: $path';
  }

  @override
  String get v2SessionLeaveBody =>
      'Quiet competence is enough. Leave the app when you are ready.';

  @override
  String get v2SessionLeaveNext =>
      'Tomorrow, Today will offer one clear next step again.';

  @override
  String get v2SessionLeaveCta => 'Back to Today';

  @override
  String get v2ProgressEmptyTitle => 'No progress yet';

  @override
  String get v2ProgressEmptyBody =>
      'Complete a Today session to start building an honest local record. Nothing is invented when history is empty.';

  @override
  String get v2ProgressLoading => 'Loading progress';

  @override
  String get v2ProgressPersistFailed =>
      'Could not save progress right now. Try again.';

  @override
  String get v2ProgressStatsSessions => 'Sessions completed';

  @override
  String get v2ProgressStatsMinimum => 'Minimum path sessions';

  @override
  String get v2ProgressStatsStandard => 'Standard path sessions';

  @override
  String get v2ProgressStatsRate => 'Completed-day rate';

  @override
  String get v2ProgressStatsCurrentStreak => 'Current completed-day run';

  @override
  String get v2ProgressStatsLongestStreak => 'Longest completed-day run';

  @override
  String get v2OnboardingLoading => 'Loading…';

  @override
  String get v2OnboardingContinue => 'Continue';

  @override
  String get v2OnboardingBack => 'Back';

  @override
  String get v2OnboardingRetry => 'Try again';

  @override
  String get v2OnboardingRestart => 'Start onboarding again';

  @override
  String get v2OnboardingGoHome => 'Back to Home';

  @override
  String v2OnboardingProgressLabel(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String v2OnboardingProgressSemantics(String current, String total) {
    return 'Onboarding step $current of $total';
  }

  @override
  String get v2OnboardingLanguageArabic => 'العربية';

  @override
  String get v2OnboardingLanguageEnglish => 'English';

  @override
  String get v2OnboardingWelcomeTitle => 'Welcome to Brain Clean';

  @override
  String get v2OnboardingWelcomeBody =>
      'Brain Clean helps you estimate your current recovery state, build a personalized recovery plan, and observe change over time — calmly, and without medical claims.';

  @override
  String get v2OnboardingExpectationsTitle => 'What to expect';

  @override
  String get v2OnboardingExpectationsBody =>
      'A short, honest path — not a diagnosis and not a guarantee.';

  @override
  String get v2OnboardingExpectation1 =>
      'A brief daily Session when you are ready — about five minutes.';

  @override
  String get v2OnboardingExpectation2 =>
      'A self-report Brain Check that is not a medical diagnosis.';

  @override
  String get v2OnboardingExpectation3 =>
      'A practical plan you can understand, with progress you can observe over time.';

  @override
  String get v2OnboardingExpectationsFootnote =>
      'Results are not guaranteed. Progress can ebb and flow.';

  @override
  String get v2OnboardingConsentTitle => 'Before you continue';

  @override
  String get v2OnboardingConsentBody =>
      'Please confirm you understand how Brain Clean is meant to be used.';

  @override
  String get v2OnboardingConsentNonMedical =>
      'I understand Brain Clean is not a medical diagnosis, clinical assessment, or treatment.';

  @override
  String get v2OnboardingConsentTerms =>
      'I agree to continue with the app’s terms of use.';

  @override
  String get v2OnboardingConsentAnalytics =>
      'Optional: allow anonymous product usage signals (off by default).';

  @override
  String get v2OnboardingConsentHint =>
      'Select the required boxes to continue.';

  @override
  String get v2OnboardingPrivacyTitle => 'Your data on this device';

  @override
  String get v2OnboardingPrivacyBody =>
      'Core Brain Check answers, Recovery Score, and Recovery Plan are calculated and stored locally on this device. You can pause and resume a Brain Check. Explanations stay reviewable. The score is not generated by AI.';

  @override
  String get v2OnboardingPrivacyFootnote =>
      'Some optional product features may use the network later (for example sync, support, or ads when enabled). Continuing works offline.';

  @override
  String get v2OnboardingPrivacyPolicyLink => 'Privacy summary';

  @override
  String get v2OnboardingPrivacyCachedSummary =>
      'Brain Clean keeps your core check and plan data local-first. Optional cloud or network features are separate and not required to finish this onboarding. This is not a medical privacy certification.';

  @override
  String get v2OnboardingRitualTitle =>
      'When would a short Session usually fit?';

  @override
  String get v2OnboardingRitualBody =>
      'Choose a gentle window as a reminder cue. You can change this later.';

  @override
  String get v2OnboardingRitualMorning => 'Morning';

  @override
  String get v2OnboardingRitualAfternoon => 'Afternoon';

  @override
  String get v2OnboardingRitualEvening => 'Evening';

  @override
  String get v2OnboardingRitualDecideLater => 'Decide later';

  @override
  String get v2OnboardingCheckIntroTitle => 'Brain Check';

  @override
  String get v2OnboardingCheckIntroBody =>
      'Brain Check is a short self-report. It is not a medical diagnosis, not brain-damage detection, and not an intelligence test. Your answers stay on this device and help build a practical plan.';

  @override
  String get v2OnboardingCheckIntroMeta =>
      'Lite Check · about a few minutes · resumable';

  @override
  String get v2OnboardingStartBrainCheck => 'Start Brain Check';

  @override
  String get v2OnboardingCorruptTitle => 'Let’s start fresh';

  @override
  String get v2OnboardingCorruptBody =>
      'Saved onboarding could not be read safely. Your Brain Check answers were not deleted. You can begin onboarding again.';

  @override
  String get v2BrainCheckEntryTitle => 'Brain Check';

  @override
  String get v2BrainCheckEntryLoading => 'Preparing Brain Check…';

  @override
  String get v2BrainCheckEntryBody =>
      'A calm self-report to help estimate your current recovery state.';

  @override
  String get v2BrainCheckEntryNonMedical =>
      'Not a medical diagnosis. Not treatment. Not a measure of intelligence.';

  @override
  String get v2BrainCheckEntryDuration =>
      'Lite Check · short · you can pause anytime';

  @override
  String get v2BrainCheckEntryStart => 'Start Brain Check';

  @override
  String get v2BrainCheckEntryResume => 'Resume Brain Check';

  @override
  String get v2BrainCheckEntryResumeHint =>
      'You have an unfinished Brain Check on this device.';

  @override
  String get v2BrainCheckEntryStartOver => 'Start over';

  @override
  String get v2BrainCheckEntryAlreadyComplete =>
      'A Brain Check is already complete. Starting again is available from later product steps — answers were not wiped.';

  @override
  String get v2BrainCheckEntryError =>
      'Could not prepare Brain Check right now.';

  @override
  String get v2BrainCheckReadyTitle => 'Brain Check is ready';

  @override
  String get v2BrainCheckReadyBody =>
      'Your Brain Check entry is ready. Continue when you want to open or resume the questionnaire.';

  @override
  String get v2WeeklyReviewTitle => 'Weekly Review';

  @override
  String get v2WeeklySummaryTitle => 'Weekly Summary';

  @override
  String get v2WeeklyReviewLoading => 'Loading Weekly Review';

  @override
  String get v2WeeklyReviewExit => 'Exit';

  @override
  String get v2WeeklyReviewBack => 'Back';

  @override
  String get v2WeeklyReviewContinue => 'Continue';

  @override
  String get v2WeeklyReviewComplete => 'Complete review';

  @override
  String get v2WeeklyReviewRetry => 'Try again';

  @override
  String get v2WeeklyReviewBackToday => 'Back to Today';

  @override
  String get v2WeeklyReviewSaveFailed =>
      'Could not save your review right now. Try again.';

  @override
  String get v2WeeklyReviewUnsupported =>
      'This review format is not supported on this version.';

  @override
  String get v2WeeklyReviewNotReadyGeneric => 'Weekly Review is not ready yet';

  @override
  String get v2WeeklyReviewNotReadyGenericBody =>
      'Come back after a completed week with at least one finished session.';

  @override
  String get v2WeeklyReviewNotReadyZeroTitle =>
      'Not enough completed activity yet';

  @override
  String get v2WeeklyReviewNotReadyZeroBody =>
      'Finish at least one Today session in a completed week to open Weekly Review.';

  @override
  String get v2WeeklyReviewNotReadyCurrentTitle =>
      'This week is still in progress';

  @override
  String get v2WeeklyReviewNotReadyCurrentBody =>
      'Weekly Review opens after the week ends. Keep going with Today when you are ready.';

  @override
  String get v2WeeklyReviewNotReadyMissingTitle =>
      'Review sources are not ready';

  @override
  String get v2WeeklyReviewNotReadyMissingBody =>
      'A local plan, profile, or progress record is missing. Continue through Today and return later.';

  @override
  String v2WeeklyReviewPeriodLabel(String start, String end) {
    return 'Period $start – $end';
  }

  @override
  String v2WeeklyReviewProgress(String current, String total) {
    return 'Question $current of $total';
  }

  @override
  String v2WeeklyReviewProgressSemantics(String current, String total) {
    return 'Weekly Review question $current of $total';
  }

  @override
  String get v2WeeklyReviewRequired => 'Required';

  @override
  String get v2WeeklyReviewMultiSelectHint => 'Optional. Choose up to two.';

  @override
  String get v2WeeklyReviewValidationHint =>
      'Please choose a valid response to continue.';

  @override
  String get v2WeeklyReviewYes => 'Yes';

  @override
  String get v2WeeklyReviewNo => 'No';

  @override
  String get v2WeeklyReviewQManageability =>
      'How manageable did the plan feel this week?';

  @override
  String get v2WeeklyReviewQPauseFocus =>
      'How much did the sessions help you pause or focus?';

  @override
  String get v2WeeklyReviewQObstacle => 'What got in the way most often?';

  @override
  String get v2WeeklyReviewQSupport => 'What supported you? (optional)';

  @override
  String get v2WeeklyReviewQAccessibility =>
      'Did you use an accessibility alternative this week? (optional)';

  @override
  String get v2WeeklyReviewOptTooLight => 'Too light';

  @override
  String get v2WeeklyReviewOptAboutRight => 'About right';

  @override
  String get v2WeeklyReviewOptTooDemanding => 'Too demanding';

  @override
  String get v2WeeklyReviewOptTime => 'Time';

  @override
  String get v2WeeklyReviewOptForgetfulness => 'Forgetfulness';

  @override
  String get v2WeeklyReviewOptLowEnergy => 'Low energy';

  @override
  String get v2WeeklyReviewOptInterruptions => 'Interruptions';

  @override
  String get v2WeeklyReviewOptUnclearStep => 'Unclear step';

  @override
  String get v2WeeklyReviewOptAccessEnv => 'Access or environment';

  @override
  String get v2WeeklyReviewOptNoMajorObstacle => 'No major obstacle';

  @override
  String get v2WeeklyReviewOptShorterPath => 'Shorter path';

  @override
  String get v2WeeklyReviewOptClearerTiming => 'Clearer timing';

  @override
  String get v2WeeklyReviewOptQuieterEnv => 'Quieter environment';

  @override
  String get v2WeeklyReviewOptA11yAlt => 'Accessibility alternative';

  @override
  String get v2WeeklyReviewOptStrongerReminder => 'Stronger reminder';

  @override
  String get v2WeeklyReviewOptSamePlan => 'Same plan is working';

  @override
  String get v2WeeklySummaryOrientation => 'This week’s pattern';

  @override
  String v2WeeklySummaryCompletedDays(String count) {
    return 'Completed days: $count';
  }

  @override
  String v2WeeklySummaryPathMix(String label) {
    return 'Path mix: $label';
  }

  @override
  String get v2WeeklySummaryPathMostlyMinimum => 'Mostly minimum';

  @override
  String get v2WeeklySummaryPathMostlyStandard => 'Mostly standard';

  @override
  String get v2WeeklySummaryPathBalanced => 'Balanced';

  @override
  String get v2WeeklySummaryPathSingle => 'Single session only';

  @override
  String get v2WeeklySummaryPatternHeading => 'Rhythm';

  @override
  String get v2WeeklySummaryRhythmSteady => 'Steady across several days';

  @override
  String get v2WeeklySummaryRhythmIntermittent =>
      'Intermittent across the week';

  @override
  String get v2WeeklySummaryRhythmLimited => 'Limited history';

  @override
  String get v2WeeklySummaryObstacleHeading => 'What got in the way';

  @override
  String get v2WeeklySummarySupportHeading => 'What supported you';

  @override
  String get v2WeeklySummarySupportNone => 'No support noted';

  @override
  String get v2WeeklySummaryAttentionHeading => 'What may deserve attention';

  @override
  String get v2WeeklySummaryAttentionLoad =>
      'Load may deserve a closer look later';

  @override
  String get v2WeeklySummaryAttentionSupport =>
      'A bit more support may deserve attention later';

  @override
  String get v2WeeklySummaryAttentionPause =>
      'Pause or focus felt low this week';

  @override
  String get v2WeeklySummaryAttentionObstacle =>
      'An obstacle stood out this week';

  @override
  String get v2WeeklySummaryAttentionMaintain =>
      'Keep observing with the current plan';

  @override
  String get v2WeeklySummaryEvidenceLimited =>
      'Limited evidence — one completed session only';

  @override
  String get v2WeeklySummaryEvidenceDeveloping =>
      'Early evidence — treat this as a quiet look-back';

  @override
  String get v2WeeklySummaryEvidenceSufficient =>
      'Summary only — not a cause claim';

  @override
  String get v2WeeklySummaryPlanUnchanged => 'Your plan has not changed yet';

  @override
  String get v2WeeklySummaryCtaToday => 'Back to Today';

  @override
  String get v2WeeklySummaryCtaProgress => 'Back to Progress';

  @override
  String get v2ProgressTitle => 'Progress';

  @override
  String get v2ProgressOrientation => 'Your progress';

  @override
  String get v2ProgressRetry => 'Try again';

  @override
  String get v2ProgressBasedOnSessions =>
      'Progress is based on completed sessions';

  @override
  String get v2ProgressHeadlineEmpty => 'No completed sessions yet';

  @override
  String get v2ProgressHeadlineFirst =>
      'Your first completed session is recorded';

  @override
  String get v2ProgressHeadlineFew => 'A few completed days are on record';

  @override
  String get v2ProgressHeadlineRhythm => 'A pattern is beginning to appear';

  @override
  String get v2ProgressHeadlineSteady => 'A steadier pattern is visible';

  @override
  String get v2ProgressHeadlineLimited => 'Evidence is still limited';

  @override
  String get v2ProgressHeadlineWeekly =>
      'Weekly evidence is available to review';

  @override
  String get v2ProgressBetterHeading => 'What is recorded';

  @override
  String get v2ProgressWhyHeading => 'What the pattern shows';

  @override
  String get v2ProgressComparedHeading => 'How it compares over time';

  @override
  String v2ProgressCompletedDays(String count) {
    return 'Completed days: $count';
  }

  @override
  String v2ProgressCompletedSessions(String count) {
    return 'Completed sessions: $count';
  }

  @override
  String v2ProgressMinimumPath(String count) {
    return 'Minimum path: $count';
  }

  @override
  String v2ProgressStandardPath(String count) {
    return 'Standard path: $count';
  }

  @override
  String v2ProgressCompletionRate(String percent) {
    return 'Completed-day rate: $percent%';
  }

  @override
  String v2ProgressCurrentRhythm(String count) {
    return 'Current rhythm: $count day(s)';
  }

  @override
  String v2ProgressLongestRhythm(String count) {
    return 'Longest rhythm: $count day(s)';
  }

  @override
  String v2ProgressFirstCompleted(String day) {
    return 'First completed day: $day';
  }

  @override
  String v2ProgressLastCompleted(String day) {
    return 'Last completed day: $day';
  }

  @override
  String get v2ProgressRecentActivity => 'Recent activity';

  @override
  String get v2ProgressTimelineMinimum => 'Minimum path';

  @override
  String get v2ProgressTimelineStandard => 'Standard path';

  @override
  String get v2ProgressTimelineBothPaths => 'Minimum and standard';

  @override
  String v2ProgressTimelineEntry(String day, String path) {
    return '$day · $path';
  }

  @override
  String get v2ProgressPathMostlyMinimum => 'Mostly minimum path';

  @override
  String get v2ProgressPathMostlyStandard => 'Mostly standard path';

  @override
  String get v2ProgressPathBalanced => 'Balanced path mix';

  @override
  String get v2ProgressPathSingle => 'Single session only';

  @override
  String get v2ProgressEvidenceEmpty =>
      'Complete today’s action first to begin an honest record.';

  @override
  String get v2ProgressEvidenceLimited =>
      'Evidence is still limited — one completed action so far.';

  @override
  String get v2ProgressEvidenceDeveloping =>
      'A pattern is beginning to appear. This is observation, not a diagnosis.';

  @override
  String get v2ProgressEvidenceSufficient =>
      'Enough completed activity for a quiet look-back. No cause claim.';

  @override
  String get v2ProgressScoreHeading => 'Recovery Score snapshot';

  @override
  String v2ProgressScoreValue(String value) {
    return 'Estimate: $value';
  }

  @override
  String get v2ProgressScoreUnavailable =>
      'Score estimate not available on this device yet';

  @override
  String v2ProgressScoreMeasured(String day) {
    return 'From Brain Check on $day';
  }

  @override
  String get v2ProgressScoreDisclaimer =>
      'Daily session completion does not instantly change this score. The score comes from Brain Check measurement, not from counting sessions.';

  @override
  String get v2ProgressWeeklyReviewHeading => 'Weekly Review';

  @override
  String get v2ProgressWrNotEnough =>
      'Not enough completed activity yet for a Weekly Review.';

  @override
  String get v2ProgressWrCurrentWeek =>
      'This week is still in progress. Review opens after the week ends.';

  @override
  String get v2ProgressWrAvailable => 'Weekly Review available';

  @override
  String get v2ProgressWrDraft => 'Weekly Review draft in progress';

  @override
  String get v2ProgressWrCompleted => 'Weekly Summary available';

  @override
  String get v2ProgressWrUnsupported =>
      'This review format is not supported on this version.';

  @override
  String get v2ProgressWrMissingRefs =>
      'Review sources are not ready yet. Continue through Today and return later.';

  @override
  String get v2ProgressWrError =>
      'Weekly Review could not be prepared right now.';

  @override
  String get v2ProgressWrCtaStart => 'Start Weekly Review';

  @override
  String get v2ProgressWrCtaContinue => 'Continue Weekly Review';

  @override
  String get v2ProgressWrCtaSummary => 'View Weekly Summary';

  @override
  String get v2ProgressWeeklyPreviewHeading => 'Latest Weekly Summary';

  @override
  String get v2ProgressCtaToday => 'Complete today’s action first';

  @override
  String get v2ProgressCtaContinueToday => 'Back to Today';

  @override
  String get v2ProgressReportsEntry => 'Open Reports';

  @override
  String get v2ReportsTitle => 'Reports';

  @override
  String get v2ReportsEvidenceOverview => 'Evidence overview';

  @override
  String get v2ReportsWeeklyHistory => 'Weekly history';

  @override
  String get v2ReportsWeeklyReport => 'Weekly report';

  @override
  String get v2ReportsMeasurementHistory => 'Measurement history';

  @override
  String get v2ReportsEvidenceStillDeveloping =>
      'Your evidence is still developing';

  @override
  String get v2ReportsNotEnoughMeasurements =>
      'Not enough measurements to compare yet';

  @override
  String get v2ReportsComparedWithEarlier => 'Compared with your earlier check';

  @override
  String get v2ReportsSelfReportEstimate => 'This is a self-report estimate';

  @override
  String get v2ReportsNoCauseFromHistory =>
      'No cause can be determined from this history';

  @override
  String get v2ReportsOrientation =>
      'Reports gather honest local proof from completed sessions, weekly summaries, and valid self-report measurements.';

  @override
  String get v2ReportsOrientationNot =>
      'Reports are not a diagnosis, not medical advice, and not a comparison with other people.';

  @override
  String get v2ReportsLoading => 'Loading reports';

  @override
  String get v2ReportsRetry => 'Try again';

  @override
  String get v2ReportsPersistFailed =>
      'Could not load reports right now. Try again.';

  @override
  String get v2ReportsUnsupported =>
      'This report format is not supported on this version.';

  @override
  String get v2ReportsEmptyBody =>
      'Complete a Today session to begin an honest local evidence record. Nothing is invented when history is empty.';

  @override
  String get v2ReportsSnapshotMissing =>
      'A saved progress snapshot is missing. Showing counts rebuilt from completed sessions only.';

  @override
  String get v2ReportsDepthNoEvidence => 'No evidence yet';

  @override
  String get v2ReportsDepthEarly => 'Early evidence';

  @override
  String get v2ReportsDepthDeveloping => 'Developing evidence';

  @override
  String get v2ReportsDepthEstablished => 'Established history';

  @override
  String get v2ReportsDepthNoEvidenceExplain =>
      'No completed sessions are on record yet.';

  @override
  String get v2ReportsDepthDevelopingExplain =>
      'Completed days and weekly summaries are building a clearer local record.';

  @override
  String get v2ReportsDepthEstablishedExplain =>
      'Multiple weekly summaries and measurements form a longer local history.';

  @override
  String get v2ReportsSessionSummaryHeading => 'Completed activity';

  @override
  String v2ReportsCompletedSessions(String count) {
    return 'Completed sessions: $count';
  }

  @override
  String v2ReportsCompletedDays(String count) {
    return 'Completed days: $count';
  }

  @override
  String v2ReportsMinimumPath(String count) {
    return 'Minimum path: $count';
  }

  @override
  String v2ReportsStandardPath(String count) {
    return 'Standard path: $count';
  }

  @override
  String v2ReportsCurrentRhythm(String count) {
    return 'Current rhythm: $count day(s)';
  }

  @override
  String v2ReportsLongestRhythm(String count) {
    return 'Longest rhythm: $count day(s)';
  }

  @override
  String v2ReportsFirstCompleted(String day) {
    return 'First completed day: $day';
  }

  @override
  String v2ReportsLastCompleted(String day) {
    return 'Last completed day: $day';
  }

  @override
  String get v2ReportsMeasurementStatusHeading => 'Measurement history status';

  @override
  String get v2ReportsMeasurementNone => 'No valid measurements yet';

  @override
  String get v2ReportsMeasurementNoneBody =>
      'A completed Brain Check creates a self-report measurement you can review here.';

  @override
  String get v2ReportsMeasurementBaseline =>
      'One baseline measurement is on record';

  @override
  String get v2ReportsMeasurementComparable =>
      'Comparable measurements are available';

  @override
  String get v2ReportsMeasurementIncompatible =>
      'Measurements exist but are not comparable yet';

  @override
  String get v2ReportsMeasurementErrorBody =>
      'Measurement history could not be prepared right now.';

  @override
  String v2ReportsLatestScore(String value) {
    return 'Latest estimate: $value';
  }

  @override
  String get v2ReportsNoArtifacts => 'No weekly reports yet';

  @override
  String v2ReportsWeeklyReportPeriod(String start, String end) {
    return 'Week $start – $end';
  }

  @override
  String v2ReportsPremiumArchiveHint(String count) {
    return '$count older report(s) available with Premium archive';
  }

  @override
  String get v2ReportsPremiumGatedTitle => 'Older archive';

  @override
  String get v2ReportsPremiumGatedBody =>
      'Your latest and previous weekly reports stay free. Older archive depth is part of Premium. Current proof is never hidden.';

  @override
  String get v2ReportsArtifactMissing => 'Weekly report not found';

  @override
  String get v2ReportsArtifactMissingBody =>
      'This weekly report is missing or unavailable. Return to Reports.';

  @override
  String get v2ReportsArtifactUnsupportedBody =>
      'This weekly report format is not supported on this version.';

  @override
  String get v2ReportsArtifactCorrupt => 'Weekly report could not be read';

  @override
  String get v2ReportsArtifactCorruptBody =>
      'This weekly report looks incomplete. Return to Reports.';

  @override
  String get v2ReportsCtaLatestArtifact => 'Open latest weekly report';

  @override
  String get v2ReportsOpenMeasurementHistory => 'Open measurement history';

  @override
  String get v2ReportsCtaToday => 'Complete today’s action first';

  @override
  String get v2ReportsBackProgress => 'Back to Progress';

  @override
  String get v2ReportsBackOverview => 'Back to Reports';

  @override
  String get v2ReportsComparisonHigher =>
      'Your latest self-report estimate is higher than your earlier one.';

  @override
  String get v2ReportsComparisonLower =>
      'Your latest self-report estimate is lower than your earlier one.';

  @override
  String get v2ReportsComparisonUnchanged =>
      'Your latest self-report estimate is unchanged from your earlier one.';

  @override
  String get v2ReportsComparisonNotComparable =>
      'These measurements are not comparable with each other.';

  @override
  String get v2ReportsTooEarlyToInterpret =>
      'It may be too early to interpret this change.';

  @override
  String get v2ReportsLowConfidenceQualifier =>
      'At least one measurement has higher uncertainty.';

  @override
  String get v2ReportsMeasurementListHeading => 'Your measurements';

  @override
  String v2ReportsMeasuredOn(String day) {
    return 'Measured on $day';
  }

  @override
  String v2ReportsScoreValue(String value) {
    return 'Estimate: $value';
  }

  @override
  String v2ReportsScoreBand(String band) {
    return 'Band: $band';
  }

  @override
  String v2ReportsScoreConfidence(String confidence) {
    return 'Confidence: $confidence';
  }

  @override
  String v2ReportsMeasurementSemantics(
      String day, String score, String confidence) {
    return 'Measurement on $day, estimate $score, confidence $confidence';
  }

  @override
  String get v2ReportsConfidenceStrong => 'Strong';

  @override
  String get v2ReportsConfidenceModerate => 'Moderate';

  @override
  String get v2ReportsConfidenceProvisional => 'Provisional';

  @override
  String get v2ReportsDomainHistoryHeading => 'Domain history';

  @override
  String get v2ReportsDomainLatestOnly =>
      'Latest domain snapshot only — not enough comparable domain history yet.';

  @override
  String v2ReportsDomainRow(String title, String value) {
    return '$title: $value';
  }

  @override
  String v2ReportsDomainHistoryRow(String title, String day, String value) {
    return '$title on $day: $value';
  }

  @override
  String get v2NavHome => 'Home';

  @override
  String get v2NavToday => 'Today';

  @override
  String get v2NavCheck => 'Brain Check';

  @override
  String get v2NavPlan => 'Plan';

  @override
  String get v2NavProgress => 'Progress';

  @override
  String get v2NavReports => 'Reports';

  @override
  String get v2NavProfile => 'Profile';

  @override
  String get v2NavRecoverHome => 'Back to Home';

  @override
  String get v2NavRouteNotFound => 'This page could not be found';

  @override
  String get v2PremiumTitle => 'Premium';

  @override
  String get v2PremiumOrientation =>
      'Premium deepens continuity after you have already made progress — it does not unlock recovery.';

  @override
  String get v2PremiumFreeCoreReassurance =>
      'Your Free core remains available.';

  @override
  String get v2PremiumCurrentProgressRemains =>
      'Your current progress remains available.';

  @override
  String get v2PremiumFourCapitalsHeading => 'What Premium adds';

  @override
  String get v2PremiumContinuity => 'Continuity';

  @override
  String get v2PremiumContinuityBody =>
      'Deeper WeeklyArtifact archive and long-horizon evidence history.';

  @override
  String get v2PremiumInterpretation => 'Interpretation';

  @override
  String get v2PremiumInterpretationBody =>
      'Additional deterministic context layers only — never medical AI claims.';

  @override
  String get v2PremiumFit => 'Fit';

  @override
  String get v2PremiumFitBody =>
      'Future approved adaptation depth without silent Plan changes.';

  @override
  String get v2PremiumSupport => 'Support';

  @override
  String get v2PremiumSupportBody =>
      'Future continuity support under a separate contract — never Premium-only crisis care.';

  @override
  String get v2PremiumBenefitsBody =>
      'Premium currently deepens older Reports archive access. Latest and previous proof stay Free.';

  @override
  String get v2PremiumViewPlans => 'View plans';

  @override
  String get v2PremiumRestorePurchases => 'Restore purchases';

  @override
  String get v2PremiumPurchaseInProgress => 'Purchase in progress';

  @override
  String get v2PremiumPurchaseCompleted => 'Purchase completed';

  @override
  String get v2PremiumPurchaseCancelled => 'Purchase cancelled';

  @override
  String get v2PremiumPurchaseFailed =>
      'Purchase failed. You can try again or restore purchases.';

  @override
  String get v2PremiumPurchasePending => 'Purchase pending';

  @override
  String get v2PremiumNoPlansAvailable => 'No plans available right now.';

  @override
  String get v2PremiumStoreUnavailable => 'Store unavailable';

  @override
  String get v2PremiumRestored => 'Restored';

  @override
  String get v2PremiumNothingToRestore => 'Nothing to restore';

  @override
  String get v2PremiumRestoreFailed =>
      'Restore failed. You can try again later.';

  @override
  String get v2PremiumRestoring => 'Restoring purchases';

  @override
  String get v2PremiumSubscriptionExpired => 'Subscription expired';

  @override
  String get v2PremiumDeeperHistory => 'Deeper history';

  @override
  String get v2PremiumOlderArchive => 'Older archive';

  @override
  String get v2PremiumManage => 'Manage Premium';

  @override
  String get v2PremiumAlreadyActive => 'Premium is active';

  @override
  String get v2PremiumFreeStatus => 'You are on the Free core';

  @override
  String get v2PremiumLoading => 'Loading Premium';

  @override
  String get v2PremiumPurchaseCta => 'Continue with Premium';

  @override
  String get v2PremiumContinue => 'Continue';

  @override
  String get v2PremiumPeriodMonthly => 'Monthly billing';

  @override
  String get v2PremiumPeriodAnnual => 'Annual billing';

  @override
  String get v2PremiumPeriodLifetime => 'Lifetime';

  @override
  String get v2PremiumTermsLink => 'Terms';

  @override
  String get v2PremiumOfflineCached => 'Offline — using saved Premium status';

  @override
  String get v2PremiumOfflineUnknown =>
      'Offline — Premium status unknown. Purchases need a connection.';

  @override
  String get v2PremiumUnavailableHere =>
      'Premium is not offered on this screen.';

  @override
  String get v2PremiumOpenFromArchive => 'View Premium for older archive';

  @override
  String get v2ReportsPremiumOpen => 'Open Premium';

  @override
  String get v2ReportsPremiumRestore => 'Restore purchases';

  @override
  String get v2SafaTitle => 'Safa';

  @override
  String get v2SafaPurpose =>
      'Short support to help you continue with one calm next step.';

  @override
  String get v2SafaAiLimitation =>
      'Safa may use an AI service over the network. It is not medical care and not emergency services.';

  @override
  String get v2SafaPrivacyNotice =>
      'Before sending: only what you type and explicitly select will be sent. You can continue without Safa or cancel.';

  @override
  String get v2SafaAcknowledgeNotice => 'I understand';

  @override
  String get v2SafaContinueWithout => 'Continue without Safa';

  @override
  String get v2SafaConsentBody =>
      'Send only your typed message and any context you select. Safa is not medical or emergency support.';

  @override
  String get v2SafaConsentAllow => 'Allow one network reply';

  @override
  String get v2SafaConsentDecline => 'Use offline support';

  @override
  String get v2SafaContextOptionalHeading =>
      'Optional context (nothing is preselected)';

  @override
  String get v2SafaContextNone => 'No extra context';

  @override
  String get v2SafaContextDifficult => 'Difficult moment';

  @override
  String get v2SafaContextClarify => 'Clarify a step';

  @override
  String get v2SafaContextContinue => 'Help continuing';

  @override
  String get v2SafaIncludeApprovedContext =>
      'Include a short context I approve for this send only';

  @override
  String get v2SafaInputLabel => 'Your message';

  @override
  String get v2SafaInputHint => 'Write briefly what you need help with';

  @override
  String get v2SafaSend => 'Send';

  @override
  String get v2SafaSending => 'Sending';

  @override
  String get v2SafaResponseHeading => 'Safa reply';

  @override
  String get v2SafaSuggestedReturn => 'Return to where you left';

  @override
  String get v2SafaSuggestedReturnToday => 'Return to Today';

  @override
  String get v2SafaFallbackGrounding => 'Pause: breathe slowly for one minute';

  @override
  String get v2SafaFallbackSimplify =>
      'Simplify: do only the smallest next step';

  @override
  String get v2SafaRetry => 'Retry';

  @override
  String get v2SafaUseLocalFallback => 'Use offline support';

  @override
  String get v2SafaOffline => 'You are offline. Offline support is available.';

  @override
  String get v2SafaTimeout =>
      'The request timed out. Offline support is available.';

  @override
  String get v2SafaServiceUnavailable =>
      'Safa is temporarily unavailable. Offline support is available.';

  @override
  String get v2SafaInvalidResponse =>
      'The reply could not be shown safely. Offline support is available.';

  @override
  String get v2SafaInputTooLong =>
      'Please shorten your message (500 characters max).';

  @override
  String get v2SafaSessionComplete =>
      'This support session has reached its limit. Choose a next step or leave.';

  @override
  String get v2SafaClearSession => 'Clear this session';

  @override
  String get v2SafaReturn => 'Return';

  @override
  String get v2SafaUrgentHelp => 'I need urgent help';

  @override
  String get v2SafaUrgentBody =>
      'Safa is stopping the conversation here. Safa cannot provide emergency care.';

  @override
  String get v2SafaUrgentLocalEmergency =>
      'If you may be in immediate danger, contact your local emergency services. This app does not replace them.';

  @override
  String get v2SafaNotMedical => 'Safa is not medical or emergency support.';

  @override
  String get v2SafaOnlyTypedSent =>
      'Only what you type and select will be sent.';

  @override
  String get v2SafaStartLater => 'Start a new Safa session later';

  @override
  String get v2SafaLoading => 'Opening Safa';

  @override
  String get v2SafaStateIdle => 'Ready when you are.';

  @override
  String get v2SafaStateReady => 'You can write a short message.';

  @override
  String get v2SafaStateResponseReady => 'A short reply is ready.';

  @override
  String get v2SafaStateLocalFallback => 'Offline support is shown below.';

  @override
  String get v2SafaUserCancelled =>
      'Cancelled. You can return or try again later.';

  @override
  String get v2SafaCleared => 'Session cleared.';

  @override
  String v2SafaSessionLimit(String used, String max) {
    return 'Support turns: $used of $max';
  }

  @override
  String get v2SafaEntryToday => 'Ask Safa for support';

  @override
  String get v2SafaEntryProfile => 'Open Safa';
}
