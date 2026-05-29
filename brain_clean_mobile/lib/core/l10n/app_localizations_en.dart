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
      'Attention and pattern recognition (coming soon)';

  @override
  String get cognitiveMemoryGameTitle => 'Memory mini-games';

  @override
  String get cognitiveMemoryGameSubtitle =>
      'Working-memory sequence tasks (coming soon)';

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
}
