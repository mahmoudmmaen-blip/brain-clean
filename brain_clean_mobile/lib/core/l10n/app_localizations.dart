import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardEmptyDiagnosticPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete the diagnostic to see your BC_score.'**
  String get dashboardEmptyDiagnosticPrompt;

  /// No description provided for @dashboardRetakeDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Retake Diagnostic'**
  String get dashboardRetakeDiagnostic;

  /// No description provided for @dashboardOpenDetoxCheckIn.
  ///
  /// In en, this message translates to:
  /// **'7-Day Detox Check-in'**
  String get dashboardOpenDetoxCheckIn;

  /// No description provided for @dashboardOpenDetoxCheckInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log daily habits and boost your live BC_score'**
  String get dashboardOpenDetoxCheckInSubtitle;

  /// No description provided for @dashboardCommittedAt.
  ///
  /// In en, this message translates to:
  /// **'Committed {date}'**
  String dashboardCommittedAt(String date);

  /// No description provided for @diagnosticTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic 6-Point Test'**
  String get diagnosticTitle;

  /// No description provided for @diagnosticLiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live · updates on every slider move'**
  String get diagnosticLiveSubtitle;

  /// No description provided for @diagnosticInstructions.
  ///
  /// In en, this message translates to:
  /// **'Rate each dimension from 1 (low) to 10 (high).'**
  String get diagnosticInstructions;

  /// No description provided for @diagnosticStart.
  ///
  /// In en, this message translates to:
  /// **'Start Brain Clean'**
  String get diagnosticStart;

  /// No description provided for @diagnosticSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get diagnosticSleepQuality;

  /// No description provided for @diagnosticSustainedAttention.
  ///
  /// In en, this message translates to:
  /// **'Sustained Attention'**
  String get diagnosticSustainedAttention;

  /// No description provided for @diagnosticFragmentation.
  ///
  /// In en, this message translates to:
  /// **'Fragmentation'**
  String get diagnosticFragmentation;

  /// No description provided for @diagnosticDopamineSeeking.
  ///
  /// In en, this message translates to:
  /// **'Dopamine Seeking'**
  String get diagnosticDopamineSeeking;

  /// No description provided for @diagnosticTaskSwitching.
  ///
  /// In en, this message translates to:
  /// **'Task Switching'**
  String get diagnosticTaskSwitching;

  /// No description provided for @diagnosticBurnout.
  ///
  /// In en, this message translates to:
  /// **'Burnout'**
  String get diagnosticBurnout;

  /// No description provided for @bcScoreHeroLabel.
  ///
  /// In en, this message translates to:
  /// **'BRAIN CLARITY SCORE'**
  String get bcScoreHeroLabel;

  /// No description provided for @bcScoreBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'BHI · BC_score breakdown'**
  String get bcScoreBreakdownTitle;

  /// No description provided for @bcScorePillarBrainPerformance.
  ///
  /// In en, this message translates to:
  /// **'Brain performance'**
  String get bcScorePillarBrainPerformance;

  /// No description provided for @bcScorePillarDigitalDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Digital discipline'**
  String get bcScorePillarDigitalDiscipline;

  /// No description provided for @bcScorePillarHealthyHabits.
  ///
  /// In en, this message translates to:
  /// **'Healthy habits'**
  String get bcScorePillarHealthyHabits;

  /// No description provided for @bcScorePillarConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get bcScorePillarConsistency;

  /// No description provided for @bcScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'BC_score'**
  String get bcScoreLabel;

  /// No description provided for @accountabilityAdjustment.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNTABILITY ADJUSTMENT'**
  String get accountabilityAdjustment;

  /// No description provided for @bhiScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Base BHI score'**
  String get bhiScoreLabel;

  /// No description provided for @finalBcScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Final BC_score'**
  String get finalBcScoreLabel;

  /// No description provided for @accountabilityDeduction.
  ///
  /// In en, this message translates to:
  /// **'Recovery accountability (−{deduction})'**
  String accountabilityDeduction(int deduction);

  /// No description provided for @detoxTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Dopamine Detox'**
  String get detoxTitle;

  /// No description provided for @detoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get detoxSubtitle;

  /// No description provided for @detoxLiveBcScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Live BC_score'**
  String get detoxLiveBcScoreTitle;

  /// No description provided for @detoxLiveBcScoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates instantly as you log habits'**
  String get detoxLiveBcScoreSubtitle;

  /// No description provided for @detoxBoredomTitle.
  ///
  /// In en, this message translates to:
  /// **'Boredom Befriended'**
  String get detoxBoredomTitle;

  /// No description provided for @detoxBoredomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sat with boredom without reaching for a screen'**
  String get detoxBoredomSubtitle;

  /// No description provided for @detoxDelayedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delayed Gratification'**
  String get detoxDelayedTitle;

  /// No description provided for @detoxDelayedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wins today (capped at {max})'**
  String detoxDelayedSubtitle(int max);

  /// No description provided for @detoxBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Activated'**
  String get detoxBodyTitle;

  /// No description provided for @detoxBodySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning sun + cold shower completed'**
  String get detoxBodySubtitle;

  /// No description provided for @detoxCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String detoxCount(int count);

  /// No description provided for @detoxIncrement.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get detoxIncrement;

  /// No description provided for @detoxDecrement.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get detoxDecrement;

  /// No description provided for @detoxReset.
  ///
  /// In en, this message translates to:
  /// **'Reset today'**
  String get detoxReset;

  /// No description provided for @detoxRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get detoxRetry;

  /// No description provided for @detoxSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get detoxSyncing;

  /// No description provided for @detoxSyncError.
  ///
  /// In en, this message translates to:
  /// **'Could not sync. Your check-in is saved locally.'**
  String get detoxSyncError;

  /// No description provided for @diagnosticBrainRotTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Rot Test'**
  String get diagnosticBrainRotTitle;

  /// No description provided for @diagnosticBhiTitle.
  ///
  /// In en, this message translates to:
  /// **'BHI 6-Point Assessment'**
  String get diagnosticBhiTitle;

  /// No description provided for @diagnosticYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get diagnosticYes;

  /// No description provided for @diagnosticNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get diagnosticNo;

  /// No description provided for @diagnosticPreviousQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous question'**
  String get diagnosticPreviousQuestion;

  /// No description provided for @diagnosticBrainRotProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String diagnosticBrainRotProgress(int current, int total);

  /// No description provided for @diagnosticBrainRotScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Rot Score'**
  String get diagnosticBrainRotScoreTitle;

  /// No description provided for @diagnosticBrainRotScoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'out of {max}'**
  String diagnosticBrainRotScoreOutOf(int max);

  /// No description provided for @diagnosticBrainRotBandRange.
  ///
  /// In en, this message translates to:
  /// **'Severity band: {min}–{max}'**
  String diagnosticBrainRotBandRange(int min, int max);

  /// No description provided for @diagnosticBrainRotInterpretationTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical interpretation'**
  String get diagnosticBrainRotInterpretationTitle;

  /// No description provided for @diagnosticContinueToBhi.
  ///
  /// In en, this message translates to:
  /// **'Continue to BHI assessment'**
  String get diagnosticContinueToBhi;

  /// No description provided for @diagnosticReviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review my answers'**
  String get diagnosticReviewAnswers;

  /// No description provided for @diagnosticBrainRotIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete all 10 questions first.'**
  String get diagnosticBrainRotIncomplete;

  /// No description provided for @diagnosticBrainRotScoring.
  ///
  /// In en, this message translates to:
  /// **'Calculating your Brain Rot score…'**
  String get diagnosticBrainRotScoring;

  /// No description provided for @diagnosticSyncError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your diagnostic. Please try again.'**
  String get diagnosticSyncError;

  /// No description provided for @diagnosticBrainRotQ1.
  ///
  /// In en, this message translates to:
  /// **'I feel my short-term memory has weakened (I forget what was said to me recently).'**
  String get diagnosticBrainRotQ1;

  /// No description provided for @diagnosticBrainRotQ2.
  ///
  /// In en, this message translates to:
  /// **'I have difficulty focusing on one task for long enough.'**
  String get diagnosticBrainRotQ2;

  /// No description provided for @diagnosticBrainRotQ3.
  ///
  /// In en, this message translates to:
  /// **'My thinking feels slower compared to before.'**
  String get diagnosticBrainRotQ3;

  /// No description provided for @diagnosticBrainRotQ4.
  ///
  /// In en, this message translates to:
  /// **'I experience \"brain fog\" or have trouble organizing my thoughts.'**
  String get diagnosticBrainRotQ4;

  /// No description provided for @diagnosticBrainRotQ5.
  ///
  /// In en, this message translates to:
  /// **'I feel mental fatigue after short periods of thinking or mental work.'**
  String get diagnosticBrainRotQ5;

  /// No description provided for @diagnosticBrainRotQ6.
  ///
  /// In en, this message translates to:
  /// **'I have trouble finding the right words when speaking or writing.'**
  String get diagnosticBrainRotQ6;

  /// No description provided for @diagnosticBrainRotQ7.
  ///
  /// In en, this message translates to:
  /// **'I feel scattered or my thoughts jump quickly from idea to idea.'**
  String get diagnosticBrainRotQ7;

  /// No description provided for @diagnosticBrainRotQ8.
  ///
  /// In en, this message translates to:
  /// **'Simple decisions or planning tasks have become harder.'**
  String get diagnosticBrainRotQ8;

  /// No description provided for @diagnosticBrainRotQ9.
  ///
  /// In en, this message translates to:
  /// **'I work slower than usual or need more time for the same tasks.'**
  String get diagnosticBrainRotQ9;

  /// No description provided for @diagnosticBrainRotQ10.
  ///
  /// In en, this message translates to:
  /// **'These symptoms affect my daily life (work, study, or relationships).'**
  String get diagnosticBrainRotQ10;

  /// No description provided for @dashboardBrainRotSummary.
  ///
  /// In en, this message translates to:
  /// **'Brain Rot: {score}/10'**
  String dashboardBrainRotSummary(int score);

  /// No description provided for @dashboardOpenRecoveryGrid.
  ///
  /// In en, this message translates to:
  /// **'30-Day Recovery Grid'**
  String get dashboardOpenRecoveryGrid;

  /// No description provided for @dashboardOpenRecoveryGridSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Five daily habits · accountability room for missed check-ins'**
  String get dashboardOpenRecoveryGridSubtitle;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean'**
  String get splashTitle;

  /// No description provided for @splashHydrationRetry.
  ///
  /// In en, this message translates to:
  /// **'Restoring your progress…'**
  String get splashHydrationRetry;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Home'**
  String get homeTitle;

  /// No description provided for @homeEmptyDiagnosticPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete the diagnostic to unlock your live BC_score tracker.'**
  String get homeEmptyDiagnosticPrompt;

  /// No description provided for @homeChallengeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'30-day recovery challenge'**
  String get homeChallengeProgressTitle;

  /// No description provided for @homeChallengeProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String homeChallengeProgressPercent(int percent);

  /// No description provided for @homeOpenDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic assessment'**
  String get homeOpenDiagnostic;

  /// No description provided for @homeOpenDiagnosticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Rot questionnaire + BHI sliders'**
  String get homeOpenDiagnosticSubtitle;

  /// No description provided for @homeOpenCognitiveHub.
  ///
  /// In en, this message translates to:
  /// **'Cognitive assessments'**
  String get homeOpenCognitiveHub;

  /// No description provided for @homeOpenCognitiveHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visual attention test and memory mini-games'**
  String get homeOpenCognitiveHubSubtitle;

  /// No description provided for @homeOpenFullDashboard.
  ///
  /// In en, this message translates to:
  /// **'Full clinical dashboard'**
  String get homeOpenFullDashboard;

  /// No description provided for @cognitiveHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Cognitive assessments'**
  String get cognitiveHubTitle;

  /// No description provided for @cognitiveHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive modules that refine your brain performance pillar.'**
  String get cognitiveHubSubtitle;

  /// No description provided for @cognitiveVisualTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Cognitive Image Test'**
  String get cognitiveVisualTestTitle;

  /// No description provided for @cognitiveVisualTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attention and pattern recognition (coming soon)'**
  String get cognitiveVisualTestSubtitle;

  /// No description provided for @cognitiveMemoryGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory mini-games'**
  String get cognitiveMemoryGameTitle;

  /// No description provided for @cognitiveMemoryGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Working-memory sequence tasks (coming soon)'**
  String get cognitiveMemoryGameSubtitle;

  /// No description provided for @cognitivePlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'This module is scaffolded for the unified BHI evaluation engine. Complete the placeholder run to verify navigation.'**
  String get cognitivePlaceholderBody;

  /// No description provided for @cognitivePlaceholderComplete.
  ///
  /// In en, this message translates to:
  /// **'Record placeholder result'**
  String get cognitivePlaceholderComplete;

  /// No description provided for @cognitivePlaceholderRecorded.
  ///
  /// In en, this message translates to:
  /// **'Placeholder score recorded: {score}%'**
  String cognitivePlaceholderRecorded(int score);

  /// No description provided for @recoveryGridTitle.
  ///
  /// In en, this message translates to:
  /// **'30-Day Recovery'**
  String get recoveryGridTitle;

  /// No description provided for @recoveryGridSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to log the five mandatory habits.'**
  String get recoveryGridSubtitle;

  /// No description provided for @recoveryDayTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day} habits'**
  String recoveryDayTasksTitle(int day);

  /// No description provided for @recoveryProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} protocol days complete'**
  String recoveryProgressSummary(int completed, int total);

  /// No description provided for @recoveryDayTasksProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} habits logged today'**
  String recoveryDayTasksProgress(int done, int total);

  /// No description provided for @recoveryTaskSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Regulated sleep'**
  String get recoveryTaskSleepTitle;

  /// No description provided for @recoveryTaskSleepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Consistent sleep window and wind-down routine'**
  String get recoveryTaskSleepSubtitle;

  /// No description provided for @recoveryTaskNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Anti-inflammatory nutrition'**
  String get recoveryTaskNutritionTitle;

  /// No description provided for @recoveryTaskNutritionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Brain-supportive meals without inflammatory triggers'**
  String get recoveryTaskNutritionSubtitle;

  /// No description provided for @recoveryTaskMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'20 minutes of movement'**
  String get recoveryTaskMovementTitle;

  /// No description provided for @recoveryTaskMovementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Walk, stretch, or light exercise for at least 20 minutes'**
  String get recoveryTaskMovementSubtitle;

  /// No description provided for @recoveryTaskDistractionTitle.
  ///
  /// In en, this message translates to:
  /// **'Distraction management protocol'**
  String get recoveryTaskDistractionTitle;

  /// No description provided for @recoveryTaskDistractionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed your daily focus-protection routine'**
  String get recoveryTaskDistractionSubtitle;

  /// No description provided for @recoveryTaskMentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Mental support'**
  String get recoveryTaskMentalTitle;

  /// No description provided for @recoveryTaskMentalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Journaling, breathwork, or guided recovery check-in'**
  String get recoveryTaskMentalSubtitle;

  /// No description provided for @recoveryDayComplete.
  ///
  /// In en, this message translates to:
  /// **'All five habits completed for this day.'**
  String get recoveryDayComplete;

  /// No description provided for @recoveryMissedHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incomplete check-in'**
  String get recoveryMissedHabitsTitle;

  /// No description provided for @recoveryMissedHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Some habits were missed. Open the accountability room to record responsibility.'**
  String get recoveryMissedHabitsSubtitle;

  /// No description provided for @recoveryOpenPenaltyBox.
  ///
  /// In en, this message translates to:
  /// **'Open accountability room'**
  String get recoveryOpenPenaltyBox;

  /// No description provided for @recoveryDayEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Check off each habit as you complete it today.'**
  String get recoveryDayEmptyHint;

  /// No description provided for @recoveryPenaltyCount.
  ///
  /// In en, this message translates to:
  /// **'Accountability entries: {count}'**
  String recoveryPenaltyCount(int count);

  /// No description provided for @recoveryPenaltyBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Accountability room'**
  String get recoveryPenaltyBoxTitle;

  /// No description provided for @recoveryPenaltyBoxMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirming applies a −{deduction} BC_score accountability entry for missed habits today.'**
  String recoveryPenaltyBoxMessage(int deduction);

  /// No description provided for @recoveryPenaltyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm accountability'**
  String get recoveryPenaltyConfirm;

  /// No description provided for @recoveryPenaltyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get recoveryPenaltyCancel;

  /// No description provided for @recoveryPenaltyApplied.
  ///
  /// In en, this message translates to:
  /// **'Accountability recorded for today.'**
  String get recoveryPenaltyApplied;

  /// No description provided for @recoveryStorageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your recovery progress from local storage.'**
  String get recoveryStorageLoadError;

  /// No description provided for @recoveryStorageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your latest check-in. Your changes are kept on screen — try again.'**
  String get recoveryStorageSaveError;

  /// No description provided for @recoveryStorageReset.
  ///
  /// In en, this message translates to:
  /// **'Start fresh protocol'**
  String get recoveryStorageReset;

  /// No description provided for @recoveryStorageMigratedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your saved progress was upgraded to the latest format.'**
  String get recoveryStorageMigratedNotice;

  /// No description provided for @recoveryStorageRecoveredNotice.
  ///
  /// In en, this message translates to:
  /// **'Local data was reset because it could not be read. A new protocol has started.'**
  String get recoveryStorageRecoveredNotice;

  /// No description provided for @homeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get homeStreakDays;

  /// No description provided for @homeStreakHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get homeStreakHours;

  /// No description provided for @homeStreakMinutes.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get homeStreakMinutes;

  /// No description provided for @homeStreakSeconds.
  ///
  /// In en, this message translates to:
  /// **'Sec'**
  String get homeStreakSeconds;

  /// No description provided for @homeDistractionButton.
  ///
  /// In en, this message translates to:
  /// **'Temporary distraction'**
  String get homeDistractionButton;

  /// No description provided for @homeDistractionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm distraction'**
  String get homeDistractionConfirmTitle;

  /// No description provided for @homeDistractionConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? 12 hours will be deducted from your streak.'**
  String get homeDistractionConfirmMessage;

  /// No description provided for @homeDistractionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get homeDistractionConfirm;

  /// No description provided for @homeDistractionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeDistractionCancel;

  /// No description provided for @homeOpenAccountability.
  ///
  /// In en, this message translates to:
  /// **'Digital accountability room'**
  String get homeOpenAccountability;

  /// No description provided for @accountabilityRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital accountability room'**
  String get accountabilityRoomTitle;

  /// No description provided for @accountabilityPenaltyRecorded.
  ///
  /// In en, this message translates to:
  /// **'Penalty recorded ✓'**
  String get accountabilityPenaltyRecorded;

  /// No description provided for @accountabilityCatPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get accountabilityCatPhysical;

  /// No description provided for @accountabilityCatNutritional.
  ///
  /// In en, this message translates to:
  /// **'Nutritional'**
  String get accountabilityCatNutritional;

  /// No description provided for @accountabilityCatAltruistic.
  ///
  /// In en, this message translates to:
  /// **'Altruistic'**
  String get accountabilityCatAltruistic;

  /// No description provided for @accountabilityCatMental.
  ///
  /// In en, this message translates to:
  /// **'Mental'**
  String get accountabilityCatMental;

  /// No description provided for @accountabilityPenPhysical1.
  ///
  /// In en, this message translates to:
  /// **'Skipped movement block'**
  String get accountabilityPenPhysical1;

  /// No description provided for @accountabilityPenPhysical2.
  ///
  /// In en, this message translates to:
  /// **'Poor sleep hygiene'**
  String get accountabilityPenPhysical2;

  /// No description provided for @accountabilityPenPhysical3.
  ///
  /// In en, this message translates to:
  /// **'Sedentary relapse'**
  String get accountabilityPenPhysical3;

  /// No description provided for @accountabilityPenPhysical4.
  ///
  /// In en, this message translates to:
  /// **'Missed recovery walk'**
  String get accountabilityPenPhysical4;

  /// No description provided for @accountabilityPenPhysical5.
  ///
  /// In en, this message translates to:
  /// **'Body activation skipped'**
  String get accountabilityPenPhysical5;

  /// No description provided for @accountabilityPenNutritional1.
  ///
  /// In en, this message translates to:
  /// **'Inflammatory meal'**
  String get accountabilityPenNutritional1;

  /// No description provided for @accountabilityPenNutritional2.
  ///
  /// In en, this message translates to:
  /// **'Skipped brain-support meal'**
  String get accountabilityPenNutritional2;

  /// No description provided for @accountabilityPenNutritional3.
  ///
  /// In en, this message translates to:
  /// **'Excess sugar intake'**
  String get accountabilityPenNutritional3;

  /// No description provided for @accountabilityPenNutritional4.
  ///
  /// In en, this message translates to:
  /// **'Hydration neglect'**
  String get accountabilityPenNutritional4;

  /// No description provided for @accountabilityPenNutritional5.
  ///
  /// In en, this message translates to:
  /// **'Late-night eating'**
  String get accountabilityPenNutritional5;

  /// No description provided for @accountabilityPenAltruistic1.
  ///
  /// In en, this message translates to:
  /// **'Missed kindness act'**
  String get accountabilityPenAltruistic1;

  /// No description provided for @accountabilityPenAltruistic2.
  ///
  /// In en, this message translates to:
  /// **'Social withdrawal'**
  String get accountabilityPenAltruistic2;

  /// No description provided for @accountabilityPenAltruistic3.
  ///
  /// In en, this message translates to:
  /// **'Ignored support request'**
  String get accountabilityPenAltruistic3;

  /// No description provided for @accountabilityPenAltruistic4.
  ///
  /// In en, this message translates to:
  /// **'Self-focused relapse'**
  String get accountabilityPenAltruistic4;

  /// No description provided for @accountabilityPenAltruistic5.
  ///
  /// In en, this message translates to:
  /// **'Community check-in skipped'**
  String get accountabilityPenAltruistic5;

  /// No description provided for @accountabilityPenMental1.
  ///
  /// In en, this message translates to:
  /// **'Skipped breathwork'**
  String get accountabilityPenMental1;

  /// No description provided for @accountabilityPenMental2.
  ///
  /// In en, this message translates to:
  /// **'Avoided journaling'**
  String get accountabilityPenMental2;

  /// No description provided for @accountabilityPenMental3.
  ///
  /// In en, this message translates to:
  /// **'Rumination spiral'**
  String get accountabilityPenMental3;

  /// No description provided for @accountabilityPenMental4.
  ///
  /// In en, this message translates to:
  /// **'Missed mental check-in'**
  String get accountabilityPenMental4;

  /// No description provided for @accountabilityPenMental5.
  ///
  /// In en, this message translates to:
  /// **'Escalated screen binge'**
  String get accountabilityPenMental5;

  /// No description provided for @breathingInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale…'**
  String get breathingInhale;

  /// No description provided for @breathingHold.
  ///
  /// In en, this message translates to:
  /// **'Hold…'**
  String get breathingHold;

  /// No description provided for @breathingExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale…'**
  String get breathingExhale;

  /// No description provided for @breathingCountdownSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds remaining'**
  String breathingCountdownSeconds(int seconds);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get commonGreat;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Brain Clean'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'Restore your digital awareness in 21 days'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Track your focus daily'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Real science-based formulas to measure brain health'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Start your journey now'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Answer 10 questions to assess your brain rot level'**
  String get onboardingPage3Body;

  /// No description provided for @onboardingStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start assessment'**
  String get onboardingStartQuiz;

  /// No description provided for @proPaywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Pro'**
  String get proPaywallTitle;

  /// No description provided for @proPaywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock your mind\'s full potential'**
  String get proPaywallSubtitle;

  /// No description provided for @proFeatureAdvancedBcs.
  ///
  /// In en, this message translates to:
  /// **'Advanced Brain Clarity Score engine'**
  String get proFeatureAdvancedBcs;

  /// No description provided for @proFeatureSevenDayChart.
  ///
  /// In en, this message translates to:
  /// **'7-day progress chart'**
  String get proFeatureSevenDayChart;

  /// No description provided for @proFeatureEmotionWheel.
  ///
  /// In en, this message translates to:
  /// **'Emotion wheel & recovery impact'**
  String get proFeatureEmotionWheel;

  /// No description provided for @proFeatureFocusChallenges.
  ///
  /// In en, this message translates to:
  /// **'Advanced focus challenges'**
  String get proFeatureFocusChallenges;

  /// No description provided for @proFeatureCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Secure cloud sync'**
  String get proFeatureCloudSync;

  /// No description provided for @proWelcomeSnack.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pro! 🎉'**
  String get proWelcomeSnack;

  /// No description provided for @proPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'SAR 19 / month'**
  String get proPriceMonthly;

  /// No description provided for @proPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Less than one meal'**
  String get proPriceHint;

  /// No description provided for @proSubscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now'**
  String get proSubscribeNow;

  /// No description provided for @proRestorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get proRestorePurchase;

  /// No description provided for @proBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proBadgeLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsProActive.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Pro ✓'**
  String get settingsProActive;

  /// No description provided for @settingsUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get settingsUpgradeToPro;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsEmotionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Negative emotion alerts'**
  String get settingsEmotionNotifications;

  /// No description provided for @settingsDailyFocusReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily focus reminder'**
  String get settingsDailyFocusReminder;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsResetData.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settingsResetData;

  /// No description provided for @settingsResetDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settingsResetDataConfirmTitle;

  /// No description provided for @settingsResetDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All local data will be deleted. Are you sure?'**
  String get settingsResetDataConfirmBody;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get settingsExportData;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon…'**
  String get settingsComingSoon;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsContactUs;

  /// No description provided for @emotionWheelTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion wheel'**
  String get emotionWheelTitle;

  /// No description provided for @emotionImpactDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Impact on your recovery'**
  String get emotionImpactDialogTitle;

  /// No description provided for @emotionImpactNegative.
  ///
  /// In en, this message translates to:
  /// **'Feeling {emotion} will reduce your recovery by {pct}%.\nLog it?'**
  String emotionImpactNegative(String emotion, String pct);

  /// No description provided for @emotionImpactPositive.
  ///
  /// In en, this message translates to:
  /// **'Feeling {emotion} will improve your recovery by {pct}%.\nLog it?'**
  String emotionImpactPositive(String emotion, String pct);

  /// No description provided for @emotionIgnore.
  ///
  /// In en, this message translates to:
  /// **'No, ignore'**
  String get emotionIgnore;

  /// No description provided for @emotionConfirmLog.
  ///
  /// In en, this message translates to:
  /// **'Yes, log it'**
  String get emotionConfirmLog;

  /// No description provided for @emotionGateNegative.
  ///
  /// In en, this message translates to:
  /// **'I feel something negative'**
  String get emotionGateNegative;

  /// No description provided for @emotionGateNeutral.
  ///
  /// In en, this message translates to:
  /// **'I feel something neutral'**
  String get emotionGateNeutral;

  /// No description provided for @emotionGatePositive.
  ///
  /// In en, this message translates to:
  /// **'I feel something positive'**
  String get emotionGatePositive;

  /// No description provided for @silenceChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Silence challenge'**
  String get silenceChallengeTitle;

  /// No description provided for @silenceChallengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t touch the screen for {minutes} minutes'**
  String silenceChallengeSubtitle(int minutes);

  /// No description provided for @silenceChallengeLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} — {minutes} minutes required'**
  String silenceChallengeLevel(int level, int minutes);

  /// No description provided for @silenceChallengeFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge failed'**
  String get silenceChallengeFailedTitle;

  /// No description provided for @silenceChallengeFailedBody.
  ///
  /// In en, this message translates to:
  /// **'You touched the screen or left the app.'**
  String get silenceChallengeFailedBody;

  /// No description provided for @silenceChallengeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Well done! 🎉'**
  String get silenceChallengeSuccessTitle;

  /// No description provided for @silenceChallengeSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'You completed the silence challenge.'**
  String get silenceChallengeSuccessBody;

  /// No description provided for @singleTaskPauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause task'**
  String get singleTaskPauseTitle;

  /// No description provided for @singleTaskPauseBody.
  ///
  /// In en, this message translates to:
  /// **'Stop the current task? You won\'t earn a reward.'**
  String get singleTaskPauseBody;

  /// No description provided for @singleTaskModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Single-task mode'**
  String get singleTaskModeTitle;

  /// No description provided for @singleTaskFocusRewardSnack.
  ///
  /// In en, this message translates to:
  /// **'Great! +10 focus points'**
  String get singleTaskFocusRewardSnack;

  /// No description provided for @singleTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Write your task now…'**
  String get singleTaskHint;

  /// No description provided for @singleTaskStartFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get singleTaskStartFocus;

  /// No description provided for @singleTaskFocusing.
  ///
  /// In en, this message translates to:
  /// **'Focusing…'**
  String get singleTaskFocusing;

  /// No description provided for @singleTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task done ✓'**
  String get singleTaskCompleted;

  /// No description provided for @singleTaskPauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get singleTaskPauseButton;

  /// No description provided for @delayedGratTitle.
  ///
  /// In en, this message translates to:
  /// **'Delayed gratification'**
  String get delayedGratTitle;

  /// No description provided for @delayedGratSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hold 20 minutes before opening social media'**
  String get delayedGratSubtitle;

  /// No description provided for @delayedGratQuoteUnder5.
  ///
  /// In en, this message translates to:
  /// **'Patience is the key to relief'**
  String get delayedGratQuoteUnder5;

  /// No description provided for @delayedGratQuoteUnder10.
  ///
  /// In en, this message translates to:
  /// **'Your brain thanks you now'**
  String get delayedGratQuoteUnder10;

  /// No description provided for @delayedGratQuoteUnder15.
  ///
  /// In en, this message translates to:
  /// **'You\'re stronger than the algorithm'**
  String get delayedGratQuoteUnder15;

  /// No description provided for @delayedGratQuoteDefault.
  ///
  /// In en, this message translates to:
  /// **'Almost there — keep going'**
  String get delayedGratQuoteDefault;

  /// No description provided for @delayedGratGiveUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Give up'**
  String get delayedGratGiveUpTitle;

  /// No description provided for @delayedGratGiveUpBody.
  ///
  /// In en, this message translates to:
  /// **'Give up now? You won\'t earn the reward.'**
  String get delayedGratGiveUpBody;

  /// No description provided for @delayedGratGiveUpButton.
  ///
  /// In en, this message translates to:
  /// **'Give up'**
  String get delayedGratGiveUpButton;

  /// No description provided for @delayedGratVictoryTitle.
  ///
  /// In en, this message translates to:
  /// **'You beat yourself! 🏆'**
  String get delayedGratVictoryTitle;

  /// No description provided for @delayedGratVictoryBody.
  ///
  /// In en, this message translates to:
  /// **'+25 focus points added.'**
  String get delayedGratVictoryBody;

  /// No description provided for @chartSevenDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your 7-day progress'**
  String get chartSevenDayTitle;

  /// No description provided for @chartDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get chartDaySat;

  /// No description provided for @chartDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get chartDaySun;

  /// No description provided for @chartDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get chartDayMon;

  /// No description provided for @chartDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get chartDayTue;

  /// No description provided for @chartDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get chartDayWed;

  /// No description provided for @chartDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get chartDayThu;

  /// No description provided for @chartDayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get chartDayFri;

  /// No description provided for @proGatedChartTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day progress chart'**
  String get proGatedChartTitle;

  /// No description provided for @proGatedChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available in Brain Clean Pro'**
  String get proGatedChartSubtitle;

  /// No description provided for @visualCognitiveBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get visualCognitiveBack;

  /// No description provided for @visualCognitiveRound.
  ///
  /// In en, this message translates to:
  /// **'Round {round} / 5'**
  String visualCognitiveRound(int round);

  /// No description provided for @visualCognitiveInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the square with a different color'**
  String get visualCognitiveInstruction;

  /// No description provided for @visualCognitiveScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String visualCognitiveScore(int score);

  /// No description provided for @diagnosticCognitiveTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test your focus 🎯'**
  String get diagnosticCognitiveTestButton;

  /// No description provided for @homeQuickEmotion.
  ///
  /// In en, this message translates to:
  /// **'How do you feel? 💭'**
  String get homeQuickEmotion;

  /// No description provided for @homeQuickSilence.
  ///
  /// In en, this message translates to:
  /// **'Silence challenge 🔇'**
  String get homeQuickSilence;

  /// No description provided for @homeQuickSingleTask.
  ///
  /// In en, this message translates to:
  /// **'Single task 🎯'**
  String get homeQuickSingleTask;

  /// No description provided for @homeQuickDelayedGrat.
  ///
  /// In en, this message translates to:
  /// **'Delayed gratification ⏳'**
  String get homeQuickDelayedGrat;

  /// No description provided for @homeQuickCognitiveTest.
  ///
  /// In en, this message translates to:
  /// **'Test your focus 🧪'**
  String get homeQuickCognitiveTest;

  /// No description provided for @homeAccountabilityBox.
  ///
  /// In en, this message translates to:
  /// **'Accountability box'**
  String get homeAccountabilityBox;

  /// No description provided for @homeDistractionConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm distraction'**
  String get homeDistractionConfirmAction;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your brain'**
  String get splashSubtitle;

  /// No description provided for @profileDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean user'**
  String get profileDefaultName;

  /// No description provided for @profileProBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro ⭐'**
  String get profileProBadge;

  /// No description provided for @profileStatFocusDays.
  ///
  /// In en, this message translates to:
  /// **'focus days'**
  String get profileStatFocusDays;

  /// No description provided for @profileStatBcs.
  ///
  /// In en, this message translates to:
  /// **'BCS'**
  String get profileStatBcs;

  /// No description provided for @profileStatEmotions.
  ///
  /// In en, this message translates to:
  /// **'emotions'**
  String get profileStatEmotions;

  /// No description provided for @profileRecentEmotions.
  ///
  /// In en, this message translates to:
  /// **'Recent emotions'**
  String get profileRecentEmotions;

  /// No description provided for @profileNoEmotionsYet.
  ///
  /// In en, this message translates to:
  /// **'No emotions logged yet'**
  String get profileNoEmotionsYet;

  /// No description provided for @profileAchievements.
  ///
  /// In en, this message translates to:
  /// **'Your achievements'**
  String get profileAchievements;

  /// No description provided for @profileBadgeStreak7.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get profileBadgeStreak7;

  /// No description provided for @profileBadgeCleanBrain.
  ///
  /// In en, this message translates to:
  /// **'Clean brain'**
  String get profileBadgeCleanBrain;

  /// No description provided for @profileBadgeSilenceHero.
  ///
  /// In en, this message translates to:
  /// **'Silence hero'**
  String get profileBadgeSilenceHero;

  /// No description provided for @profileBadgeSingleTask.
  ///
  /// In en, this message translates to:
  /// **'Single task'**
  String get profileBadgeSingleTask;

  /// No description provided for @profileBadgeEmotionAwake.
  ///
  /// In en, this message translates to:
  /// **'Emotion aware'**
  String get profileBadgeEmotionAwake;

  /// No description provided for @profileBadgeProMember.
  ///
  /// In en, this message translates to:
  /// **'Pro Member'**
  String get profileBadgeProMember;

  /// No description provided for @accountabilityModalCatPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical fitness'**
  String get accountabilityModalCatPhysical;

  /// No description provided for @accountabilityModalCatNutritional.
  ///
  /// In en, this message translates to:
  /// **'Healthy nutrition'**
  String get accountabilityModalCatNutritional;

  /// No description provided for @accountabilityModalCatAltruistic.
  ///
  /// In en, this message translates to:
  /// **'Altruistic acts'**
  String get accountabilityModalCatAltruistic;

  /// No description provided for @accountabilityModalCatMental.
  ///
  /// In en, this message translates to:
  /// **'Mental challenge'**
  String get accountabilityModalCatMental;

  /// No description provided for @accountabilityModalPenPhysical1.
  ///
  /// In en, this message translates to:
  /// **'30-minute workout'**
  String get accountabilityModalPenPhysical1;

  /// No description provided for @accountabilityModalPenPhysical2.
  ///
  /// In en, this message translates to:
  /// **'Strength training'**
  String get accountabilityModalPenPhysical2;

  /// No description provided for @accountabilityModalPenPhysical3.
  ///
  /// In en, this message translates to:
  /// **'5,000 steps walk'**
  String get accountabilityModalPenPhysical3;

  /// No description provided for @accountabilityModalPenPhysical4.
  ///
  /// In en, this message translates to:
  /// **'Morning stretch'**
  String get accountabilityModalPenPhysical4;

  /// No description provided for @accountabilityModalPenPhysical5.
  ///
  /// In en, this message translates to:
  /// **'Outdoor activity'**
  String get accountabilityModalPenPhysical5;

  /// No description provided for @accountabilityModalPenNutritional1.
  ///
  /// In en, this message translates to:
  /// **'Avoid sugar'**
  String get accountabilityModalPenNutritional1;

  /// No description provided for @accountabilityModalPenNutritional2.
  ///
  /// In en, this message translates to:
  /// **'Balanced meal'**
  String get accountabilityModalPenNutritional2;

  /// No description provided for @accountabilityModalPenNutritional3.
  ///
  /// In en, this message translates to:
  /// **'Drink 2L water'**
  String get accountabilityModalPenNutritional3;

  /// No description provided for @accountabilityModalPenNutritional4.
  ///
  /// In en, this message translates to:
  /// **'Reduce caffeine'**
  String get accountabilityModalPenNutritional4;

  /// No description provided for @accountabilityModalPenNutritional5.
  ///
  /// In en, this message translates to:
  /// **'Protein meal'**
  String get accountabilityModalPenNutritional5;

  /// No description provided for @accountabilityModalPenAltruistic1.
  ///
  /// In en, this message translates to:
  /// **'Help a neighbor'**
  String get accountabilityModalPenAltruistic1;

  /// No description provided for @accountabilityModalPenAltruistic2.
  ///
  /// In en, this message translates to:
  /// **'Small donation'**
  String get accountabilityModalPenAltruistic2;

  /// No description provided for @accountabilityModalPenAltruistic3.
  ///
  /// In en, this message translates to:
  /// **'Thank-you message'**
  String get accountabilityModalPenAltruistic3;

  /// No description provided for @accountabilityModalPenAltruistic4.
  ///
  /// In en, this message translates to:
  /// **'Community service'**
  String get accountabilityModalPenAltruistic4;

  /// No description provided for @accountabilityModalPenAltruistic5.
  ///
  /// In en, this message translates to:
  /// **'Support a friend'**
  String get accountabilityModalPenAltruistic5;

  /// No description provided for @accountabilityModalPenMental1.
  ///
  /// In en, this message translates to:
  /// **'Read 20 minutes'**
  String get accountabilityModalPenMental1;

  /// No description provided for @accountabilityModalPenMental2.
  ///
  /// In en, this message translates to:
  /// **'Solve a puzzle'**
  String get accountabilityModalPenMental2;

  /// No description provided for @accountabilityModalPenMental3.
  ///
  /// In en, this message translates to:
  /// **'Learn a new word'**
  String get accountabilityModalPenMental3;

  /// No description provided for @accountabilityModalPenMental4.
  ///
  /// In en, this message translates to:
  /// **'Guided meditation'**
  String get accountabilityModalPenMental4;

  /// No description provided for @accountabilityModalPenMental5.
  ///
  /// In en, this message translates to:
  /// **'Journal writing'**
  String get accountabilityModalPenMental5;

  /// No description provided for @breathingInhaleSlow.
  ///
  /// In en, this message translates to:
  /// **'Inhale slowly…'**
  String get breathingInhaleSlow;

  /// No description provided for @breathingExhaleFull.
  ///
  /// In en, this message translates to:
  /// **'Exhale fully…'**
  String get breathingExhaleFull;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
