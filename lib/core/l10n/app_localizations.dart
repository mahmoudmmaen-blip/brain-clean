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
  /// **'Find the odd shape or color in a timed grid'**
  String get cognitiveVisualTestSubtitle;

  /// No description provided for @cognitiveMemoryGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory mini-games'**
  String get cognitiveMemoryGameTitle;

  /// No description provided for @cognitiveMemoryGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recall growing color sequences on a 3×3 grid'**
  String get cognitiveMemoryGameSubtitle;

  /// No description provided for @cognitiveStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get cognitiveStartButton;

  /// No description provided for @cognitiveDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Save & close'**
  String get cognitiveDoneButton;

  /// No description provided for @cognitiveMemoryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Watch the highlighted cells, then tap them in the same order. The sequence grows each round.'**
  String get cognitiveMemoryInstructions;

  /// No description provided for @cognitiveMemoryWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence…'**
  String get cognitiveMemoryWatch;

  /// No description provided for @cognitiveMemoryYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn — tap the cells in order'**
  String get cognitiveMemoryYourTurn;

  /// No description provided for @cognitiveMemoryRound.
  ///
  /// In en, this message translates to:
  /// **'Sequence length: {length}'**
  String cognitiveMemoryRound(int length);

  /// No description provided for @cognitiveMemoryWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect — test ended.'**
  String get cognitiveMemoryWrong;

  /// No description provided for @cognitiveMemoryResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory test complete'**
  String get cognitiveMemoryResultTitle;

  /// No description provided for @cognitiveMemoryResultScore.
  ///
  /// In en, this message translates to:
  /// **'Longest sequence: {span} · Score: {score}%'**
  String cognitiveMemoryResultScore(int span, int score);

  /// No description provided for @cognitiveVisualInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap the one cell that looks different. You have a few seconds each round.'**
  String get cognitiveVisualInstructions;

  /// No description provided for @cognitiveVisualFindOdd.
  ///
  /// In en, this message translates to:
  /// **'Find the odd one out'**
  String get cognitiveVisualFindOdd;

  /// No description provided for @cognitiveVisualRound.
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String cognitiveVisualRound(int current, int total);

  /// No description provided for @cognitiveVisualCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get cognitiveVisualCorrect;

  /// No description provided for @cognitiveVisualWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get cognitiveVisualWrong;

  /// No description provided for @cognitiveVisualTimeout.
  ///
  /// In en, this message translates to:
  /// **'Too slow'**
  String get cognitiveVisualTimeout;

  /// No description provided for @cognitiveVisualResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual attention complete'**
  String get cognitiveVisualResultTitle;

  /// No description provided for @cognitiveVisualResultScore.
  ///
  /// In en, this message translates to:
  /// **'{points} / {maxPoints} points · Score: {score}%'**
  String cognitiveVisualResultScore(int points, int maxPoints, int score);

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
  /// **'Temporary Distraction protocol'**
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
  /// **'Journaling or guided recovery check-in'**
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

  /// No description provided for @homeFocusJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Journey'**
  String get homeFocusJourneyTitle;

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
  /// **'Temporary Distraction'**
  String get homeDistractionButton;

  /// No description provided for @homeDistractionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Temporary Distraction'**
  String get homeDistractionConfirmTitle;

  /// No description provided for @homeDistractionConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? 12 hours will be deducted from your Focus Journey.'**
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
  /// **'Accountability recorded ✓'**
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
  /// **'Skipped mental recovery block'**
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

  /// No description provided for @proFeatureColorThemes.
  ///
  /// In en, this message translates to:
  /// **'4 exclusive Pro color themes'**
  String get proFeatureColorThemes;

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

  /// No description provided for @proPlanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get proPlanMonthly;

  /// No description provided for @proPlanAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get proPlanAnnual;

  /// No description provided for @proPlanLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get proPlanLifetime;

  /// No description provided for @proBestValueBadge.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get proBestValueBadge;

  /// No description provided for @proAlreadyProTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re already Pro'**
  String get proAlreadyProTitle;

  /// No description provided for @proAlreadyProBody.
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited access to all premium features.'**
  String get proAlreadyProBody;

  /// No description provided for @proRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully'**
  String get proRestoreSuccess;

  /// No description provided for @proRestoreNone.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found'**
  String get proRestoreNone;

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

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @colorThemeMidnightName.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get colorThemeMidnightName;

  /// No description provided for @colorThemeAuroraName.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get colorThemeAuroraName;

  /// No description provided for @colorThemePineName.
  ///
  /// In en, this message translates to:
  /// **'Pine'**
  String get colorThemePineName;

  /// No description provided for @colorThemeSolarName.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get colorThemeSolarName;

  /// No description provided for @colorThemeSlateName.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colorThemeSlateName;

  /// No description provided for @colorThemeDaylightName.
  ///
  /// In en, this message translates to:
  /// **'Daylight'**
  String get colorThemeDaylightName;

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

  /// No description provided for @settingsLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link on this device.'**
  String get settingsLinkUnavailable;

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
  /// **'Confirm Temporary Distraction'**
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
  /// **'7-day Focus Journey'**
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

  /// No description provided for @asyncErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get asyncErrorRetry;

  /// No description provided for @chartEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No data yet — start your journey today'**
  String get chartEmptyState;

  /// No description provided for @homeStreakMotivation.
  ///
  /// In en, this message translates to:
  /// **'Start your Focus Journey now 🚀'**
  String get homeStreakMotivation;

  /// No description provided for @dailyQuoteSource.
  ///
  /// In en, this message translates to:
  /// **'Neuroscience'**
  String get dailyQuoteSource;

  /// No description provided for @focusJourneyFreezeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Journey Freeze ❄️'**
  String get focusJourneyFreezeTitle;

  /// No description provided for @streakFreezeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use Focus Journey freeze? Available once per week'**
  String get streakFreezeConfirm;

  /// No description provided for @shareProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Share Progress'**
  String get shareProgressLabel;

  /// No description provided for @levelPointsToNext.
  ///
  /// In en, this message translates to:
  /// **'{points} points to next level'**
  String levelPointsToNext(int points);

  /// No description provided for @weeklyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReportTitle;

  /// No description provided for @weeklyReportStreakDays.
  ///
  /// In en, this message translates to:
  /// **'Focus Journey days this week'**
  String get weeklyReportStreakDays;

  /// No description provided for @weeklyReportAvgBcs.
  ///
  /// In en, this message translates to:
  /// **'Average BCS'**
  String get weeklyReportAvgBcs;

  /// No description provided for @weeklyReportBestEmotion.
  ///
  /// In en, this message translates to:
  /// **'Top emotion'**
  String get weeklyReportBestEmotion;

  /// No description provided for @weeklyReportChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges completed'**
  String get weeklyReportChallenges;

  /// No description provided for @pomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoroTitle;

  /// No description provided for @pomodoroPhaseFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus Time 🎯'**
  String get pomodoroPhaseFocus;

  /// No description provided for @pomodoroPhaseShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break ☕'**
  String get pomodoroPhaseShortBreak;

  /// No description provided for @pomodoroPhaseLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break 🌿'**
  String get pomodoroPhaseLongBreak;

  /// No description provided for @pomodoroReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get pomodoroReset;

  /// No description provided for @pomodoroSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get pomodoroSkip;

  /// No description provided for @pomodoroSessionsToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sessions: {count}'**
  String pomodoroSessionsToday(int count);

  /// No description provided for @homeQuickPomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro ⏱️'**
  String get homeQuickPomodoro;

  /// No description provided for @homeQuickGames.
  ///
  /// In en, this message translates to:
  /// **'Games 🎮'**
  String get homeQuickGames;

  /// No description provided for @taskCategoryMental.
  ///
  /// In en, this message translates to:
  /// **'🧠 Mental'**
  String get taskCategoryMental;

  /// No description provided for @taskCategoryPhysical.
  ///
  /// In en, this message translates to:
  /// **'💪 Physical'**
  String get taskCategoryPhysical;

  /// No description provided for @taskCategoryCreative.
  ///
  /// In en, this message translates to:
  /// **'🎨 Creative'**
  String get taskCategoryCreative;

  /// No description provided for @taskCategoryEducational.
  ///
  /// In en, this message translates to:
  /// **'📚 Educational'**
  String get taskCategoryEducational;

  /// No description provided for @taskCategoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'🏠 Household'**
  String get taskCategoryHousehold;

  /// No description provided for @singleTaskEstimatedBonus.
  ///
  /// In en, this message translates to:
  /// **'Completing this task adds +{points} points'**
  String singleTaskEstimatedBonus(String points);

  /// No description provided for @singleTaskFocusRewardSnackBonus.
  ///
  /// In en, this message translates to:
  /// **'Great! +{points} focus points'**
  String singleTaskFocusRewardSnackBonus(String points);

  /// No description provided for @singleTaskAbandonSnack.
  ///
  /// In en, this message translates to:
  /// **'Incomplete tasks slightly weaken focus'**
  String get singleTaskAbandonSnack;

  /// No description provided for @gamesHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Games 🎮'**
  String get gamesHubTitle;

  /// No description provided for @gamePatternMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Pattern Match'**
  String get gamePatternMatchTitle;

  /// No description provided for @gamePatternMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Memorize and recreate the grid pattern'**
  String get gamePatternMatchDesc;

  /// No description provided for @gameNumberMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Number Memory'**
  String get gameNumberMemoryTitle;

  /// No description provided for @gameNumberMemoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remember growing digit sequences'**
  String get gameNumberMemoryDesc;

  /// No description provided for @gameColorWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Word'**
  String get gameColorWordTitle;

  /// No description provided for @gameColorWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the ink color, not the word'**
  String get gameColorWordDesc;

  /// No description provided for @gamesBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score: {score}'**
  String gamesBestScore(int score);

  /// No description provided for @gamesBestDigits.
  ///
  /// In en, this message translates to:
  /// **'Best digits: {digits}'**
  String gamesBestDigits(int digits);

  /// No description provided for @gameRoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Round {current} / {total}'**
  String gameRoundLabel(int current, int total);

  /// No description provided for @gameFinalScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String gameFinalScore(int score);

  /// No description provided for @gameSubmitRound.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get gameSubmitRound;

  /// No description provided for @gameEnterSequence.
  ///
  /// In en, this message translates to:
  /// **'Enter the sequence you saw'**
  String get gameEnterSequence;

  /// No description provided for @gameNumberMemoryResult.
  ///
  /// In en, this message translates to:
  /// **'Max digits reached: {digits}'**
  String gameNumberMemoryResult(int digits);

  /// No description provided for @gameColorWordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the color of the ink'**
  String get gameColorWordPrompt;

  /// No description provided for @gameStroopResult.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String gameStroopResult(int correct, int total);

  /// No description provided for @gameStroopStats.
  ///
  /// In en, this message translates to:
  /// **'{correct} correct · {wrong} wrong'**
  String gameStroopStats(int correct, int wrong);

  /// No description provided for @gameDigitSpanIntro.
  ///
  /// In en, this message translates to:
  /// **'Digits appear one at a time. Memorize the order, then enter them on the keypad.'**
  String get gameDigitSpanIntro;

  /// No description provided for @gameDigitSpanWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch the digits'**
  String get gameDigitSpanWatch;

  /// No description provided for @gameDigitSpanClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get gameDigitSpanClear;

  /// No description provided for @gameDigitSpanDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get gameDigitSpanDelete;

  /// No description provided for @gameDigitSpanCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get gameDigitSpanCorrect;

  /// No description provided for @gameDigitSpanWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite — try the next sequence'**
  String get gameDigitSpanWrong;

  /// No description provided for @gameDigitSpanLevel.
  ///
  /// In en, this message translates to:
  /// **'Length: {digits} digits'**
  String gameDigitSpanLevel(int digits);

  /// No description provided for @gameDigitSpanLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Best span this session: {digits}'**
  String gameDigitSpanLengthLabel(int digits);

  /// No description provided for @focusedThinkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Focused Thinking Challenge'**
  String get focusedThinkingTitle;

  /// No description provided for @focusedThinkingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one topic and think about it deeply'**
  String get focusedThinkingSubtitle;

  /// No description provided for @focusedThinkingDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get focusedThinkingDurationLabel;

  /// No description provided for @focusedThinkingStart.
  ///
  /// In en, this message translates to:
  /// **'Start thinking'**
  String get focusedThinkingStart;

  /// No description provided for @focusedThinkingGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Thinking Guide'**
  String get focusedThinkingGuideTitle;

  /// No description provided for @focusedThinkingStillThinking.
  ///
  /// In en, this message translates to:
  /// **'Still thinking about {topic}?'**
  String focusedThinkingStillThinking(String topic);

  /// No description provided for @focusedThinkingYes.
  ///
  /// In en, this message translates to:
  /// **'Yes ✓'**
  String get focusedThinkingYes;

  /// No description provided for @focusedThinkingNo.
  ///
  /// In en, this message translates to:
  /// **'Drifted ✗'**
  String get focusedThinkingNo;

  /// No description provided for @focusedThinkingFocusScore.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the time you stayed focused'**
  String focusedThinkingFocusScore(int percent);

  /// No description provided for @focusedThinkingDistractions.
  ///
  /// In en, this message translates to:
  /// **'Temporary Distractions logged: {count}'**
  String focusedThinkingDistractions(int count);

  /// No description provided for @focusedThinkingInsightsSaved.
  ///
  /// In en, this message translates to:
  /// **'Insights saved: {count}'**
  String focusedThinkingInsightsSaved(int count);

  /// No description provided for @focusedThinkingInsightsHint.
  ///
  /// In en, this message translates to:
  /// **'Note your key insights'**
  String get focusedThinkingInsightsHint;

  /// No description provided for @focusedThinkingSaveInsight.
  ///
  /// In en, this message translates to:
  /// **'Save insight'**
  String get focusedThinkingSaveInsight;

  /// No description provided for @homeQuickFocusedThinking.
  ///
  /// In en, this message translates to:
  /// **'Deep thinking 🧠'**
  String get homeQuickFocusedThinking;

  /// No description provided for @homeQuickCrossword.
  ///
  /// In en, this message translates to:
  /// **'Crossword ✏️'**
  String get homeQuickCrossword;

  /// No description provided for @crosswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Crossword'**
  String get crosswordTitle;

  /// No description provided for @crosswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Brain-themed Arabic crossword puzzles'**
  String get crosswordDesc;

  /// No description provided for @crosswordPlayNow.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get crosswordPlayNow;

  /// No description provided for @crosswordTabAcross.
  ///
  /// In en, this message translates to:
  /// **'Across ↔'**
  String get crosswordTabAcross;

  /// No description provided for @crosswordTabDown.
  ///
  /// In en, this message translates to:
  /// **'Down ↕'**
  String get crosswordTabDown;

  /// No description provided for @crosswordEnterLetter.
  ///
  /// In en, this message translates to:
  /// **'Enter letter'**
  String get crosswordEnterLetter;

  /// No description provided for @gameNBackTitle.
  ///
  /// In en, this message translates to:
  /// **'N-Back 🧠'**
  String get gameNBackTitle;

  /// No description provided for @gameNBackDesc.
  ///
  /// In en, this message translates to:
  /// **'Strongest science-backed working memory training'**
  String get gameNBackDesc;

  /// No description provided for @gameNBackIntro.
  ///
  /// In en, this message translates to:
  /// **'This is scientifically the strongest game for working memory'**
  String get gameNBackIntro;

  /// No description provided for @gameNBackLevel.
  ///
  /// In en, this message translates to:
  /// **'N={n} — {current}/{total}'**
  String gameNBackLevel(int n, int current, int total);

  /// No description provided for @gameNBackMatch.
  ///
  /// In en, this message translates to:
  /// **'Match!'**
  String get gameNBackMatch;

  /// No description provided for @gameNBackNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get gameNBackNext;

  /// No description provided for @gameNBackIntroDetail.
  ///
  /// In en, this message translates to:
  /// **'A square lights up on the 3×3 grid. Press Match if it is in the same place as 2 steps ago; otherwise press Next.'**
  String get gameNBackIntroDetail;

  /// No description provided for @gameNBackStats.
  ///
  /// In en, this message translates to:
  /// **'{correct} correct · {wrong} wrong'**
  String gameNBackStats(int correct, int wrong);

  /// No description provided for @gameNBackSessionResult.
  ///
  /// In en, this message translates to:
  /// **'Done — {correct} correct, {wrong} wrong'**
  String gameNBackSessionResult(int correct, int wrong);

  /// No description provided for @gameNBackResult.
  ///
  /// In en, this message translates to:
  /// **'Max N reached: {n}'**
  String gameNBackResult(int n);

  /// No description provided for @gameNBackBonus.
  ///
  /// In en, this message translates to:
  /// **'+{points} BCS earned'**
  String gameNBackBonus(String points);

  /// No description provided for @gamesBestNLevel.
  ///
  /// In en, this message translates to:
  /// **'Best N: {n}'**
  String gamesBestNLevel(int n);

  /// No description provided for @gameSpeedSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed Sort'**
  String get gameSpeedSortTitle;

  /// No description provided for @gameSpeedSortDesc.
  ///
  /// In en, this message translates to:
  /// **'Sort falling numbers into even/odd buckets'**
  String get gameSpeedSortDesc;

  /// No description provided for @gameSpeedSortEven.
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get gameSpeedSortEven;

  /// No description provided for @gameSpeedSortOdd.
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get gameSpeedSortOdd;

  /// No description provided for @gameSpeedSortCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct: {count}'**
  String gameSpeedSortCorrect(int count);

  /// No description provided for @gameSpeedSortResult.
  ///
  /// In en, this message translates to:
  /// **'Done! {correct} correct, {wrong} wrong'**
  String gameSpeedSortResult(int correct, int wrong);

  /// No description provided for @gameStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get gameStart;

  /// No description provided for @bciCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clarity Index'**
  String get bciCardTitle;

  /// No description provided for @bciCardTitleEn.
  ///
  /// In en, this message translates to:
  /// **'BRAIN CLARITY INDEX'**
  String get bciCardTitleEn;

  /// No description provided for @bciCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'BCI Engine · Live update'**
  String get bciCardSubtitle;

  /// No description provided for @bciCardAssessmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly assessment'**
  String get bciCardAssessmentLabel;

  /// No description provided for @bciCardAdherenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily adherence'**
  String get bciCardAdherenceLabel;

  /// No description provided for @bciCardWeightAssessment.
  ///
  /// In en, this message translates to:
  /// **'60%'**
  String get bciCardWeightAssessment;

  /// No description provided for @bciCardWeightAdherence.
  ///
  /// In en, this message translates to:
  /// **'40%'**
  String get bciCardWeightAdherence;

  /// No description provided for @bciCardStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'Peak focus'**
  String get bciCardStatusHigh;

  /// No description provided for @bciCardStatusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable focus'**
  String get bciCardStatusStable;

  /// No description provided for @bciCardStatusMild.
  ///
  /// In en, this message translates to:
  /// **'Mild fog'**
  String get bciCardStatusMild;

  /// No description provided for @bciCardStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning — review your habits'**
  String get bciCardStatusWarning;

  /// No description provided for @bciCardNoAssessment.
  ///
  /// In en, this message translates to:
  /// **'Complete the weekly assessment for full BCI'**
  String get bciCardNoAssessment;

  /// No description provided for @bciCardLoading.
  ///
  /// In en, this message translates to:
  /// **'Calculating BCI...'**
  String get bciCardLoading;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecuritySection;

  /// No description provided for @settingsBiometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric app lock'**
  String get settingsBiometricLock;

  /// No description provided for @settingsBiometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require authentication when opening the app (device PIN fallback)'**
  String get settingsBiometricLockSubtitle;

  /// No description provided for @settingsBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get settingsBiometricUnavailable;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or device PIN to continue'**
  String get biometricLockSubtitle;

  /// No description provided for @biometricLockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock Brain Clean'**
  String get biometricLockButton;

  /// No description provided for @securityCompromisedBanner.
  ///
  /// In en, this message translates to:
  /// **'Warning: this device may be compromised. Local data only — cloud sync is disabled.'**
  String get securityCompromisedBanner;

  /// No description provided for @brainCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Check'**
  String get brainCheckTitle;

  /// No description provided for @brainCheckIntroNonMedical.
  ///
  /// In en, this message translates to:
  /// **'This is a self-check, not a medical diagnosis.'**
  String get brainCheckIntroNonMedical;

  /// No description provided for @brainCheckStart.
  ///
  /// In en, this message translates to:
  /// **'Start Brain Check'**
  String get brainCheckStart;

  /// No description provided for @brainCheckContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get brainCheckContinue;

  /// No description provided for @brainCheckStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get brainCheckStartOver;

  /// No description provided for @brainCheckEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Start Brain Check to build your profile.'**
  String get brainCheckEmptyState;

  /// No description provided for @brainCheckQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String brainCheckQuestionProgress(int current, int total);

  /// No description provided for @brainCheckSectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Part {current} of {total}'**
  String brainCheckSectionProgress(int current, int total);

  /// No description provided for @brainCheckComplete.
  ///
  /// In en, this message translates to:
  /// **'Check complete'**
  String get brainCheckComplete;

  /// No description provided for @brainCheckResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your Brain Check?'**
  String get brainCheckResumeTitle;

  /// No description provided for @brainCheckSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your answers. They are still on this screen.'**
  String get brainCheckSaveError;

  /// No description provided for @brainCheckLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Brain Check…'**
  String get brainCheckLoading;

  /// No description provided for @brainCheckExit.
  ///
  /// In en, this message translates to:
  /// **'Exit Brain Check'**
  String get brainCheckExit;

  /// No description provided for @brainCheckBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get brainCheckBack;

  /// No description provided for @brainCheckSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get brainCheckSaving;

  /// No description provided for @brainCheckFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish check'**
  String get brainCheckFinish;

  /// No description provided for @brainCheckSelectAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer to continue.'**
  String get brainCheckSelectAnswerHint;

  /// No description provided for @brainCheckAutosaveHint.
  ///
  /// In en, this message translates to:
  /// **'Your answers save on this device as you go.'**
  String get brainCheckAutosaveHint;

  /// No description provided for @brainCheckAnswerChoices.
  ///
  /// In en, this message translates to:
  /// **'Answer choices'**
  String get brainCheckAnswerChoices;

  /// No description provided for @brainCheckAnswerSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get brainCheckAnswerSelected;

  /// No description provided for @brainCheckAnswerUnselected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get brainCheckAnswerUnselected;

  /// No description provided for @brainCheckAnswerYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get brainCheckAnswerYes;

  /// No description provided for @brainCheckAnswerNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get brainCheckAnswerNo;

  /// No description provided for @brainCheckLikert1.
  ///
  /// In en, this message translates to:
  /// **'Strongly disagree'**
  String get brainCheckLikert1;

  /// No description provided for @brainCheckLikert2.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get brainCheckLikert2;

  /// No description provided for @brainCheckLikert3.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get brainCheckLikert3;

  /// No description provided for @brainCheckLikert4.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get brainCheckLikert4;

  /// No description provided for @brainCheckLikert5.
  ///
  /// In en, this message translates to:
  /// **'Strongly agree'**
  String get brainCheckLikert5;

  /// No description provided for @brainCheckFrequency1.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get brainCheckFrequency1;

  /// No description provided for @brainCheckFrequency2.
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get brainCheckFrequency2;

  /// No description provided for @brainCheckFrequency3.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get brainCheckFrequency3;

  /// No description provided for @brainCheckFrequency4.
  ///
  /// In en, this message translates to:
  /// **'Often'**
  String get brainCheckFrequency4;

  /// No description provided for @brainCheckFrequency5.
  ///
  /// In en, this message translates to:
  /// **'Very often'**
  String get brainCheckFrequency5;

  /// No description provided for @brainCheckBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'A short pause'**
  String get brainCheckBreakTitle;

  /// No description provided for @brainCheckBreakBody.
  ///
  /// In en, this message translates to:
  /// **'Next: {sectionTitle}'**
  String brainCheckBreakBody(String sectionTitle);

  /// No description provided for @brainCheckCompletionBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for finishing this self-report. Your check is ready to save on this device.'**
  String get brainCheckCompletionBody;

  /// No description provided for @brainCheckConfigError.
  ///
  /// In en, this message translates to:
  /// **'Brain Check questions are unavailable right now.'**
  String get brainCheckConfigError;

  /// No description provided for @brainCheckRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over?'**
  String get brainCheckRestartTitle;

  /// No description provided for @brainCheckRestartBody.
  ///
  /// In en, this message translates to:
  /// **'This clears your unfinished Brain Check answers on this device. Onboarding progress and past completed profiles stay untouched.'**
  String get brainCheckRestartBody;

  /// No description provided for @brainCheckRestartCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get brainCheckRestartCancel;

  /// No description provided for @brainCheckRestartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get brainCheckRestartConfirm;

  /// No description provided for @brainCheckCompleteBoundaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Check saved'**
  String get brainCheckCompleteBoundaryTitle;

  /// No description provided for @brainCheckCompleteBoundaryBody.
  ///
  /// In en, this message translates to:
  /// **'Your self-report is stored on this device. Continue to build your Brain Profile snapshot.'**
  String get brainCheckCompleteBoundaryBody;

  /// No description provided for @brainCheckCompleteBoundaryContinue.
  ///
  /// In en, this message translates to:
  /// **'Build Brain Profile'**
  String get brainCheckCompleteBoundaryContinue;

  /// No description provided for @brainProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Profile'**
  String get brainProfileTitle;

  /// No description provided for @brainProfileBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building your Brain Profile…'**
  String get brainProfileBuilding;

  /// No description provided for @brainProfileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Brain Profile'**
  String get brainProfileLoading;

  /// No description provided for @brainProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'No Brain Profile yet'**
  String get brainProfileMissing;

  /// No description provided for @brainProfileEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Complete a Brain Check to create your first snapshot.'**
  String get brainProfileEmptyHint;

  /// No description provided for @brainProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile calculation is unavailable right now.'**
  String get brainProfileUnavailable;

  /// No description provided for @brainProfileRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get brainProfileRetry;

  /// No description provided for @brainProfileGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get brainProfileGoHome;

  /// No description provided for @brainProfileOrientation.
  ///
  /// In en, this message translates to:
  /// **'A calm look at your snapshot'**
  String get brainProfileOrientation;

  /// No description provided for @brainProfileScoreHeading.
  ///
  /// In en, this message translates to:
  /// **'Recovery Score estimate'**
  String get brainProfileScoreHeading;

  /// No description provided for @brainProfileScorePendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimate pending'**
  String get brainProfileScorePendingLabel;

  /// No description provided for @brainProfileScorePendingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Recovery Score estimate is pending. Domain summaries are available from your answers.'**
  String get brainProfileScorePendingSemantics;

  /// No description provided for @brainProfileScoreSemantics.
  ///
  /// In en, this message translates to:
  /// **'Recovery Score estimate: {value}'**
  String brainProfileScoreSemantics(String value);

  /// No description provided for @brainProfileConfidenceHeading.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get brainProfileConfidenceHeading;

  /// No description provided for @brainProfileConfidenceProvisional.
  ///
  /// In en, this message translates to:
  /// **'Provisional'**
  String get brainProfileConfidenceProvisional;

  /// No description provided for @brainProfileConfidenceModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get brainProfileConfidenceModerate;

  /// No description provided for @brainProfileConfidenceSolid.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get brainProfileConfidenceSolid;

  /// No description provided for @brainProfileBandHeading.
  ///
  /// In en, this message translates to:
  /// **'Current band'**
  String get brainProfileBandHeading;

  /// No description provided for @brainProfileBandMeaning.
  ///
  /// In en, this message translates to:
  /// **'A calm product label for this self-report estimate — not a clinical severity.'**
  String get brainProfileBandMeaning;

  /// No description provided for @brainProfileMeansHeading.
  ///
  /// In en, this message translates to:
  /// **'What this means'**
  String get brainProfileMeansHeading;

  /// No description provided for @brainProfileMeansBody.
  ///
  /// In en, this message translates to:
  /// **'This is a self-reported starting snapshot. It highlights stronger reported areas and current support priorities based on your Brain Check answers.'**
  String get brainProfileMeansBody;

  /// No description provided for @brainProfileDoesNotMeanHeading.
  ///
  /// In en, this message translates to:
  /// **'What this does not mean'**
  String get brainProfileDoesNotMeanHeading;

  /// No description provided for @brainProfileScoreUnavailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimate unavailable'**
  String get brainProfileScoreUnavailableLabel;

  /// No description provided for @brainProfileScoreUnavailableSemantics.
  ///
  /// In en, this message translates to:
  /// **'Recovery Score estimate is unavailable. No number is shown.'**
  String get brainProfileScoreUnavailableSemantics;

  /// No description provided for @brainProfileScoreUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'A Recovery Score could not be estimated from this check. Your answers remain saved. Complete a valid Brain Check to continue to a Recovery Plan.'**
  String get brainProfileScoreUnavailableBody;

  /// No description provided for @brainProfileContinueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A Recovery Plan needs a valid Recovery Score estimate.'**
  String get brainProfileContinueUnavailable;

  /// No description provided for @brainProfileMissingEvent.
  ///
  /// In en, this message translates to:
  /// **'Complete a Brain Check first.'**
  String get brainProfileMissingEvent;

  /// No description provided for @brainProfileBuildingHint.
  ///
  /// In en, this message translates to:
  /// **'Preparing your self-report snapshot on this device…'**
  String get brainProfileBuildingHint;

  /// No description provided for @brainProfileDomainEstimateHeading.
  ///
  /// In en, this message translates to:
  /// **'Current estimate'**
  String get brainProfileDomainEstimateHeading;

  /// No description provided for @brainProfileDomainStrongerLabel.
  ///
  /// In en, this message translates to:
  /// **'Stronger reported area'**
  String get brainProfileDomainStrongerLabel;

  /// No description provided for @brainProfileDomainSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Current support priority'**
  String get brainProfileDomainSupportLabel;

  /// No description provided for @brainProfileDomainNeutralLabel.
  ///
  /// In en, this message translates to:
  /// **'Based on your current answers'**
  String get brainProfileDomainNeutralLabel;

  /// No description provided for @brainProfileDomainBasedOnAnswers.
  ///
  /// In en, this message translates to:
  /// **'Based on themes from your current Brain Check answers — not raw scores.'**
  String get brainProfileDomainBasedOnAnswers;

  /// No description provided for @brainProfileDomainNonMedical.
  ///
  /// In en, this message translates to:
  /// **'Not a medical diagnosis. Not brain-damage detection. Not an intelligence score.'**
  String get brainProfileDomainNonMedical;

  /// No description provided for @brainProfileDomainPlanPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'A gentle Recovery Plan step may focus here next — that comes after you continue.'**
  String get brainProfileDomainPlanPreviewHint;

  /// No description provided for @brainProfileDomainsHeading.
  ///
  /// In en, this message translates to:
  /// **'Domain summary'**
  String get brainProfileDomainsHeading;

  /// No description provided for @brainProfileDomainNoData.
  ///
  /// In en, this message translates to:
  /// **'No answers in this area yet'**
  String get brainProfileDomainNoData;

  /// No description provided for @brainProfileDomainMean.
  ///
  /// In en, this message translates to:
  /// **'Reported average: {value}'**
  String brainProfileDomainMean(String value);

  /// No description provided for @brainProfileDomainClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get brainProfileDomainClose;

  /// No description provided for @brainProfileExplainHeading.
  ///
  /// In en, this message translates to:
  /// **'What this means'**
  String get brainProfileExplainHeading;

  /// No description provided for @brainProfileContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to Recovery Plan'**
  String get brainProfileContinue;

  /// No description provided for @brainProfileReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Brain Profile is ready'**
  String get brainProfileReadyTitle;

  /// No description provided for @brainProfileReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your Recovery Plan is the next calm step when you continue from your Profile.'**
  String get brainProfileReadyBody;

  /// No description provided for @brainProfileHistoricalBadge.
  ///
  /// In en, this message translates to:
  /// **'Earlier snapshot'**
  String get brainProfileHistoricalBadge;

  /// No description provided for @recoveryPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Plan'**
  String get recoveryPlanTitle;

  /// No description provided for @recoveryPlanBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building your Recovery Plan…'**
  String get recoveryPlanBuilding;

  /// No description provided for @recoveryPlanLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Recovery Plan'**
  String get recoveryPlanLoading;

  /// No description provided for @recoveryPlanReady.
  ///
  /// In en, this message translates to:
  /// **'Your Recovery Plan is ready'**
  String get recoveryPlanReady;

  /// No description provided for @recoveryPlanStarterReady.
  ///
  /// In en, this message translates to:
  /// **'A calm starter plan is ready'**
  String get recoveryPlanStarterReady;

  /// No description provided for @recoveryPlanMissing.
  ///
  /// In en, this message translates to:
  /// **'No Recovery Plan yet'**
  String get recoveryPlanMissing;

  /// No description provided for @recoveryPlanMissingProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete a Brain Check and Brain Profile first.'**
  String get recoveryPlanMissingProfile;

  /// No description provided for @recoveryPlanScoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A full plan needs a valid Recovery Score estimate. A starter plan may still be available.'**
  String get recoveryPlanScoreUnavailable;

  /// No description provided for @recoveryPlanUnsupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'This plan model is not supported on this version.'**
  String get recoveryPlanUnsupportedVersion;

  /// No description provided for @recoveryPlanGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Could not build your plan right now. Try again.'**
  String get recoveryPlanGenerationError;

  /// No description provided for @recoveryPlanRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get recoveryPlanRetry;

  /// No description provided for @recoveryPlanGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get recoveryPlanGoHome;

  /// No description provided for @recoveryPlanBuildCta.
  ///
  /// In en, this message translates to:
  /// **'Build Recovery Plan'**
  String get recoveryPlanBuildCta;

  /// No description provided for @recoveryPlanMainFocus.
  ///
  /// In en, this message translates to:
  /// **'Main focus'**
  String get recoveryPlanMainFocus;

  /// No description provided for @recoveryPlanPrioritiesHeading.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get recoveryPlanPrioritiesHeading;

  /// No description provided for @recoveryPlanNoPriorities.
  ///
  /// In en, this message translates to:
  /// **'No priority domains in this starter plan'**
  String get recoveryPlanNoPriorities;

  /// No description provided for @recoveryPlanStrongerHeading.
  ///
  /// In en, this message translates to:
  /// **'Already helping'**
  String get recoveryPlanStrongerHeading;

  /// No description provided for @recoveryPlanConfidenceHeading.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get recoveryPlanConfidenceHeading;

  /// No description provided for @recoveryPlanTimeHeading.
  ///
  /// In en, this message translates to:
  /// **'Daily time'**
  String get recoveryPlanTimeHeading;

  /// No description provided for @recoveryPlanTimeRange.
  ///
  /// In en, this message translates to:
  /// **'About {min}–{max} minutes'**
  String recoveryPlanTimeRange(String min, String max);

  /// No description provided for @recoveryPlanIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get recoveryPlanIntensityLabel;

  /// No description provided for @recoveryPlanMinimumPath.
  ///
  /// In en, this message translates to:
  /// **'Minimum path'**
  String get recoveryPlanMinimumPath;

  /// No description provided for @recoveryPlanStandardPath.
  ///
  /// In en, this message translates to:
  /// **'Standard path'**
  String get recoveryPlanStandardPath;

  /// No description provided for @recoveryPlanBecauseHeading.
  ///
  /// In en, this message translates to:
  /// **'Why this plan today'**
  String get recoveryPlanBecauseHeading;

  /// No description provided for @recoveryPlanTodayPreview.
  ///
  /// In en, this message translates to:
  /// **'Today preview'**
  String get recoveryPlanTodayPreview;

  /// No description provided for @recoveryPlanContinueToday.
  ///
  /// In en, this message translates to:
  /// **'Continue to Today'**
  String get recoveryPlanContinueToday;

  /// No description provided for @recoveryPlanSkipHint.
  ///
  /// In en, this message translates to:
  /// **'Skipping a step never counts against you.'**
  String get recoveryPlanSkipHint;

  /// No description provided for @recoveryPlanOptionalTag.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get recoveryPlanOptionalTag;

  /// No description provided for @recoveryPlanNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps listed'**
  String get recoveryPlanNoSteps;

  /// No description provided for @recoveryPlanStarterBadge.
  ///
  /// In en, this message translates to:
  /// **'Starter plan'**
  String get recoveryPlanStarterBadge;

  /// No description provided for @recoveryPlanTodayReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today is ready to begin'**
  String get recoveryPlanTodayReadyTitle;

  /// No description provided for @recoveryPlanTodayReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily session player arrives in a later step. Your Recovery Plan is saved on this device.'**
  String get recoveryPlanTodayReadyBody;

  /// No description provided for @recoveryPlanCalmOrientation.
  ///
  /// In en, this message translates to:
  /// **'Your Recovery Plan'**
  String get recoveryPlanCalmOrientation;

  /// No description provided for @recoveryPlanCalmOrientationBody.
  ///
  /// In en, this message translates to:
  /// **'This plan is a practical estimate based on your current Brain Profile. It is not a diagnosis or treatment. You can adjust it later.'**
  String get recoveryPlanCalmOrientationBody;

  /// No description provided for @recoveryPlanFitsProfile.
  ///
  /// In en, this message translates to:
  /// **'It matches the priorities in your current profile estimate.'**
  String get recoveryPlanFitsProfile;

  /// No description provided for @recoveryPlanTodayFitHeading.
  ///
  /// In en, this message translates to:
  /// **'How today fits'**
  String get recoveryPlanTodayFitHeading;

  /// No description provided for @recoveryPlanOpenToday.
  ///
  /// In en, this message translates to:
  /// **'Open Today'**
  String get recoveryPlanOpenToday;

  /// No description provided for @recoveryPlanAboutDetails.
  ///
  /// In en, this message translates to:
  /// **'Why this plan'**
  String get recoveryPlanAboutDetails;

  /// No description provided for @recoveryPlanPathDetails.
  ///
  /// In en, this message translates to:
  /// **'Path details'**
  String get recoveryPlanPathDetails;

  /// No description provided for @recoveryPlanStepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String recoveryPlanStepCount(int count);

  /// No description provided for @v2TodayPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first Today'**
  String get v2TodayPreviewTitle;

  /// No description provided for @v2TodayPreviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Today preview'**
  String get v2TodayPreviewLoading;

  /// No description provided for @v2TodayPreviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Today preview'**
  String get v2TodayPreviewHeading;

  /// No description provided for @v2TodayPreviewOrientation.
  ///
  /// In en, this message translates to:
  /// **'Your day starts with one clear step. Completing it later will mark the day on your plan.'**
  String get v2TodayPreviewOrientation;

  /// No description provided for @v2TodayPreviewActHeading.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get v2TodayPreviewActHeading;

  /// No description provided for @v2TodayPreviewFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s practice'**
  String get v2TodayPreviewFallbackTitle;

  /// No description provided for @v2TodayPreviewBecauseHeading.
  ///
  /// In en, this message translates to:
  /// **'Why this step today'**
  String get v2TodayPreviewBecauseHeading;

  /// No description provided for @v2TodayPreviewCompletionMeaning.
  ///
  /// In en, this message translates to:
  /// **'Finishing this step later will count as your day done. Skipping stays allowed with no negative mark.'**
  String get v2TodayPreviewCompletionMeaning;

  /// No description provided for @v2TodayPreviewContinueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue — first step ready'**
  String get v2TodayPreviewContinueCta;

  /// No description provided for @v2TodayPreviewMissingAct.
  ///
  /// In en, this message translates to:
  /// **'Today’s step is not available yet. Rebuild your Recovery Plan.'**
  String get v2TodayPreviewMissingAct;

  /// No description provided for @v2TodayReadyLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your first step'**
  String get v2TodayReadyLoading;

  /// No description provided for @v2TodayReadyFirstStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first step is ready'**
  String get v2TodayReadyFirstStepTitle;

  /// No description provided for @v2TodayReadyFirstStepBody.
  ///
  /// In en, this message translates to:
  /// **'Your Recovery Plan is saved. Open Today to begin your first daily session when you are ready. You can leave and return without losing progress.'**
  String get v2TodayReadyFirstStepBody;

  /// No description provided for @v2TodayReadyJourneySaved.
  ///
  /// In en, this message translates to:
  /// **'First-time setup is complete on this device.'**
  String get v2TodayReadyJourneySaved;

  /// No description provided for @v2TodayReadyProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved on this device.'**
  String get v2TodayReadyProgressSaved;

  /// No description provided for @v2TodayReadyPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Open Today'**
  String get v2TodayReadyPrimaryCta;

  /// No description provided for @v2TodayReadyReviewPreview.
  ///
  /// In en, this message translates to:
  /// **'Review Today preview'**
  String get v2TodayReadyReviewPreview;

  /// No description provided for @v2TodayReadyCorruptPlan.
  ///
  /// In en, this message translates to:
  /// **'This plan could not be read safely. Rebuild it calmly when you are ready.'**
  String get v2TodayReadyCorruptPlan;

  /// No description provided for @v2TodayReadyPersistFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save progress right now. Try again.'**
  String get v2TodayReadyPersistFailed;

  /// No description provided for @v2TodayHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get v2TodayHomeTitle;

  /// No description provided for @v2TodayHomeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Today'**
  String get v2TodayHomeLoading;

  /// No description provided for @v2TodayHomeOrientation.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get v2TodayHomeOrientation;

  /// No description provided for @v2TodayHomeOrientationBody.
  ///
  /// In en, this message translates to:
  /// **'One clear action from your daily program. Nothing extra.'**
  String get v2TodayHomeOrientationBody;

  /// No description provided for @v2TodayHomeStandardPathHint.
  ///
  /// In en, this message translates to:
  /// **'Stay with today\'s practice — small steps rebuild focus.'**
  String get v2TodayHomeStandardPathHint;

  /// No description provided for @v2TodayHomeStatusHeading.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get v2TodayHomeStatusHeading;

  /// No description provided for @v2TodayHomeStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get v2TodayHomeStatusReady;

  /// No description provided for @v2TodayHomeStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get v2TodayHomeStatusInProgress;

  /// No description provided for @v2TodayHomeStatusReflect.
  ///
  /// In en, this message translates to:
  /// **'Almost done — finish check-in'**
  String get v2TodayHomeStatusReflect;

  /// No description provided for @v2TodayHomeStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get v2TodayHomeStatusDone;

  /// No description provided for @v2TodayHomeStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Progress saved — keep going tomorrow'**
  String get v2TodayHomeStatusPartial;

  /// No description provided for @v2TodayHomeCtaStart.
  ///
  /// In en, this message translates to:
  /// **'Start today\'s program'**
  String get v2TodayHomeCtaStart;

  /// No description provided for @v2TodayHomeCtaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue program'**
  String get v2TodayHomeCtaContinue;

  /// No description provided for @v2TodayHomeCtaViewCompleted.
  ///
  /// In en, this message translates to:
  /// **'View completed session'**
  String get v2TodayHomeCtaViewCompleted;

  /// No description provided for @v2TodayHomeViewPlan.
  ///
  /// In en, this message translates to:
  /// **'View daily program'**
  String get v2TodayHomeViewPlan;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreetingName(String name);

  /// No description provided for @homeFocusLevelTag.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get homeFocusLevelTag;

  /// No description provided for @homeFocusImprovement.
  ///
  /// In en, this message translates to:
  /// **'Up {percent}% from your first check'**
  String homeFocusImprovement(int percent);

  /// No description provided for @homeFocusImprovementPending.
  ///
  /// In en, this message translates to:
  /// **'Complete a Brain Check to track recovery'**
  String get homeFocusImprovementPending;

  /// No description provided for @homeMetricStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get homeMetricStreakLabel;

  /// No description provided for @homeMetricExercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s exercises'**
  String get homeMetricExercisesLabel;

  /// No description provided for @homeSuggestedExerciseBadge.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get homeSuggestedExerciseBadge;

  /// No description provided for @homeProgramPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily program'**
  String get homeProgramPathTitle;

  /// No description provided for @homeProgramPathDay.
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total}'**
  String homeProgramPathDay(int current, int total);

  /// No description provided for @homeTodaySessionHeading.
  ///
  /// In en, this message translates to:
  /// **'Your daily program'**
  String get homeTodaySessionHeading;

  /// No description provided for @homeDateTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeDateTodayLabel;

  /// No description provided for @homeDatePrevDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get homeDatePrevDay;

  /// No description provided for @homeDateNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get homeDateNextDay;

  /// No description provided for @homeReturnToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get homeReturnToToday;

  /// No description provided for @homePomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus timer'**
  String get homePomodoroTitle;

  /// No description provided for @homePomodoroStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get homePomodoroStart;

  /// No description provided for @homePomodoroPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get homePomodoroPause;

  /// No description provided for @homePomodoroMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'25 min'**
  String get homePomodoroMinutesShort;

  /// No description provided for @homePomodoroMinutesLong.
  ///
  /// In en, this message translates to:
  /// **'50 min'**
  String get homePomodoroMinutesLong;

  /// No description provided for @homePomodoroMinus5.
  ///
  /// In en, this message translates to:
  /// **'−5 min'**
  String get homePomodoroMinus5;

  /// No description provided for @homePomodoroPlus5.
  ///
  /// In en, this message translates to:
  /// **'+5 min'**
  String get homePomodoroPlus5;

  /// No description provided for @homeWeeklyTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly test'**
  String get homeWeeklyTestTitle;

  /// No description provided for @homeWeeklyTestLocked.
  ///
  /// In en, this message translates to:
  /// **'Opens every 7 days'**
  String get homeWeeklyTestLocked;

  /// No description provided for @homeWeeklyTestDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Opens in {days} days'**
  String homeWeeklyTestDaysLeft(int days);

  /// No description provided for @homeWeeklyTestReady.
  ///
  /// In en, this message translates to:
  /// **'Ready — start this week\'s check'**
  String get homeWeeklyTestReady;

  /// No description provided for @homeWeeklyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get homeWeeklyReportTitle;

  /// No description provided for @homeWeeklyReportLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked until your next review window'**
  String get homeWeeklyReportLocked;

  /// No description provided for @homeWeeklyReportDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Available in {days} days'**
  String homeWeeklyReportDaysLeft(int days);

  /// No description provided for @homeWeeklyReportReady.
  ///
  /// In en, this message translates to:
  /// **'Your weekly report is ready'**
  String get homeWeeklyReportReady;

  /// No description provided for @homeBaselineTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Baseline test'**
  String get homeBaselineTestTitle;

  /// No description provided for @homeBaselineTestPending.
  ///
  /// In en, this message translates to:
  /// **'Not completed yet'**
  String get homeBaselineTestPending;

  /// No description provided for @homeBaselineTestScore.
  ///
  /// In en, this message translates to:
  /// **'Baseline score {score}'**
  String homeBaselineTestScore(int score);

  /// No description provided for @homeSafaCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Safa'**
  String get homeSafaCardTitle;

  /// No description provided for @homeSafaCardBody.
  ///
  /// In en, this message translates to:
  /// **'Calm support for today\'s step'**
  String get homeSafaCardBody;

  /// No description provided for @homeSafaCardCta.
  ///
  /// In en, this message translates to:
  /// **'Open Safa'**
  String get homeSafaCardCta;

  /// No description provided for @homePastProgramHeading.
  ///
  /// In en, this message translates to:
  /// **'Program for this day'**
  String get homePastProgramHeading;

  /// No description provided for @homePastProgramEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved program for this day yet.'**
  String get homePastProgramEmpty;

  /// No description provided for @homeUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get homeUpgradeToPro;

  /// No description provided for @homeRecoveryFormulaTitle.
  ///
  /// In en, this message translates to:
  /// **'How recovery % is calculated'**
  String get homeRecoveryFormulaTitle;

  /// No description provided for @homeRecoveryFormulaBody.
  ///
  /// In en, this message translates to:
  /// **'40% daily program completion today\n35% baseline brain check score\n25% weekly test score'**
  String get homeRecoveryFormulaBody;

  /// No description provided for @dailyProgramTimerDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Well done! Your brain thanks you 🧠'**
  String get dailyProgramTimerDoneMessage;

  /// No description provided for @dailyProgramEveningReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening review'**
  String get dailyProgramEveningReviewTitle;

  /// No description provided for @dailyProgramEveningReviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'What did you finish today? What will you improve tomorrow?'**
  String get dailyProgramEveningReviewPrompt;

  /// No description provided for @dailyProgramEveningReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Write a few lines…'**
  String get dailyProgramEveningReviewHint;

  /// No description provided for @dailyProgramEveningReviewSave.
  ///
  /// In en, this message translates to:
  /// **'Save and complete'**
  String get dailyProgramEveningReviewSave;

  /// No description provided for @dailyProgramBenefitLine.
  ///
  /// In en, this message translates to:
  /// **'Completing your daily program improves focus, memory, digital clarity, and reasoning.'**
  String get dailyProgramBenefitLine;

  /// No description provided for @homeBrainCheckBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your brain profile — start the check'**
  String get homeBrainCheckBadgeTitle;

  /// No description provided for @homeBrainCheckBadgeCta.
  ///
  /// In en, this message translates to:
  /// **'Start Brain Check'**
  String get homeBrainCheckBadgeCta;

  /// No description provided for @homeBrainCheckScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Your brain check'**
  String get homeBrainCheckScoreTitle;

  /// No description provided for @homeBrainCheckScoreValue.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String homeBrainCheckScoreValue(int score);

  /// No description provided for @homeBrainCheckRedo.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get homeBrainCheckRedo;

  /// No description provided for @homeDailyProgramEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your daily program'**
  String get homeDailyProgramEmptyTitle;

  /// No description provided for @homeDailyProgramEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A short daily practice to cut screen time and rebuild focus — one clear step at a time.'**
  String get homeDailyProgramEmptyBody;

  /// No description provided for @homeDailyProgramEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Set up program'**
  String get homeDailyProgramEmptyCta;

  /// No description provided for @v2SessionPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get v2SessionPrepareTitle;

  /// No description provided for @v2SessionPreparePurpose.
  ///
  /// In en, this message translates to:
  /// **'A short guided practice from your plan.'**
  String get v2SessionPreparePurpose;

  /// No description provided for @v2SessionPrepareIncludes.
  ///
  /// In en, this message translates to:
  /// **'This session includes:'**
  String get v2SessionPrepareIncludes;

  /// No description provided for @v2SessionPathHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose your path'**
  String get v2SessionPathHeading;

  /// No description provided for @v2SessionPathNoShame.
  ///
  /// In en, this message translates to:
  /// **'Minimum is complete and useful. Standard adds optional depth.'**
  String get v2SessionPathNoShame;

  /// No description provided for @v2SessionA11yHint.
  ///
  /// In en, this message translates to:
  /// **'Each step offers an accessibility alternative.'**
  String get v2SessionA11yHint;

  /// No description provided for @v2SessionStartCta.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get v2SessionStartCta;

  /// No description provided for @v2SessionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get v2SessionClose;

  /// No description provided for @v2SessionActTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s Session'**
  String get v2SessionActTitle;

  /// No description provided for @v2SessionProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String v2SessionProgress(String current, String total);

  /// No description provided for @v2SessionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get v2SessionOptionalLabel;

  /// No description provided for @v2SessionRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get v2SessionRequiredLabel;

  /// No description provided for @v2SessionStartTimer.
  ///
  /// In en, this message translates to:
  /// **'Start optional timer'**
  String get v2SessionStartTimer;

  /// No description provided for @v2SessionTimerContext.
  ///
  /// In en, this message translates to:
  /// **'About {seconds} seconds left on the optional timer'**
  String v2SessionTimerContext(String seconds);

  /// No description provided for @v2SessionMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark step done'**
  String get v2SessionMarkDone;

  /// No description provided for @v2SessionSkipOptional.
  ///
  /// In en, this message translates to:
  /// **'Skip optional step'**
  String get v2SessionSkipOptional;

  /// No description provided for @v2SessionEndEarly.
  ///
  /// In en, this message translates to:
  /// **'End and check in'**
  String get v2SessionEndEarly;

  /// No description provided for @v2SessionReflectTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick check-in'**
  String get v2SessionReflectTitle;

  /// No description provided for @v2SessionReflectPrompt.
  ///
  /// In en, this message translates to:
  /// **'How did today’s session feel?'**
  String get v2SessionReflectPrompt;

  /// No description provided for @v2SessionReflectManageable.
  ///
  /// In en, this message translates to:
  /// **'How manageable was it?'**
  String get v2SessionReflectManageable;

  /// No description provided for @v2SessionReflectHelped.
  ///
  /// In en, this message translates to:
  /// **'Did it help you pause or focus?'**
  String get v2SessionReflectHelped;

  /// No description provided for @v2SessionReflectObstacle.
  ///
  /// In en, this message translates to:
  /// **'Any obstacle? (optional)'**
  String get v2SessionReflectObstacle;

  /// No description provided for @v2SessionChipEasy.
  ///
  /// In en, this message translates to:
  /// **'Manageable'**
  String get v2SessionChipEasy;

  /// No description provided for @v2SessionChipOk.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get v2SessionChipOk;

  /// No description provided for @v2SessionChipHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get v2SessionChipHard;

  /// No description provided for @v2SessionChipYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get v2SessionChipYes;

  /// No description provided for @v2SessionChipSomewhat.
  ///
  /// In en, this message translates to:
  /// **'Somewhat'**
  String get v2SessionChipSomewhat;

  /// No description provided for @v2SessionChipNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get v2SessionChipNotYet;

  /// No description provided for @v2SessionChipNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get v2SessionChipNone;

  /// No description provided for @v2SessionChipDistraction.
  ///
  /// In en, this message translates to:
  /// **'Temporary Distraction'**
  String get v2SessionChipDistraction;

  /// No description provided for @v2SessionChipLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Low energy'**
  String get v2SessionChipLowEnergy;

  /// No description provided for @v2SessionChipTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get v2SessionChipTime;

  /// No description provided for @v2SessionReflectSave.
  ///
  /// In en, this message translates to:
  /// **'Save check-in'**
  String get v2SessionReflectSave;

  /// No description provided for @v2SessionReflectSkipChips.
  ///
  /// In en, this message translates to:
  /// **'Continue without chips'**
  String get v2SessionReflectSkipChips;

  /// No description provided for @v2SessionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get v2SessionSaving;

  /// No description provided for @v2SessionLeaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Well done — you’re done for today'**
  String get v2SessionLeaveSuccess;

  /// No description provided for @v2SessionLeavePartial.
  ///
  /// In en, this message translates to:
  /// **'You paused with care — nothing was lost'**
  String get v2SessionLeavePartial;

  /// No description provided for @v2SessionLeavePath.
  ///
  /// In en, this message translates to:
  /// **'Path: {path}'**
  String v2SessionLeavePath(String path);

  /// No description provided for @v2SessionLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Quiet competence is enough. Leave the app when you are ready.'**
  String get v2SessionLeaveBody;

  /// No description provided for @v2SessionLeaveNext.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, Today will offer one clear next step again.'**
  String get v2SessionLeaveNext;

  /// No description provided for @v2SessionLeaveCta.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get v2SessionLeaveCta;

  /// No description provided for @v2ProgressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No progress yet'**
  String get v2ProgressEmptyTitle;

  /// No description provided for @v2ProgressEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a Today session to start building an honest local record. Nothing is invented when history is empty.'**
  String get v2ProgressEmptyBody;

  /// No description provided for @v2ProgressLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading progress'**
  String get v2ProgressLoading;

  /// No description provided for @v2ProgressPersistFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save progress right now. Try again.'**
  String get v2ProgressPersistFailed;

  /// No description provided for @v2ProgressStatsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions completed'**
  String get v2ProgressStatsSessions;

  /// No description provided for @v2ProgressStatsMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum path sessions'**
  String get v2ProgressStatsMinimum;

  /// No description provided for @v2ProgressStatsStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard path sessions'**
  String get v2ProgressStatsStandard;

  /// No description provided for @v2ProgressStatsRate.
  ///
  /// In en, this message translates to:
  /// **'Completed-day rate'**
  String get v2ProgressStatsRate;

  /// No description provided for @v2ProgressStatsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current completed-day run'**
  String get v2ProgressStatsCurrentStreak;

  /// No description provided for @v2ProgressStatsLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest completed-day run'**
  String get v2ProgressStatsLongestStreak;

  /// No description provided for @v2OnboardingLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get v2OnboardingLoading;

  /// No description provided for @v2OnboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get v2OnboardingContinue;

  /// No description provided for @v2OnboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get v2OnboardingBack;

  /// No description provided for @v2OnboardingRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get v2OnboardingRetry;

  /// No description provided for @v2OnboardingRestart.
  ///
  /// In en, this message translates to:
  /// **'Start onboarding again'**
  String get v2OnboardingRestart;

  /// No description provided for @v2OnboardingGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get v2OnboardingGoHome;

  /// No description provided for @v2OnboardingProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String v2OnboardingProgressLabel(String current, String total);

  /// No description provided for @v2OnboardingProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Onboarding step {current} of {total}'**
  String v2OnboardingProgressSemantics(String current, String total);

  /// No description provided for @v2OnboardingLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get v2OnboardingLanguageArabic;

  /// No description provided for @v2OnboardingLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get v2OnboardingLanguageEnglish;

  /// No description provided for @v2OnboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Brain Clean'**
  String get v2OnboardingWelcomeTitle;

  /// No description provided for @v2OnboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean helps you estimate your current recovery state, build a personalized recovery plan, and observe change over time — calmly, and without medical claims.'**
  String get v2OnboardingWelcomeBody;

  /// No description provided for @v2OnboardingExpectationsTitle.
  ///
  /// In en, this message translates to:
  /// **'What to expect'**
  String get v2OnboardingExpectationsTitle;

  /// No description provided for @v2OnboardingExpectationsBody.
  ///
  /// In en, this message translates to:
  /// **'A short, honest path — not a diagnosis and not a guarantee.'**
  String get v2OnboardingExpectationsBody;

  /// No description provided for @v2OnboardingExpectation1.
  ///
  /// In en, this message translates to:
  /// **'A brief daily Session when you are ready — about five minutes.'**
  String get v2OnboardingExpectation1;

  /// No description provided for @v2OnboardingExpectation2.
  ///
  /// In en, this message translates to:
  /// **'A self-report Brain Check that is not a medical diagnosis.'**
  String get v2OnboardingExpectation2;

  /// No description provided for @v2OnboardingExpectation3.
  ///
  /// In en, this message translates to:
  /// **'A practical plan you can understand, with progress you can observe over time.'**
  String get v2OnboardingExpectation3;

  /// No description provided for @v2OnboardingExpectationsFootnote.
  ///
  /// In en, this message translates to:
  /// **'Results are not guaranteed. Progress can ebb and flow.'**
  String get v2OnboardingExpectationsFootnote;

  /// No description provided for @v2OnboardingConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you continue'**
  String get v2OnboardingConsentTitle;

  /// No description provided for @v2OnboardingConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you understand how Brain Clean is meant to be used.'**
  String get v2OnboardingConsentBody;

  /// No description provided for @v2OnboardingConsentNonMedical.
  ///
  /// In en, this message translates to:
  /// **'I understand Brain Clean is not a medical diagnosis, clinical assessment, or treatment.'**
  String get v2OnboardingConsentNonMedical;

  /// No description provided for @v2OnboardingConsentTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to continue with the app’s terms of use.'**
  String get v2OnboardingConsentTerms;

  /// No description provided for @v2OnboardingConsentAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Optional: allow anonymous product usage signals (off by default).'**
  String get v2OnboardingConsentAnalytics;

  /// No description provided for @v2OnboardingConsentHint.
  ///
  /// In en, this message translates to:
  /// **'Select the required boxes to continue.'**
  String get v2OnboardingConsentHint;

  /// No description provided for @v2OnboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data on this device'**
  String get v2OnboardingPrivacyTitle;

  /// No description provided for @v2OnboardingPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Core Brain Check answers, Recovery Score, and Recovery Plan are calculated and stored locally on this device. You can pause and resume a Brain Check. Explanations stay reviewable. The score is not generated by AI.'**
  String get v2OnboardingPrivacyBody;

  /// No description provided for @v2OnboardingPrivacyFootnote.
  ///
  /// In en, this message translates to:
  /// **'Some optional product features may use the network later (for example sync, support, or ads when enabled). Continuing works offline.'**
  String get v2OnboardingPrivacyFootnote;

  /// No description provided for @v2OnboardingPrivacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy summary'**
  String get v2OnboardingPrivacyPolicyLink;

  /// No description provided for @v2OnboardingPrivacyCachedSummary.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean keeps your core check and plan data local-first. Optional cloud or network features are separate and not required to finish this onboarding. This is not a medical privacy certification.'**
  String get v2OnboardingPrivacyCachedSummary;

  /// No description provided for @v2OnboardingRitualTitle.
  ///
  /// In en, this message translates to:
  /// **'When would a short Session usually fit?'**
  String get v2OnboardingRitualTitle;

  /// No description provided for @v2OnboardingRitualBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a gentle window as a reminder cue. You can change this later.'**
  String get v2OnboardingRitualBody;

  /// No description provided for @v2OnboardingRitualMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get v2OnboardingRitualMorning;

  /// No description provided for @v2OnboardingRitualAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get v2OnboardingRitualAfternoon;

  /// No description provided for @v2OnboardingRitualEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get v2OnboardingRitualEvening;

  /// No description provided for @v2OnboardingRitualDecideLater.
  ///
  /// In en, this message translates to:
  /// **'Decide later'**
  String get v2OnboardingRitualDecideLater;

  /// No description provided for @v2OnboardingCheckIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Check'**
  String get v2OnboardingCheckIntroTitle;

  /// No description provided for @v2OnboardingCheckIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Brain Check is a short self-report. It is not a medical diagnosis, not brain-damage detection, and not an intelligence test. Your answers stay on this device and help build a practical plan.'**
  String get v2OnboardingCheckIntroBody;

  /// No description provided for @v2OnboardingCheckIntroMeta.
  ///
  /// In en, this message translates to:
  /// **'Lite Check · about a few minutes · resumable'**
  String get v2OnboardingCheckIntroMeta;

  /// No description provided for @v2OnboardingStartBrainCheck.
  ///
  /// In en, this message translates to:
  /// **'Start Brain Check'**
  String get v2OnboardingStartBrainCheck;

  /// No description provided for @v2OnboardingSkipBrainCheck.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get v2OnboardingSkipBrainCheck;

  /// No description provided for @v2OnboardingCorruptTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s start fresh'**
  String get v2OnboardingCorruptTitle;

  /// No description provided for @v2OnboardingCorruptBody.
  ///
  /// In en, this message translates to:
  /// **'Saved onboarding could not be read safely. Your Brain Check answers were not deleted. You can begin onboarding again.'**
  String get v2OnboardingCorruptBody;

  /// No description provided for @v2BrainCheckEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Check'**
  String get v2BrainCheckEntryTitle;

  /// No description provided for @v2BrainCheckEntryLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing Brain Check…'**
  String get v2BrainCheckEntryLoading;

  /// No description provided for @v2BrainCheckEntryBody.
  ///
  /// In en, this message translates to:
  /// **'A calm self-report to help estimate your current recovery state.'**
  String get v2BrainCheckEntryBody;

  /// No description provided for @v2BrainCheckEntryNonMedical.
  ///
  /// In en, this message translates to:
  /// **'Not a medical diagnosis. Not treatment. Not a measure of intelligence.'**
  String get v2BrainCheckEntryNonMedical;

  /// No description provided for @v2BrainCheckEntryDuration.
  ///
  /// In en, this message translates to:
  /// **'Lite Check · short · you can pause anytime'**
  String get v2BrainCheckEntryDuration;

  /// No description provided for @v2BrainCheckEntryStart.
  ///
  /// In en, this message translates to:
  /// **'Start Brain Check'**
  String get v2BrainCheckEntryStart;

  /// No description provided for @v2BrainCheckEntryResume.
  ///
  /// In en, this message translates to:
  /// **'Resume Brain Check'**
  String get v2BrainCheckEntryResume;

  /// No description provided for @v2BrainCheckEntryResumeHint.
  ///
  /// In en, this message translates to:
  /// **'You have an unfinished Brain Check on this device.'**
  String get v2BrainCheckEntryResumeHint;

  /// No description provided for @v2BrainCheckEntryStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get v2BrainCheckEntryStartOver;

  /// No description provided for @v2BrainCheckEntryAlreadyComplete.
  ///
  /// In en, this message translates to:
  /// **'A Brain Check is already complete. Starting again is available from later product steps — answers were not wiped.'**
  String get v2BrainCheckEntryAlreadyComplete;

  /// No description provided for @v2BrainCheckEntryError.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare Brain Check right now.'**
  String get v2BrainCheckEntryError;

  /// No description provided for @v2BrainCheckReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Check is ready'**
  String get v2BrainCheckReadyTitle;

  /// No description provided for @v2BrainCheckReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your Brain Check entry is ready. Continue when you want to open or resume the questionnaire.'**
  String get v2BrainCheckReadyBody;

  /// No description provided for @v2WeeklyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get v2WeeklyReviewTitle;

  /// No description provided for @v2WeeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get v2WeeklySummaryTitle;

  /// No description provided for @v2WeeklyReviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Weekly Review'**
  String get v2WeeklyReviewLoading;

  /// No description provided for @v2WeeklyReviewExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get v2WeeklyReviewExit;

  /// No description provided for @v2WeeklyReviewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get v2WeeklyReviewBack;

  /// No description provided for @v2WeeklyReviewContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get v2WeeklyReviewContinue;

  /// No description provided for @v2WeeklyReviewComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete review'**
  String get v2WeeklyReviewComplete;

  /// No description provided for @v2WeeklyReviewRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get v2WeeklyReviewRetry;

  /// No description provided for @v2WeeklyReviewBackToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get v2WeeklyReviewBackToday;

  /// No description provided for @v2WeeklyReviewSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your review right now. Try again.'**
  String get v2WeeklyReviewSaveFailed;

  /// No description provided for @v2WeeklyReviewUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This review format is not supported on this version.'**
  String get v2WeeklyReviewUnsupported;

  /// No description provided for @v2WeeklyReviewNotReadyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review is not ready yet'**
  String get v2WeeklyReviewNotReadyGeneric;

  /// No description provided for @v2WeeklyReviewNotReadyGenericBody.
  ///
  /// In en, this message translates to:
  /// **'Come back after a completed week with at least one finished session.'**
  String get v2WeeklyReviewNotReadyGenericBody;

  /// No description provided for @v2WeeklyReviewNotReadyZeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough completed activity yet'**
  String get v2WeeklyReviewNotReadyZeroTitle;

  /// No description provided for @v2WeeklyReviewNotReadyZeroBody.
  ///
  /// In en, this message translates to:
  /// **'Finish at least one Today session in a completed week to open Weekly Review.'**
  String get v2WeeklyReviewNotReadyZeroBody;

  /// No description provided for @v2WeeklyReviewNotReadyCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'This week is still in progress'**
  String get v2WeeklyReviewNotReadyCurrentTitle;

  /// No description provided for @v2WeeklyReviewNotReadyCurrentBody.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review opens after the week ends. Keep going with Today when you are ready.'**
  String get v2WeeklyReviewNotReadyCurrentBody;

  /// No description provided for @v2WeeklyReviewNotReadyMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Review sources are not ready'**
  String get v2WeeklyReviewNotReadyMissingTitle;

  /// No description provided for @v2WeeklyReviewNotReadyMissingBody.
  ///
  /// In en, this message translates to:
  /// **'A local plan, profile, or progress record is missing. Continue through Today and return later.'**
  String get v2WeeklyReviewNotReadyMissingBody;

  /// No description provided for @v2WeeklyReviewPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period {start} – {end}'**
  String v2WeeklyReviewPeriodLabel(String start, String end);

  /// No description provided for @v2WeeklyReviewProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String v2WeeklyReviewProgress(String current, String total);

  /// No description provided for @v2WeeklyReviewProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review question {current} of {total}'**
  String v2WeeklyReviewProgressSemantics(String current, String total);

  /// No description provided for @v2WeeklyReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get v2WeeklyReviewRequired;

  /// No description provided for @v2WeeklyReviewMultiSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Choose up to two.'**
  String get v2WeeklyReviewMultiSelectHint;

  /// No description provided for @v2WeeklyReviewValidationHint.
  ///
  /// In en, this message translates to:
  /// **'Please choose a valid response to continue.'**
  String get v2WeeklyReviewValidationHint;

  /// No description provided for @v2WeeklyReviewYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get v2WeeklyReviewYes;

  /// No description provided for @v2WeeklyReviewNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get v2WeeklyReviewNo;

  /// No description provided for @v2WeeklyReviewQManageability.
  ///
  /// In en, this message translates to:
  /// **'How manageable did the plan feel this week?'**
  String get v2WeeklyReviewQManageability;

  /// No description provided for @v2WeeklyReviewQPauseFocus.
  ///
  /// In en, this message translates to:
  /// **'How much did the sessions help you pause or focus?'**
  String get v2WeeklyReviewQPauseFocus;

  /// No description provided for @v2WeeklyReviewQObstacle.
  ///
  /// In en, this message translates to:
  /// **'What got in the way most often?'**
  String get v2WeeklyReviewQObstacle;

  /// No description provided for @v2WeeklyReviewQSupport.
  ///
  /// In en, this message translates to:
  /// **'What supported you? (optional)'**
  String get v2WeeklyReviewQSupport;

  /// No description provided for @v2WeeklyReviewQAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Did you use an accessibility alternative this week? (optional)'**
  String get v2WeeklyReviewQAccessibility;

  /// No description provided for @v2WeeklyReviewOptTooLight.
  ///
  /// In en, this message translates to:
  /// **'Too light'**
  String get v2WeeklyReviewOptTooLight;

  /// No description provided for @v2WeeklyReviewOptAboutRight.
  ///
  /// In en, this message translates to:
  /// **'About right'**
  String get v2WeeklyReviewOptAboutRight;

  /// No description provided for @v2WeeklyReviewOptTooDemanding.
  ///
  /// In en, this message translates to:
  /// **'Too demanding'**
  String get v2WeeklyReviewOptTooDemanding;

  /// No description provided for @v2WeeklyReviewOptTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get v2WeeklyReviewOptTime;

  /// No description provided for @v2WeeklyReviewOptForgetfulness.
  ///
  /// In en, this message translates to:
  /// **'Forgetfulness'**
  String get v2WeeklyReviewOptForgetfulness;

  /// No description provided for @v2WeeklyReviewOptLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Low energy'**
  String get v2WeeklyReviewOptLowEnergy;

  /// No description provided for @v2WeeklyReviewOptInterruptions.
  ///
  /// In en, this message translates to:
  /// **'Interruptions'**
  String get v2WeeklyReviewOptInterruptions;

  /// No description provided for @v2WeeklyReviewOptUnclearStep.
  ///
  /// In en, this message translates to:
  /// **'Unclear step'**
  String get v2WeeklyReviewOptUnclearStep;

  /// No description provided for @v2WeeklyReviewOptAccessEnv.
  ///
  /// In en, this message translates to:
  /// **'Access or environment'**
  String get v2WeeklyReviewOptAccessEnv;

  /// No description provided for @v2WeeklyReviewOptNoMajorObstacle.
  ///
  /// In en, this message translates to:
  /// **'No major obstacle'**
  String get v2WeeklyReviewOptNoMajorObstacle;

  /// No description provided for @v2WeeklyReviewOptShorterPath.
  ///
  /// In en, this message translates to:
  /// **'Shorter path'**
  String get v2WeeklyReviewOptShorterPath;

  /// No description provided for @v2WeeklyReviewOptClearerTiming.
  ///
  /// In en, this message translates to:
  /// **'Clearer timing'**
  String get v2WeeklyReviewOptClearerTiming;

  /// No description provided for @v2WeeklyReviewOptQuieterEnv.
  ///
  /// In en, this message translates to:
  /// **'Quieter environment'**
  String get v2WeeklyReviewOptQuieterEnv;

  /// No description provided for @v2WeeklyReviewOptA11yAlt.
  ///
  /// In en, this message translates to:
  /// **'Accessibility alternative'**
  String get v2WeeklyReviewOptA11yAlt;

  /// No description provided for @v2WeeklyReviewOptStrongerReminder.
  ///
  /// In en, this message translates to:
  /// **'Stronger reminder'**
  String get v2WeeklyReviewOptStrongerReminder;

  /// No description provided for @v2WeeklyReviewOptSamePlan.
  ///
  /// In en, this message translates to:
  /// **'Same plan is working'**
  String get v2WeeklyReviewOptSamePlan;

  /// No description provided for @v2WeeklySummaryOrientation.
  ///
  /// In en, this message translates to:
  /// **'This week’s pattern'**
  String get v2WeeklySummaryOrientation;

  /// No description provided for @v2WeeklySummaryCompletedDays.
  ///
  /// In en, this message translates to:
  /// **'Completed days: {count}'**
  String v2WeeklySummaryCompletedDays(String count);

  /// No description provided for @v2WeeklySummaryPathMix.
  ///
  /// In en, this message translates to:
  /// **'Path mix: {label}'**
  String v2WeeklySummaryPathMix(String label);

  /// No description provided for @v2WeeklySummaryPathMostlyMinimum.
  ///
  /// In en, this message translates to:
  /// **'Mostly minimum'**
  String get v2WeeklySummaryPathMostlyMinimum;

  /// No description provided for @v2WeeklySummaryPathMostlyStandard.
  ///
  /// In en, this message translates to:
  /// **'Mostly standard'**
  String get v2WeeklySummaryPathMostlyStandard;

  /// No description provided for @v2WeeklySummaryPathBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get v2WeeklySummaryPathBalanced;

  /// No description provided for @v2WeeklySummaryPathSingle.
  ///
  /// In en, this message translates to:
  /// **'Single session only'**
  String get v2WeeklySummaryPathSingle;

  /// No description provided for @v2WeeklySummaryPatternHeading.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get v2WeeklySummaryPatternHeading;

  /// No description provided for @v2WeeklySummaryRhythmSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady across several days'**
  String get v2WeeklySummaryRhythmSteady;

  /// No description provided for @v2WeeklySummaryRhythmIntermittent.
  ///
  /// In en, this message translates to:
  /// **'Intermittent across the week'**
  String get v2WeeklySummaryRhythmIntermittent;

  /// No description provided for @v2WeeklySummaryRhythmLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited history'**
  String get v2WeeklySummaryRhythmLimited;

  /// No description provided for @v2WeeklySummaryObstacleHeading.
  ///
  /// In en, this message translates to:
  /// **'What got in the way'**
  String get v2WeeklySummaryObstacleHeading;

  /// No description provided for @v2WeeklySummarySupportHeading.
  ///
  /// In en, this message translates to:
  /// **'What supported you'**
  String get v2WeeklySummarySupportHeading;

  /// No description provided for @v2WeeklySummarySupportNone.
  ///
  /// In en, this message translates to:
  /// **'No support noted'**
  String get v2WeeklySummarySupportNone;

  /// No description provided for @v2WeeklySummaryAttentionHeading.
  ///
  /// In en, this message translates to:
  /// **'What may deserve attention'**
  String get v2WeeklySummaryAttentionHeading;

  /// No description provided for @v2WeeklySummaryAttentionLoad.
  ///
  /// In en, this message translates to:
  /// **'Load may deserve a closer look later'**
  String get v2WeeklySummaryAttentionLoad;

  /// No description provided for @v2WeeklySummaryAttentionSupport.
  ///
  /// In en, this message translates to:
  /// **'A bit more support may deserve attention later'**
  String get v2WeeklySummaryAttentionSupport;

  /// No description provided for @v2WeeklySummaryAttentionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause or focus felt low this week'**
  String get v2WeeklySummaryAttentionPause;

  /// No description provided for @v2WeeklySummaryAttentionObstacle.
  ///
  /// In en, this message translates to:
  /// **'An obstacle stood out this week'**
  String get v2WeeklySummaryAttentionObstacle;

  /// No description provided for @v2WeeklySummaryAttentionMaintain.
  ///
  /// In en, this message translates to:
  /// **'Keep observing with the current plan'**
  String get v2WeeklySummaryAttentionMaintain;

  /// No description provided for @v2WeeklySummaryEvidenceLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited evidence — one completed session only'**
  String get v2WeeklySummaryEvidenceLimited;

  /// No description provided for @v2WeeklySummaryEvidenceDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Early evidence — treat this as a quiet look-back'**
  String get v2WeeklySummaryEvidenceDeveloping;

  /// No description provided for @v2WeeklySummaryEvidenceSufficient.
  ///
  /// In en, this message translates to:
  /// **'Summary only — not a cause claim'**
  String get v2WeeklySummaryEvidenceSufficient;

  /// No description provided for @v2WeeklySummaryPlanUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Your plan has not changed yet'**
  String get v2WeeklySummaryPlanUnchanged;

  /// No description provided for @v2WeeklySummaryCtaToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get v2WeeklySummaryCtaToday;

  /// No description provided for @v2WeeklySummaryCtaProgress.
  ///
  /// In en, this message translates to:
  /// **'Back to Progress'**
  String get v2WeeklySummaryCtaProgress;

  /// No description provided for @v2WeeklyFactsSection.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get v2WeeklyFactsSection;

  /// No description provided for @v2WeeklyFactsTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks completed'**
  String get v2WeeklyFactsTasks;

  /// No description provided for @v2WeeklyFactsTasksCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} required steps'**
  String v2WeeklyFactsTasksCaption(String count);

  /// No description provided for @v2WeeklyFactsStreak.
  ///
  /// In en, this message translates to:
  /// **'Focus Journey'**
  String get v2WeeklyFactsStreak;

  /// No description provided for @v2WeeklyFactsStreakCaption.
  ///
  /// In en, this message translates to:
  /// **'{current} now · {best} best'**
  String v2WeeklyFactsStreakCaption(String current, String best);

  /// No description provided for @v2WeeklyFactsAdherence.
  ///
  /// In en, this message translates to:
  /// **'Plan adherence'**
  String get v2WeeklyFactsAdherence;

  /// No description provided for @v2WeeklyFactsAdherenceCaption.
  ///
  /// In en, this message translates to:
  /// **'{days} of 7 days'**
  String v2WeeklyFactsAdherenceCaption(String days);

  /// No description provided for @v2ProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get v2ProgressTitle;

  /// No description provided for @v2ProgressOrientation.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get v2ProgressOrientation;

  /// No description provided for @v2ProgressRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get v2ProgressRetry;

  /// No description provided for @v2ProgressBasedOnSessions.
  ///
  /// In en, this message translates to:
  /// **'Progress is based on completed sessions'**
  String get v2ProgressBasedOnSessions;

  /// No description provided for @v2ProgressHeadlineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed sessions yet'**
  String get v2ProgressHeadlineEmpty;

  /// No description provided for @v2ProgressHeadlineFirst.
  ///
  /// In en, this message translates to:
  /// **'Your first completed session is recorded'**
  String get v2ProgressHeadlineFirst;

  /// No description provided for @v2ProgressHeadlineFew.
  ///
  /// In en, this message translates to:
  /// **'A few completed days are on record'**
  String get v2ProgressHeadlineFew;

  /// No description provided for @v2ProgressHeadlineRhythm.
  ///
  /// In en, this message translates to:
  /// **'A pattern is beginning to appear'**
  String get v2ProgressHeadlineRhythm;

  /// No description provided for @v2ProgressHeadlineSteady.
  ///
  /// In en, this message translates to:
  /// **'A steadier pattern is visible'**
  String get v2ProgressHeadlineSteady;

  /// No description provided for @v2ProgressHeadlineLimited.
  ///
  /// In en, this message translates to:
  /// **'Evidence is still limited'**
  String get v2ProgressHeadlineLimited;

  /// No description provided for @v2ProgressHeadlineWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly evidence is available to review'**
  String get v2ProgressHeadlineWeekly;

  /// No description provided for @v2ProgressBetterHeading.
  ///
  /// In en, this message translates to:
  /// **'What is recorded'**
  String get v2ProgressBetterHeading;

  /// No description provided for @v2ProgressWhyHeading.
  ///
  /// In en, this message translates to:
  /// **'What the pattern shows'**
  String get v2ProgressWhyHeading;

  /// No description provided for @v2ProgressComparedHeading.
  ///
  /// In en, this message translates to:
  /// **'How it compares over time'**
  String get v2ProgressComparedHeading;

  /// No description provided for @v2ProgressCompletedDays.
  ///
  /// In en, this message translates to:
  /// **'Completed days: {count}'**
  String v2ProgressCompletedDays(String count);

  /// No description provided for @v2ProgressCompletedSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions: {count}'**
  String v2ProgressCompletedSessions(String count);

  /// No description provided for @v2ProgressMinimumPath.
  ///
  /// In en, this message translates to:
  /// **'Minimum path: {count}'**
  String v2ProgressMinimumPath(String count);

  /// No description provided for @v2ProgressStandardPath.
  ///
  /// In en, this message translates to:
  /// **'Standard path: {count}'**
  String v2ProgressStandardPath(String count);

  /// No description provided for @v2ProgressCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Completed-day rate: {percent}%'**
  String v2ProgressCompletionRate(String percent);

  /// No description provided for @v2ProgressCurrentRhythm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Current rhythm: 1 day} other{Current rhythm: {count} days}}'**
  String v2ProgressCurrentRhythm(int count);

  /// No description provided for @v2ProgressLongestRhythm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Longest rhythm: 1 day} other{Longest rhythm: {count} days}}'**
  String v2ProgressLongestRhythm(int count);

  /// No description provided for @v2ProgressFirstCompleted.
  ///
  /// In en, this message translates to:
  /// **'First completed day: {day}'**
  String v2ProgressFirstCompleted(String day);

  /// No description provided for @v2ProgressLastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Last completed day: {day}'**
  String v2ProgressLastCompleted(String day);

  /// No description provided for @v2ProgressRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get v2ProgressRecentActivity;

  /// No description provided for @v2ProgressTimelineMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum path'**
  String get v2ProgressTimelineMinimum;

  /// No description provided for @v2ProgressTimelineStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard path'**
  String get v2ProgressTimelineStandard;

  /// No description provided for @v2ProgressTimelineBothPaths.
  ///
  /// In en, this message translates to:
  /// **'Minimum and standard'**
  String get v2ProgressTimelineBothPaths;

  /// No description provided for @v2ProgressTimelineEntry.
  ///
  /// In en, this message translates to:
  /// **'{day} · {path}'**
  String v2ProgressTimelineEntry(String day, String path);

  /// No description provided for @v2ProgressPathMostlyMinimum.
  ///
  /// In en, this message translates to:
  /// **'Mostly minimum path'**
  String get v2ProgressPathMostlyMinimum;

  /// No description provided for @v2ProgressPathMostlyStandard.
  ///
  /// In en, this message translates to:
  /// **'Mostly standard path'**
  String get v2ProgressPathMostlyStandard;

  /// No description provided for @v2ProgressPathBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced path mix'**
  String get v2ProgressPathBalanced;

  /// No description provided for @v2ProgressPathSingle.
  ///
  /// In en, this message translates to:
  /// **'Single session only'**
  String get v2ProgressPathSingle;

  /// No description provided for @v2ProgressEvidenceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete today’s action first to begin an honest record.'**
  String get v2ProgressEvidenceEmpty;

  /// No description provided for @v2ProgressEvidenceLimited.
  ///
  /// In en, this message translates to:
  /// **'Evidence is still limited — one completed action so far.'**
  String get v2ProgressEvidenceLimited;

  /// No description provided for @v2ProgressEvidenceDeveloping.
  ///
  /// In en, this message translates to:
  /// **'A pattern is beginning to appear. This is observation, not a diagnosis.'**
  String get v2ProgressEvidenceDeveloping;

  /// No description provided for @v2ProgressEvidenceSufficient.
  ///
  /// In en, this message translates to:
  /// **'Enough completed activity for a quiet look-back. No cause claim.'**
  String get v2ProgressEvidenceSufficient;

  /// No description provided for @v2ProgressScoreHeading.
  ///
  /// In en, this message translates to:
  /// **'Recovery Score snapshot'**
  String get v2ProgressScoreHeading;

  /// No description provided for @v2ProgressScoreValue.
  ///
  /// In en, this message translates to:
  /// **'Estimate: {value}'**
  String v2ProgressScoreValue(String value);

  /// No description provided for @v2ProgressScoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Score estimate not available on this device yet'**
  String get v2ProgressScoreUnavailable;

  /// No description provided for @v2ProgressScoreMeasured.
  ///
  /// In en, this message translates to:
  /// **'From Brain Check on {day}'**
  String v2ProgressScoreMeasured(String day);

  /// No description provided for @v2ProgressScoreDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Daily session completion does not instantly change this score. The score comes from Brain Check measurement, not from counting sessions.'**
  String get v2ProgressScoreDisclaimer;

  /// No description provided for @v2ProgressWeeklyReviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get v2ProgressWeeklyReviewHeading;

  /// No description provided for @v2ProgressWrNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough completed activity yet for a Weekly Review.'**
  String get v2ProgressWrNotEnough;

  /// No description provided for @v2ProgressWrCurrentWeek.
  ///
  /// In en, this message translates to:
  /// **'This week is still in progress. Review opens after the week ends.'**
  String get v2ProgressWrCurrentWeek;

  /// No description provided for @v2ProgressWrAvailableInDays.
  ///
  /// In en, this message translates to:
  /// **'Available in {days} days'**
  String v2ProgressWrAvailableInDays(int days);

  /// No description provided for @v2ProgressWeeklyChartHeading.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get v2ProgressWeeklyChartHeading;

  /// No description provided for @v2ProgressWrAvailable.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review available'**
  String get v2ProgressWrAvailable;

  /// No description provided for @v2ProgressWrDraft.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review draft in progress'**
  String get v2ProgressWrDraft;

  /// No description provided for @v2ProgressWrCompleted.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary available'**
  String get v2ProgressWrCompleted;

  /// No description provided for @v2ProgressWrUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This review format is not supported on this version.'**
  String get v2ProgressWrUnsupported;

  /// No description provided for @v2ProgressWrMissingRefs.
  ///
  /// In en, this message translates to:
  /// **'Review sources are not ready yet. Continue through Today and return later.'**
  String get v2ProgressWrMissingRefs;

  /// No description provided for @v2ProgressWrError.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review could not be prepared right now.'**
  String get v2ProgressWrError;

  /// No description provided for @v2ProgressWrCtaStart.
  ///
  /// In en, this message translates to:
  /// **'Start Weekly Review'**
  String get v2ProgressWrCtaStart;

  /// No description provided for @v2ProgressWrCtaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Weekly Review'**
  String get v2ProgressWrCtaContinue;

  /// No description provided for @v2ProgressWrCtaSummary.
  ///
  /// In en, this message translates to:
  /// **'View Weekly Summary'**
  String get v2ProgressWrCtaSummary;

  /// No description provided for @v2ProgressWeeklyPreviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Latest Weekly Summary'**
  String get v2ProgressWeeklyPreviewHeading;

  /// No description provided for @v2ProgressCtaToday.
  ///
  /// In en, this message translates to:
  /// **'Complete today’s action first'**
  String get v2ProgressCtaToday;

  /// No description provided for @v2ProgressCtaContinueToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get v2ProgressCtaContinueToday;

  /// No description provided for @v2ProgressReportsEntry.
  ///
  /// In en, this message translates to:
  /// **'Open Reports'**
  String get v2ProgressReportsEntry;

  /// No description provided for @v2ProgressPillarsHeading.
  ///
  /// In en, this message translates to:
  /// **'Cognitive pillars'**
  String get v2ProgressPillarsHeading;

  /// No description provided for @v2ProgressPillarsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete a quick diagnostic to track focus, memory, screen habits, and sleep over time.'**
  String get v2ProgressPillarsEmpty;

  /// No description provided for @v2ProgressPillarsFirstDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Start first diagnostic'**
  String get v2ProgressPillarsFirstDiagnostic;

  /// No description provided for @v2ProgressLiveVsDayOne.
  ///
  /// In en, this message translates to:
  /// **'Live vs day one'**
  String get v2ProgressLiveVsDayOne;

  /// No description provided for @v2ProgressOverallDelta.
  ///
  /// In en, this message translates to:
  /// **'Average change: {delta}'**
  String v2ProgressOverallDelta(String delta);

  /// No description provided for @v2ProgressBaselineDate.
  ///
  /// In en, this message translates to:
  /// **'First snapshot: {date}'**
  String v2ProgressBaselineDate(String date);

  /// No description provided for @v2ProgressChartDayOne.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get v2ProgressChartDayOne;

  /// No description provided for @v2ProgressChartToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get v2ProgressChartToday;

  /// No description provided for @v2ProgressWeeklyRediagnosis.
  ///
  /// In en, this message translates to:
  /// **'Re-run weekly diagnostic'**
  String get v2ProgressWeeklyRediagnosis;

  /// No description provided for @v2ProgressPatternDetails.
  ///
  /// In en, this message translates to:
  /// **'Pattern details'**
  String get v2ProgressPatternDetails;

  /// No description provided for @v2ReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get v2ReportsTitle;

  /// No description provided for @v2ReportsEvidenceOverview.
  ///
  /// In en, this message translates to:
  /// **'Evidence overview'**
  String get v2ReportsEvidenceOverview;

  /// No description provided for @v2ReportsWeeklyHistory.
  ///
  /// In en, this message translates to:
  /// **'Weekly history'**
  String get v2ReportsWeeklyHistory;

  /// No description provided for @v2ReportsWeeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get v2ReportsWeeklyReport;

  /// No description provided for @v2ReportsMeasurementHistory.
  ///
  /// In en, this message translates to:
  /// **'Measurement history'**
  String get v2ReportsMeasurementHistory;

  /// No description provided for @v2ReportsEvidenceStillDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Your evidence is still developing'**
  String get v2ReportsEvidenceStillDeveloping;

  /// No description provided for @v2ReportsNotEnoughMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Not enough measurements to compare yet'**
  String get v2ReportsNotEnoughMeasurements;

  /// No description provided for @v2ReportsComparedWithEarlier.
  ///
  /// In en, this message translates to:
  /// **'Compared with your earlier check'**
  String get v2ReportsComparedWithEarlier;

  /// No description provided for @v2ReportsSelfReportEstimate.
  ///
  /// In en, this message translates to:
  /// **'This is a self-report estimate'**
  String get v2ReportsSelfReportEstimate;

  /// No description provided for @v2ReportsNoCauseFromHistory.
  ///
  /// In en, this message translates to:
  /// **'No cause can be determined from this history'**
  String get v2ReportsNoCauseFromHistory;

  /// No description provided for @v2ReportsOrientation.
  ///
  /// In en, this message translates to:
  /// **'Reports gather honest local proof from completed sessions, weekly summaries, and valid self-report measurements.'**
  String get v2ReportsOrientation;

  /// No description provided for @v2ReportsOrientationNot.
  ///
  /// In en, this message translates to:
  /// **'Reports are not a diagnosis, not medical advice, and not a comparison with other people.'**
  String get v2ReportsOrientationNot;

  /// No description provided for @v2ReportsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading reports'**
  String get v2ReportsLoading;

  /// No description provided for @v2ReportsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get v2ReportsRetry;

  /// No description provided for @v2ReportsPersistFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load reports right now. Try again.'**
  String get v2ReportsPersistFailed;

  /// No description provided for @v2ReportsUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This report format is not supported on this version.'**
  String get v2ReportsUnsupported;

  /// No description provided for @v2ReportsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a Today session to begin an honest local evidence record. Nothing is invented when history is empty.'**
  String get v2ReportsEmptyBody;

  /// No description provided for @v2ReportsSnapshotMissing.
  ///
  /// In en, this message translates to:
  /// **'A saved progress snapshot is missing. Showing counts rebuilt from completed sessions only.'**
  String get v2ReportsSnapshotMissing;

  /// No description provided for @v2ReportsDepthNoEvidence.
  ///
  /// In en, this message translates to:
  /// **'No evidence yet'**
  String get v2ReportsDepthNoEvidence;

  /// No description provided for @v2ReportsDepthEarly.
  ///
  /// In en, this message translates to:
  /// **'Early evidence'**
  String get v2ReportsDepthEarly;

  /// No description provided for @v2ReportsDepthDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Developing evidence'**
  String get v2ReportsDepthDeveloping;

  /// No description provided for @v2ReportsDepthEstablished.
  ///
  /// In en, this message translates to:
  /// **'Established history'**
  String get v2ReportsDepthEstablished;

  /// No description provided for @v2ReportsDepthNoEvidenceExplain.
  ///
  /// In en, this message translates to:
  /// **'No completed sessions are on record yet.'**
  String get v2ReportsDepthNoEvidenceExplain;

  /// No description provided for @v2ReportsDepthDevelopingExplain.
  ///
  /// In en, this message translates to:
  /// **'Completed days and weekly summaries are building a clearer local record.'**
  String get v2ReportsDepthDevelopingExplain;

  /// No description provided for @v2ReportsDepthEstablishedExplain.
  ///
  /// In en, this message translates to:
  /// **'Multiple weekly summaries and measurements form a longer local history.'**
  String get v2ReportsDepthEstablishedExplain;

  /// No description provided for @v2ReportsSessionSummaryHeading.
  ///
  /// In en, this message translates to:
  /// **'Completed activity'**
  String get v2ReportsSessionSummaryHeading;

  /// No description provided for @v2ReportsCompletedSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions: {count}'**
  String v2ReportsCompletedSessions(String count);

  /// No description provided for @v2ReportsCompletedDays.
  ///
  /// In en, this message translates to:
  /// **'Completed days: {count}'**
  String v2ReportsCompletedDays(String count);

  /// No description provided for @v2ReportsMinimumPath.
  ///
  /// In en, this message translates to:
  /// **'Minimum path: {count}'**
  String v2ReportsMinimumPath(String count);

  /// No description provided for @v2ReportsStandardPath.
  ///
  /// In en, this message translates to:
  /// **'Standard path: {count}'**
  String v2ReportsStandardPath(String count);

  /// No description provided for @v2ReportsCurrentRhythm.
  ///
  /// In en, this message translates to:
  /// **'Current rhythm: {count} day(s)'**
  String v2ReportsCurrentRhythm(String count);

  /// No description provided for @v2ReportsLongestRhythm.
  ///
  /// In en, this message translates to:
  /// **'Longest rhythm: {count} day(s)'**
  String v2ReportsLongestRhythm(String count);

  /// No description provided for @v2ReportsFirstCompleted.
  ///
  /// In en, this message translates to:
  /// **'First completed day: {day}'**
  String v2ReportsFirstCompleted(String day);

  /// No description provided for @v2ReportsLastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Last completed day: {day}'**
  String v2ReportsLastCompleted(String day);

  /// No description provided for @v2ReportsMeasurementStatusHeading.
  ///
  /// In en, this message translates to:
  /// **'Measurement history status'**
  String get v2ReportsMeasurementStatusHeading;

  /// No description provided for @v2ReportsMeasurementNone.
  ///
  /// In en, this message translates to:
  /// **'No valid measurements yet'**
  String get v2ReportsMeasurementNone;

  /// No description provided for @v2ReportsMeasurementNoneBody.
  ///
  /// In en, this message translates to:
  /// **'A completed Brain Check creates a self-report measurement you can review here.'**
  String get v2ReportsMeasurementNoneBody;

  /// No description provided for @v2ReportsMeasurementBaseline.
  ///
  /// In en, this message translates to:
  /// **'One baseline measurement is on record'**
  String get v2ReportsMeasurementBaseline;

  /// No description provided for @v2ReportsMeasurementComparable.
  ///
  /// In en, this message translates to:
  /// **'Comparable measurements are available'**
  String get v2ReportsMeasurementComparable;

  /// No description provided for @v2ReportsMeasurementIncompatible.
  ///
  /// In en, this message translates to:
  /// **'Measurements exist but are not comparable yet'**
  String get v2ReportsMeasurementIncompatible;

  /// No description provided for @v2ReportsMeasurementErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Measurement history could not be prepared right now.'**
  String get v2ReportsMeasurementErrorBody;

  /// No description provided for @v2ReportsLatestScore.
  ///
  /// In en, this message translates to:
  /// **'Latest estimate: {value}'**
  String v2ReportsLatestScore(String value);

  /// No description provided for @v2ReportsNoArtifacts.
  ///
  /// In en, this message translates to:
  /// **'No weekly reports yet'**
  String get v2ReportsNoArtifacts;

  /// No description provided for @v2ReportsWeeklyReportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Week {start} – {end}'**
  String v2ReportsWeeklyReportPeriod(String start, String end);

  /// No description provided for @v2ReportsPremiumArchiveHint.
  ///
  /// In en, this message translates to:
  /// **'{count} older report(s) available with Premium archive'**
  String v2ReportsPremiumArchiveHint(String count);

  /// No description provided for @v2ReportsPremiumGatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Older archive'**
  String get v2ReportsPremiumGatedTitle;

  /// No description provided for @v2ReportsPremiumGatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your latest and previous weekly reports stay free. Older archive depth is part of Premium. Current proof is never hidden.'**
  String get v2ReportsPremiumGatedBody;

  /// No description provided for @v2ReportsArtifactMissing.
  ///
  /// In en, this message translates to:
  /// **'Weekly report not found'**
  String get v2ReportsArtifactMissing;

  /// No description provided for @v2ReportsArtifactMissingBody.
  ///
  /// In en, this message translates to:
  /// **'This weekly report is missing or unavailable. Return to Reports.'**
  String get v2ReportsArtifactMissingBody;

  /// No description provided for @v2ReportsArtifactUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'This weekly report format is not supported on this version.'**
  String get v2ReportsArtifactUnsupportedBody;

  /// No description provided for @v2ReportsArtifactCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Weekly report could not be read'**
  String get v2ReportsArtifactCorrupt;

  /// No description provided for @v2ReportsArtifactCorruptBody.
  ///
  /// In en, this message translates to:
  /// **'This weekly report looks incomplete. Return to Reports.'**
  String get v2ReportsArtifactCorruptBody;

  /// No description provided for @v2ReportsCtaLatestArtifact.
  ///
  /// In en, this message translates to:
  /// **'Open latest weekly report'**
  String get v2ReportsCtaLatestArtifact;

  /// No description provided for @v2ReportsOpenMeasurementHistory.
  ///
  /// In en, this message translates to:
  /// **'Open measurement history'**
  String get v2ReportsOpenMeasurementHistory;

  /// No description provided for @v2ReportsCtaToday.
  ///
  /// In en, this message translates to:
  /// **'Complete today’s action first'**
  String get v2ReportsCtaToday;

  /// No description provided for @v2ReportsBackProgress.
  ///
  /// In en, this message translates to:
  /// **'Back to Progress'**
  String get v2ReportsBackProgress;

  /// No description provided for @v2ReportsBackOverview.
  ///
  /// In en, this message translates to:
  /// **'Back to Reports'**
  String get v2ReportsBackOverview;

  /// No description provided for @v2ReportsComparisonHigher.
  ///
  /// In en, this message translates to:
  /// **'Your latest self-report estimate is higher than your earlier one.'**
  String get v2ReportsComparisonHigher;

  /// No description provided for @v2ReportsComparisonLower.
  ///
  /// In en, this message translates to:
  /// **'Your latest self-report estimate is lower than your earlier one.'**
  String get v2ReportsComparisonLower;

  /// No description provided for @v2ReportsComparisonUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Your latest self-report estimate is unchanged from your earlier one.'**
  String get v2ReportsComparisonUnchanged;

  /// No description provided for @v2ReportsComparisonNotComparable.
  ///
  /// In en, this message translates to:
  /// **'These measurements are not comparable with each other.'**
  String get v2ReportsComparisonNotComparable;

  /// No description provided for @v2ReportsTooEarlyToInterpret.
  ///
  /// In en, this message translates to:
  /// **'It may be too early to interpret this change.'**
  String get v2ReportsTooEarlyToInterpret;

  /// No description provided for @v2ReportsLowConfidenceQualifier.
  ///
  /// In en, this message translates to:
  /// **'At least one measurement has higher uncertainty.'**
  String get v2ReportsLowConfidenceQualifier;

  /// No description provided for @v2ReportsMeasurementListHeading.
  ///
  /// In en, this message translates to:
  /// **'Your measurements'**
  String get v2ReportsMeasurementListHeading;

  /// No description provided for @v2ReportsMeasuredOn.
  ///
  /// In en, this message translates to:
  /// **'Measured on {day}'**
  String v2ReportsMeasuredOn(String day);

  /// No description provided for @v2ReportsScoreValue.
  ///
  /// In en, this message translates to:
  /// **'Estimate: {value}'**
  String v2ReportsScoreValue(String value);

  /// No description provided for @v2ReportsScoreBand.
  ///
  /// In en, this message translates to:
  /// **'Band: {band}'**
  String v2ReportsScoreBand(String band);

  /// No description provided for @v2ReportsScoreConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidence}'**
  String v2ReportsScoreConfidence(String confidence);

  /// No description provided for @v2ReportsMeasurementSemantics.
  ///
  /// In en, this message translates to:
  /// **'Measurement on {day}, estimate {score}, confidence {confidence}'**
  String v2ReportsMeasurementSemantics(
      String day, String score, String confidence);

  /// No description provided for @v2ReportsConfidenceStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get v2ReportsConfidenceStrong;

  /// No description provided for @v2ReportsConfidenceModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get v2ReportsConfidenceModerate;

  /// No description provided for @v2ReportsConfidenceProvisional.
  ///
  /// In en, this message translates to:
  /// **'Provisional'**
  String get v2ReportsConfidenceProvisional;

  /// No description provided for @v2ReportsDomainHistoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Domain history'**
  String get v2ReportsDomainHistoryHeading;

  /// No description provided for @v2ReportsDomainLatestOnly.
  ///
  /// In en, this message translates to:
  /// **'Latest domain snapshot only — not enough comparable domain history yet.'**
  String get v2ReportsDomainLatestOnly;

  /// No description provided for @v2ReportsDomainRow.
  ///
  /// In en, this message translates to:
  /// **'{title}: {value}'**
  String v2ReportsDomainRow(String title, String value);

  /// No description provided for @v2ReportsDomainHistoryRow.
  ///
  /// In en, this message translates to:
  /// **'{title} on {day}: {value}'**
  String v2ReportsDomainHistoryRow(String title, String day, String value);

  /// No description provided for @v2NavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get v2NavHome;

  /// No description provided for @v2NavToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get v2NavToday;

  /// No description provided for @v2NavCheck.
  ///
  /// In en, this message translates to:
  /// **'Brain Check'**
  String get v2NavCheck;

  /// No description provided for @v2NavPlan.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get v2NavPlan;

  /// No description provided for @v2NavExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get v2NavExercises;

  /// No description provided for @v2NavProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get v2NavProgress;

  /// No description provided for @v2NavPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get v2NavPro;

  /// No description provided for @v2NavReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get v2NavReports;

  /// No description provided for @v2NavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get v2NavProfile;

  /// No description provided for @v2ExercisesLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get v2ExercisesLibraryTitle;

  /// No description provided for @v2ExercisesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get v2ExercisesFilterAll;

  /// No description provided for @v2ExercisesFilterFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get v2ExercisesFilterFocus;

  /// No description provided for @v2ExercisesFilterMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get v2ExercisesFilterMemory;

  /// No description provided for @v2ExercisesFilterSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get v2ExercisesFilterSpeed;

  /// No description provided for @v2ExercisesFilterReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get v2ExercisesFilterReading;

  /// No description provided for @v2ExercisesFilterMentalFitness.
  ///
  /// In en, this message translates to:
  /// **'Mental fitness'**
  String get v2ExercisesFilterMentalFitness;

  /// No description provided for @v2ExercisesDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get v2ExercisesDifficultyEasy;

  /// No description provided for @v2ExercisesDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get v2ExercisesDifficultyMedium;

  /// No description provided for @v2ExercisesDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get v2ExercisesDifficultyHard;

  /// No description provided for @v2ExercisesMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String v2ExercisesMinutes(int count);

  /// No description provided for @v2ExercisesSectionFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get v2ExercisesSectionFree;

  /// No description provided for @v2ExercisesSectionPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get v2ExercisesSectionPro;

  /// No description provided for @v2ExercisesProBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get v2ExercisesProBadge;

  /// No description provided for @v2ExercisesEmptyFilter.
  ///
  /// In en, this message translates to:
  /// **'No exercises match this filter yet.'**
  String get v2ExercisesEmptyFilter;

  /// No description provided for @v2ExercisesNBackTitle.
  ///
  /// In en, this message translates to:
  /// **'N-Back'**
  String get v2ExercisesNBackTitle;

  /// No description provided for @v2ExercisesNBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dual N-Back protocol for working memory'**
  String get v2ExercisesNBackSubtitle;

  /// No description provided for @v2ExercisesStroopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stroop test'**
  String get v2ExercisesStroopTitle;

  /// No description provided for @v2ExercisesStroopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inhibit distraction by naming ink color, not the word'**
  String get v2ExercisesStroopSubtitle;

  /// No description provided for @v2ExercisesDigitSpanTitle.
  ///
  /// In en, this message translates to:
  /// **'Digit span'**
  String get v2ExercisesDigitSpanTitle;

  /// No description provided for @v2ExercisesDigitSpanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hold and recall growing number sequences'**
  String get v2ExercisesDigitSpanSubtitle;

  /// No description provided for @v2ExercisesGoNoGoTitle.
  ///
  /// In en, this message translates to:
  /// **'Impulse control (Go / No-Go)'**
  String get v2ExercisesGoNoGoTitle;

  /// No description provided for @v2ExercisesGoNoGoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train response inhibition under time pressure'**
  String get v2ExercisesGoNoGoSubtitle;

  /// No description provided for @v2ExercisesReadingComprehensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Focused reading + comprehension'**
  String get v2ExercisesReadingComprehensionTitle;

  /// No description provided for @v2ExercisesReadingComprehensionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read without distractions, then answer recall questions'**
  String get v2ExercisesReadingComprehensionSubtitle;

  /// No description provided for @v2ExercisesHiitTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus HIIT'**
  String get v2ExercisesHiitTitle;

  /// No description provided for @v2ExercisesHiitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short math bursts to sharpen sustained attention'**
  String get v2ExercisesHiitSubtitle;

  /// No description provided for @v2ExercisesPatternMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual pattern matching'**
  String get v2ExercisesPatternMatchTitle;

  /// No description provided for @v2ExercisesPatternMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Memorize and recreate grid patterns from memory'**
  String get v2ExercisesPatternMatchSubtitle;

  /// No description provided for @v2ExercisesReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Focused reading session (10 min)'**
  String get v2ExercisesReadingTitle;

  /// No description provided for @v2ExercisesReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distraction-free reading to extend attention span'**
  String get v2ExercisesReadingSubtitle;

  /// No description provided for @v2ExercisesDetoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Boredom challenge (no social media)'**
  String get v2ExercisesDetoxTitle;

  /// No description provided for @v2ExercisesDetoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset dopamine and restore mental patience'**
  String get v2ExercisesDetoxSubtitle;

  /// No description provided for @v2ExercisesAccountabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily accountability box'**
  String get v2ExercisesAccountabilityTitle;

  /// No description provided for @v2ExercisesAccountabilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Honestly review screen pulls and distractions'**
  String get v2ExercisesAccountabilitySubtitle;

  /// No description provided for @diagFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick diagnostic'**
  String get diagFlowTitle;

  /// No description provided for @diagIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'5 quick questions'**
  String get diagIntroTitle;

  /// No description provided for @diagIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Answer honestly — there are no right or wrong answers. This snapshot helps personalize your recovery program.'**
  String get diagIntroBody;

  /// No description provided for @diagIntroMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'What we measure'**
  String get diagIntroMetricsTitle;

  /// No description provided for @diagMetricAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention span'**
  String get diagMetricAttention;

  /// No description provided for @diagMetricWorkingMemory.
  ///
  /// In en, this message translates to:
  /// **'Working memory'**
  String get diagMetricWorkingMemory;

  /// No description provided for @diagMetricScreenHabits.
  ///
  /// In en, this message translates to:
  /// **'Screen habits'**
  String get diagMetricScreenHabits;

  /// No description provided for @diagMetricSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get diagMetricSleepQuality;

  /// No description provided for @diagIntroDurationHint.
  ///
  /// In en, this message translates to:
  /// **'About 2 minutes · 5 questions'**
  String get diagIntroDurationHint;

  /// No description provided for @diagIntroStart.
  ///
  /// In en, this message translates to:
  /// **'Start diagnostic'**
  String get diagIntroStart;

  /// No description provided for @diagQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String diagQuestionProgress(int current, int total);

  /// No description provided for @diagQ1Stem.
  ///
  /// In en, this message translates to:
  /// **'I can stay with one task without switching apps.'**
  String get diagQ1Stem;

  /// No description provided for @diagQ2Stem.
  ///
  /// In en, this message translates to:
  /// **'I can hold several items in mind while working.'**
  String get diagQ2Stem;

  /// No description provided for @diagQ3Stem.
  ///
  /// In en, this message translates to:
  /// **'I notice when I start scrolling without a purpose.'**
  String get diagQ3Stem;

  /// No description provided for @diagQ4Stem.
  ///
  /// In en, this message translates to:
  /// **'I can put my phone away during important tasks.'**
  String get diagQ4Stem;

  /// No description provided for @diagQ5Stem.
  ///
  /// In en, this message translates to:
  /// **'I wake up feeling rested most mornings.'**
  String get diagQ5Stem;

  /// No description provided for @diagBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get diagBack;

  /// No description provided for @diagContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get diagContinue;

  /// No description provided for @diagFinish.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get diagFinish;

  /// No description provided for @diagResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your snapshot'**
  String get diagResultTitle;

  /// No description provided for @diagResultOverallLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall score'**
  String get diagResultOverallLabel;

  /// No description provided for @diagResultBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Breakdown by area'**
  String get diagResultBreakdownTitle;

  /// No description provided for @diagResultWeakestHint.
  ///
  /// In en, this message translates to:
  /// **'Priority focus for your program'**
  String get diagResultWeakestHint;

  /// No description provided for @diagResultPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your program was updated to support {area} first.'**
  String diagResultPlanUpdated(String area);

  /// No description provided for @diagResultPlanUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating your personalized program…'**
  String get diagResultPlanUpdating;

  /// No description provided for @diagResultPlanError.
  ///
  /// In en, this message translates to:
  /// **'Could not update your program. You can retry from Plan.'**
  String get diagResultPlanError;

  /// No description provided for @diagResultContinue.
  ///
  /// In en, this message translates to:
  /// **'View my program'**
  String get diagResultContinue;

  /// No description provided for @v2NavRecoverHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get v2NavRecoverHome;

  /// No description provided for @v2NavRouteNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page could not be found'**
  String get v2NavRouteNotFound;

  /// No description provided for @v2PremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get v2PremiumTitle;

  /// No description provided for @v2PremiumOrientation.
  ///
  /// In en, this message translates to:
  /// **'Premium deepens continuity after you have already made progress — it does not unlock recovery.'**
  String get v2PremiumOrientation;

  /// No description provided for @v2PremiumFreeCoreReassurance.
  ///
  /// In en, this message translates to:
  /// **'Your Free core remains available.'**
  String get v2PremiumFreeCoreReassurance;

  /// No description provided for @v2PremiumCurrentProgressRemains.
  ///
  /// In en, this message translates to:
  /// **'Your current progress remains available.'**
  String get v2PremiumCurrentProgressRemains;

  /// No description provided for @v2PremiumFourCapitalsHeading.
  ///
  /// In en, this message translates to:
  /// **'What Premium adds'**
  String get v2PremiumFourCapitalsHeading;

  /// No description provided for @v2PremiumContinuity.
  ///
  /// In en, this message translates to:
  /// **'Continuity'**
  String get v2PremiumContinuity;

  /// No description provided for @v2PremiumContinuityBody.
  ///
  /// In en, this message translates to:
  /// **'Deeper WeeklyArtifact archive and long-horizon evidence history.'**
  String get v2PremiumContinuityBody;

  /// No description provided for @v2PremiumInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get v2PremiumInterpretation;

  /// No description provided for @v2PremiumInterpretationBody.
  ///
  /// In en, this message translates to:
  /// **'Planned deterministic context layers only — never medical AI claims. Not active yet.'**
  String get v2PremiumInterpretationBody;

  /// No description provided for @v2PremiumFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get v2PremiumFit;

  /// No description provided for @v2PremiumFitBody.
  ///
  /// In en, this message translates to:
  /// **'Future approved adaptation depth without silent Plan changes.'**
  String get v2PremiumFitBody;

  /// No description provided for @v2PremiumSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get v2PremiumSupport;

  /// No description provided for @v2PremiumSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Future continuity support under a separate contract — never Premium-only crisis care.'**
  String get v2PremiumSupportBody;

  /// No description provided for @v2PremiumIncludesNowHeading.
  ///
  /// In en, this message translates to:
  /// **'Included with Premium now'**
  String get v2PremiumIncludesNowHeading;

  /// No description provided for @v2PremiumIncludeArchive.
  ///
  /// In en, this message translates to:
  /// **'Older Reports archive beyond the latest and previous proof'**
  String get v2PremiumIncludeArchive;

  /// No description provided for @v2PremiumIncludeThemes.
  ///
  /// In en, this message translates to:
  /// **'Exclusive color themes'**
  String get v2PremiumIncludeThemes;

  /// No description provided for @v2PremiumIncludeTools.
  ///
  /// In en, this message translates to:
  /// **'Selected tools: emotion wheel, silence, crossword, games, and cognitive test'**
  String get v2PremiumIncludeTools;

  /// No description provided for @v2PremiumIncludeChart.
  ///
  /// In en, this message translates to:
  /// **'Seven-day progress chart'**
  String get v2PremiumIncludeChart;

  /// No description provided for @v2PremiumBenefitsBody.
  ///
  /// In en, this message translates to:
  /// **'Latest and previous Weekly proof stay Free. Premium deepens continuity — it does not unlock recovery.'**
  String get v2PremiumBenefitsBody;

  /// No description provided for @v2PremiumPlanMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium monthly'**
  String get v2PremiumPlanMonthlyTitle;

  /// No description provided for @v2PremiumPlanMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'49 SAR / month'**
  String get v2PremiumPlanMonthlyPrice;

  /// No description provided for @v2PremiumPlanMonthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full access, cancel anytime'**
  String get v2PremiumPlanMonthlySubtitle;

  /// No description provided for @v2PremiumPlanAnnualTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual saver'**
  String get v2PremiumPlanAnnualTitle;

  /// No description provided for @v2PremiumPlanAnnualPrice.
  ///
  /// In en, this message translates to:
  /// **'399 SAR / year'**
  String get v2PremiumPlanAnnualPrice;

  /// No description provided for @v2PremiumPlanAnnualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best value — save vs monthly'**
  String get v2PremiumPlanAnnualSubtitle;

  /// No description provided for @v2PremiumPlanAnnualBadge.
  ///
  /// In en, this message translates to:
  /// **'Save 32%'**
  String get v2PremiumPlanAnnualBadge;

  /// No description provided for @v2PremiumFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'Everything in Pro'**
  String get v2PremiumFeaturesHeading;

  /// No description provided for @v2PremiumFeatureNoAds.
  ///
  /// In en, this message translates to:
  /// **'Remove all ads'**
  String get v2PremiumFeatureNoAds;

  /// No description provided for @v2PremiumFeatureBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric app lock'**
  String get v2PremiumFeatureBiometric;

  /// No description provided for @v2PremiumFeatureCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync across devices'**
  String get v2PremiumFeatureCloudSync;

  /// No description provided for @v2PremiumFeatureStealth.
  ///
  /// In en, this message translates to:
  /// **'Stealth mode icon'**
  String get v2PremiumFeatureStealth;

  /// No description provided for @v2PremiumFeatureFullStats.
  ///
  /// In en, this message translates to:
  /// **'Full statistics and detailed charts'**
  String get v2PremiumFeatureFullStats;

  /// No description provided for @v2PremiumFeatureWeeklyArchive.
  ///
  /// In en, this message translates to:
  /// **'Deep weekly report archive'**
  String get v2PremiumFeatureWeeklyArchive;

  /// No description provided for @v2PremiumViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get v2PremiumViewPlans;

  /// No description provided for @v2PremiumRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get v2PremiumRestorePurchases;

  /// No description provided for @v2PremiumPurchaseInProgress.
  ///
  /// In en, this message translates to:
  /// **'Purchase in progress'**
  String get v2PremiumPurchaseInProgress;

  /// No description provided for @v2PremiumPurchaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Purchase completed'**
  String get v2PremiumPurchaseCompleted;

  /// No description provided for @v2PremiumPurchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled'**
  String get v2PremiumPurchaseCancelled;

  /// No description provided for @v2PremiumPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. You can try again or restore purchases.'**
  String get v2PremiumPurchaseFailed;

  /// No description provided for @v2PremiumPurchasePending.
  ///
  /// In en, this message translates to:
  /// **'Purchase pending'**
  String get v2PremiumPurchasePending;

  /// No description provided for @v2PremiumNoPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available right now.'**
  String get v2PremiumNoPlansAvailable;

  /// No description provided for @v2PremiumStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable'**
  String get v2PremiumStoreUnavailable;

  /// No description provided for @v2PremiumRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get v2PremiumRestored;

  /// No description provided for @v2PremiumNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'Nothing to restore'**
  String get v2PremiumNothingToRestore;

  /// No description provided for @v2PremiumRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. You can try again later.'**
  String get v2PremiumRestoreFailed;

  /// No description provided for @v2PremiumRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases'**
  String get v2PremiumRestoring;

  /// No description provided for @v2PremiumSubscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get v2PremiumSubscriptionExpired;

  /// No description provided for @v2PremiumDeeperHistory.
  ///
  /// In en, this message translates to:
  /// **'Deeper history'**
  String get v2PremiumDeeperHistory;

  /// No description provided for @v2PremiumOlderArchive.
  ///
  /// In en, this message translates to:
  /// **'Older archive'**
  String get v2PremiumOlderArchive;

  /// No description provided for @v2PremiumManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Premium'**
  String get v2PremiumManage;

  /// No description provided for @v2PremiumAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get v2PremiumAlreadyActive;

  /// No description provided for @v2PremiumFreeStatus.
  ///
  /// In en, this message translates to:
  /// **'You are on the Free core'**
  String get v2PremiumFreeStatus;

  /// No description provided for @v2PremiumLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Premium'**
  String get v2PremiumLoading;

  /// No description provided for @v2PremiumPurchaseCta.
  ///
  /// In en, this message translates to:
  /// **'Continue with Premium'**
  String get v2PremiumPurchaseCta;

  /// No description provided for @v2PremiumContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get v2PremiumContinue;

  /// No description provided for @v2PremiumPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly billing'**
  String get v2PremiumPeriodMonthly;

  /// No description provided for @v2PremiumPeriodAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual billing'**
  String get v2PremiumPeriodAnnual;

  /// No description provided for @v2PremiumPeriodLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get v2PremiumPeriodLifetime;

  /// No description provided for @v2PremiumTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get v2PremiumTermsLink;

  /// No description provided for @v2PremiumOfflineCached.
  ///
  /// In en, this message translates to:
  /// **'Offline — using saved Premium status'**
  String get v2PremiumOfflineCached;

  /// No description provided for @v2PremiumOfflineUnknown.
  ///
  /// In en, this message translates to:
  /// **'Offline — Premium status unknown. Purchases need a connection.'**
  String get v2PremiumOfflineUnknown;

  /// No description provided for @v2PremiumUnavailableHere.
  ///
  /// In en, this message translates to:
  /// **'Premium is not offered on this screen.'**
  String get v2PremiumUnavailableHere;

  /// No description provided for @v2PremiumOpenFromArchive.
  ///
  /// In en, this message translates to:
  /// **'View Premium for older archive'**
  String get v2PremiumOpenFromArchive;

  /// No description provided for @v2ReportsPremiumOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Premium'**
  String get v2ReportsPremiumOpen;

  /// No description provided for @v2ReportsPremiumRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get v2ReportsPremiumRestore;

  /// No description provided for @v2SafaTitle.
  ///
  /// In en, this message translates to:
  /// **'Safa'**
  String get v2SafaTitle;

  /// No description provided for @v2SafaPurpose.
  ///
  /// In en, this message translates to:
  /// **'Short support to help you continue with one calm next step.'**
  String get v2SafaPurpose;

  /// No description provided for @v2SafaAiLimitation.
  ///
  /// In en, this message translates to:
  /// **'Safa may use an AI service over the network. It is not medical care and not emergency services.'**
  String get v2SafaAiLimitation;

  /// No description provided for @v2SafaPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Before sending: only what you type and explicitly select will be sent. You can continue without Safa or cancel.'**
  String get v2SafaPrivacyNotice;

  /// No description provided for @v2SafaAcknowledgeNotice.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get v2SafaAcknowledgeNotice;

  /// No description provided for @v2SafaContinueWithout.
  ///
  /// In en, this message translates to:
  /// **'Continue without Safa'**
  String get v2SafaContinueWithout;

  /// No description provided for @v2SafaConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Send only your typed message and any context you select. Safa is not medical or emergency support.'**
  String get v2SafaConsentBody;

  /// No description provided for @v2SafaConsentAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow one network reply'**
  String get v2SafaConsentAllow;

  /// No description provided for @v2SafaConsentDecline.
  ///
  /// In en, this message translates to:
  /// **'Use offline support'**
  String get v2SafaConsentDecline;

  /// No description provided for @v2SafaContextOptionalHeading.
  ///
  /// In en, this message translates to:
  /// **'Optional context (nothing is preselected)'**
  String get v2SafaContextOptionalHeading;

  /// No description provided for @v2SafaContextNone.
  ///
  /// In en, this message translates to:
  /// **'No extra context'**
  String get v2SafaContextNone;

  /// No description provided for @v2SafaContextDifficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult moment'**
  String get v2SafaContextDifficult;

  /// No description provided for @v2SafaContextClarify.
  ///
  /// In en, this message translates to:
  /// **'Clarify a step'**
  String get v2SafaContextClarify;

  /// No description provided for @v2SafaContextContinue.
  ///
  /// In en, this message translates to:
  /// **'Help continuing'**
  String get v2SafaContextContinue;

  /// No description provided for @v2SafaIncludeApprovedContext.
  ///
  /// In en, this message translates to:
  /// **'Include a short context I approve for this send only'**
  String get v2SafaIncludeApprovedContext;

  /// No description provided for @v2SafaInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get v2SafaInputLabel;

  /// No description provided for @v2SafaInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write briefly what you need help with'**
  String get v2SafaInputHint;

  /// No description provided for @v2SafaSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get v2SafaSend;

  /// No description provided for @v2SafaSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get v2SafaSending;

  /// No description provided for @v2SafaResponseHeading.
  ///
  /// In en, this message translates to:
  /// **'Safa reply'**
  String get v2SafaResponseHeading;

  /// No description provided for @v2SafaSuggestedReturn.
  ///
  /// In en, this message translates to:
  /// **'Return to where you left'**
  String get v2SafaSuggestedReturn;

  /// No description provided for @v2SafaSuggestedReturnToday.
  ///
  /// In en, this message translates to:
  /// **'Return to Today'**
  String get v2SafaSuggestedReturnToday;

  /// No description provided for @v2SafaFallbackGrounding.
  ///
  /// In en, this message translates to:
  /// **'Pause: take one calm minute before continuing'**
  String get v2SafaFallbackGrounding;

  /// No description provided for @v2SafaFallbackSimplify.
  ///
  /// In en, this message translates to:
  /// **'Simplify: do only the smallest next step'**
  String get v2SafaFallbackSimplify;

  /// No description provided for @v2SafaRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get v2SafaRetry;

  /// No description provided for @v2SafaUseLocalFallback.
  ///
  /// In en, this message translates to:
  /// **'Use offline support'**
  String get v2SafaUseLocalFallback;

  /// No description provided for @v2SafaOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline — here is a short calm step you can take now.'**
  String get v2SafaOffline;

  /// No description provided for @v2SafaTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Offline support is available.'**
  String get v2SafaTimeout;

  /// No description provided for @v2SafaServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Safa is offline right now — try slow breathing or simplify your next step.'**
  String get v2SafaServiceUnavailable;

  /// No description provided for @v2SafaOfflineTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline tip'**
  String get v2SafaOfflineTipTitle;

  /// No description provided for @v2SafaOfflineTipBody.
  ///
  /// In en, this message translates to:
  /// **'Breathe in for 4 counts, hold 2, out for 6. Then return to Today and complete one small focus block.'**
  String get v2SafaOfflineTipBody;

  /// No description provided for @v2SafaInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The reply could not be shown safely. Offline support is available.'**
  String get v2SafaInvalidResponse;

  /// No description provided for @v2SafaInputTooLong.
  ///
  /// In en, this message translates to:
  /// **'Please shorten your message (500 characters max).'**
  String get v2SafaInputTooLong;

  /// No description provided for @v2SafaSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'This support session has reached its limit. Choose a next step or leave.'**
  String get v2SafaSessionComplete;

  /// No description provided for @v2SafaClearSession.
  ///
  /// In en, this message translates to:
  /// **'Clear this session'**
  String get v2SafaClearSession;

  /// No description provided for @v2SafaReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get v2SafaReturn;

  /// No description provided for @v2SafaUrgentHelp.
  ///
  /// In en, this message translates to:
  /// **'I need urgent help'**
  String get v2SafaUrgentHelp;

  /// No description provided for @v2SafaUrgentBody.
  ///
  /// In en, this message translates to:
  /// **'Safa is stopping the conversation here. Safa cannot provide emergency care.'**
  String get v2SafaUrgentBody;

  /// No description provided for @v2SafaUrgentLocalEmergency.
  ///
  /// In en, this message translates to:
  /// **'If you may be in immediate danger, contact your local emergency services. This app does not replace them.'**
  String get v2SafaUrgentLocalEmergency;

  /// No description provided for @v2SafaNotMedical.
  ///
  /// In en, this message translates to:
  /// **'Safa is not medical or emergency support.'**
  String get v2SafaNotMedical;

  /// No description provided for @v2SafaOnlyTypedSent.
  ///
  /// In en, this message translates to:
  /// **'Only what you type and select will be sent.'**
  String get v2SafaOnlyTypedSent;

  /// No description provided for @v2SafaStartLater.
  ///
  /// In en, this message translates to:
  /// **'Start a new Safa session later'**
  String get v2SafaStartLater;

  /// No description provided for @v2SafaLoading.
  ///
  /// In en, this message translates to:
  /// **'Opening Safa'**
  String get v2SafaLoading;

  /// No description provided for @v2SafaStateIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are.'**
  String get v2SafaStateIdle;

  /// No description provided for @v2SafaStateReady.
  ///
  /// In en, this message translates to:
  /// **'You can write a short message.'**
  String get v2SafaStateReady;

  /// No description provided for @v2SafaStateResponseReady.
  ///
  /// In en, this message translates to:
  /// **'A short reply is ready.'**
  String get v2SafaStateResponseReady;

  /// No description provided for @v2SafaStateLocalFallback.
  ///
  /// In en, this message translates to:
  /// **'Offline support is shown below.'**
  String get v2SafaStateLocalFallback;

  /// No description provided for @v2SafaUserCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. You can return or try again later.'**
  String get v2SafaUserCancelled;

  /// No description provided for @v2SafaCleared.
  ///
  /// In en, this message translates to:
  /// **'Session cleared.'**
  String get v2SafaCleared;

  /// No description provided for @v2SafaSessionLimit.
  ///
  /// In en, this message translates to:
  /// **'Support turns: {used} of {max}'**
  String v2SafaSessionLimit(String used, String max);

  /// No description provided for @v2SafaEntryToday.
  ///
  /// In en, this message translates to:
  /// **'Ask Safa for support'**
  String get v2SafaEntryToday;

  /// No description provided for @v2SafaEntryProfile.
  ///
  /// In en, this message translates to:
  /// **'Open Safa'**
  String get v2SafaEntryProfile;

  /// No description provided for @v2ProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get v2ProfileTitle;

  /// No description provided for @v2ProfileDefaultIdentity.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get v2ProfileDefaultIdentity;

  /// No description provided for @v2ProfileOrientation.
  ///
  /// In en, this message translates to:
  /// **'Preferences, privacy, and personal controls — not another progress dashboard.'**
  String get v2ProfileOrientation;

  /// No description provided for @v2ProfileSectionRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery setup'**
  String get v2ProfileSectionRecovery;

  /// No description provided for @v2ProfilePurityHeading.
  ///
  /// In en, this message translates to:
  /// **'Purity journey'**
  String get v2ProfilePurityHeading;

  /// No description provided for @v2ProfilePurityDay.
  ///
  /// In en, this message translates to:
  /// **'Day {days}'**
  String v2ProfilePurityDay(int days);

  /// No description provided for @v2ProfilePuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Days on your recovery path since you started'**
  String get v2ProfilePuritySubtitle;

  /// No description provided for @v2ProfileNotificationsRow.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get v2ProfileNotificationsRow;

  /// No description provided for @v2ProfileNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Session and check-in notifications'**
  String get v2ProfileNotificationsHint;

  /// No description provided for @v2ProfileBrainProfile.
  ///
  /// In en, this message translates to:
  /// **'Brain Profile'**
  String get v2ProfileBrainProfile;

  /// No description provided for @v2ProfileBrainProfileLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking your assessment…'**
  String get v2ProfileBrainProfileLoading;

  /// No description provided for @v2ProfileBrainProfileReady.
  ///
  /// In en, this message translates to:
  /// **'View your latest assessment'**
  String get v2ProfileBrainProfileReady;

  /// No description provided for @v2ProfileBrainProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'Complete Brain Check to build this'**
  String get v2ProfileBrainProfileMissing;

  /// No description provided for @v2ProfileBaselineTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Baseline Brain Check'**
  String get v2ProfileBaselineTestTitle;

  /// No description provided for @v2ProfileBaselineTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time assessment — you can redo anytime'**
  String get v2ProfileBaselineTestSubtitle;

  /// No description provided for @v2ProfileWeeklyTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Brain Check'**
  String get v2ProfileWeeklyTestTitle;

  /// No description provided for @v2ProfileWeeklyTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlocks every 7 days'**
  String get v2ProfileWeeklyTestSubtitle;

  /// No description provided for @v2ProfileWeeklyTestLocked.
  ///
  /// In en, this message translates to:
  /// **'Available in {days} days'**
  String v2ProfileWeeklyTestLocked(int days);

  /// No description provided for @v2ProfileWeeklyTestReady.
  ///
  /// In en, this message translates to:
  /// **'Ready — start this week\'s check'**
  String get v2ProfileWeeklyTestReady;

  /// No description provided for @v2ProfileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get v2ProfileSectionPreferences;

  /// No description provided for @v2ProfilePreferencesRow.
  ///
  /// In en, this message translates to:
  /// **'Preferences & settings'**
  String get v2ProfilePreferencesRow;

  /// No description provided for @v2ProfilePreferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Appearance, notifications, biometric lock, and privacy & data'**
  String get v2ProfilePreferencesHint;

  /// No description provided for @v2ProfileSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get v2ProfileSectionPrivacy;

  /// No description provided for @v2ProfilePrivacyRow.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data controls'**
  String get v2ProfilePrivacyRow;

  /// No description provided for @v2ProfilePrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'Reset local data (confirmation required)'**
  String get v2ProfilePrivacyHint;

  /// No description provided for @v2ProfileSectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get v2ProfileSectionSubscription;

  /// No description provided for @v2ProfileSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Premium status, plans, and restore'**
  String get v2ProfileSubscriptionHint;

  /// No description provided for @v2ProfileSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get v2ProfileSectionHelp;

  /// No description provided for @v2ProfileHelpHint.
  ///
  /// In en, this message translates to:
  /// **'Short support for a calm next step'**
  String get v2ProfileHelpHint;

  /// No description provided for @v2ProfileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get v2ProfileSectionAbout;

  /// No description provided for @v2ProfileEditNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get v2ProfileEditNameTitle;

  /// No description provided for @v2ProfileEditNameHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — shown only on this device'**
  String get v2ProfileEditNameHint;

  /// No description provided for @v2ProfileNameSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your name. Please try again.'**
  String get v2ProfileNameSaveFailed;

  /// No description provided for @v2ProfileLegalHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the privacy policy in your browser'**
  String get v2ProfileLegalHint;

  /// No description provided for @v2ProfileContactHint.
  ///
  /// In en, this message translates to:
  /// **'Opens your email app'**
  String get v2ProfileContactHint;

  /// No description provided for @settingsOrientation.
  ///
  /// In en, this message translates to:
  /// **'Appearance, language, notifications, and your account on this device.'**
  String get settingsOrientation;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will return to the start of the app. Your recovery data stays on this device until you delete it.'**
  String get settingsLogoutConfirmBody;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All local data on this device will be permanently deleted. This cannot be undone.'**
  String get settingsDeleteAccountConfirmBody;

  /// No description provided for @colorThemeMorningDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get colorThemeMorningDark;

  /// No description provided for @colorThemeMorningLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get colorThemeMorningLight;

  /// No description provided for @colorThemeAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get colorThemeAmoled;

  /// No description provided for @colorThemeAmoledName.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get colorThemeAmoledName;

  /// No description provided for @colorThemePureWhiteName.
  ///
  /// In en, this message translates to:
  /// **'Pure White'**
  String get colorThemePureWhiteName;

  /// No description provided for @colorThemeWarmBeigeName.
  ///
  /// In en, this message translates to:
  /// **'Warm Beige'**
  String get colorThemeWarmBeigeName;

  /// No description provided for @settingsThemeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Light dark canvas'**
  String get settingsThemeDarkSubtitle;

  /// No description provided for @settingsThemeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Light bright canvas'**
  String get settingsThemeLightSubtitle;

  /// No description provided for @settingsThemeAmoledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pure black for OLED screens'**
  String get settingsThemeAmoledSubtitle;

  /// No description provided for @settingsThemePureWhiteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Crisp white with green accents'**
  String get settingsThemePureWhiteSubtitle;

  /// No description provided for @settingsThemeWarmBeigeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warm off-white with brown text'**
  String get settingsThemeWarmBeigeSubtitle;

  /// No description provided for @dailyProgramMindfulness.
  ///
  /// In en, this message translates to:
  /// **'Reading — 15 min (book or useful article)'**
  String get dailyProgramMindfulness;

  /// No description provided for @dailyProgramReflection.
  ///
  /// In en, this message translates to:
  /// **'Evening review — what did I finish? What will I improve tomorrow?'**
  String get dailyProgramReflection;

  /// No description provided for @dailyProgramReading.
  ///
  /// In en, this message translates to:
  /// **'Reading — 15 min (book or useful article)'**
  String get dailyProgramReading;

  /// No description provided for @dailyProgramPomodoro.
  ///
  /// In en, this message translates to:
  /// **'Focus Pomodoro — 25 min, one task only'**
  String get dailyProgramPomodoro;

  /// No description provided for @dailyProgramScreenFree.
  ///
  /// In en, this message translates to:
  /// **'Screen-free time'**
  String get dailyProgramScreenFree;

  /// No description provided for @dailyProgramEveningReview.
  ///
  /// In en, this message translates to:
  /// **'Evening review — what did I finish? What will I improve tomorrow?'**
  String get dailyProgramEveningReview;

  /// No description provided for @dailyProgramCognitive.
  ///
  /// In en, this message translates to:
  /// **'Cognitive exercise'**
  String get dailyProgramCognitive;

  /// No description provided for @dailyProgramCognitiveNBack.
  ///
  /// In en, this message translates to:
  /// **'Cognitive exercise — N-Back (5 min)'**
  String get dailyProgramCognitiveNBack;

  /// No description provided for @dailyProgramCognitiveStroop.
  ///
  /// In en, this message translates to:
  /// **'Cognitive exercise — Stroop (5 min)'**
  String get dailyProgramCognitiveStroop;

  /// No description provided for @dailyProgramIqChallenge.
  ///
  /// In en, this message translates to:
  /// **'Pattern / logic challenge'**
  String get dailyProgramIqChallenge;

  /// No description provided for @dailyProgramTestsBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your tests to unlock a personalized program'**
  String get dailyProgramTestsBannerTitle;

  /// No description provided for @dailyProgramTestsBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Start tests'**
  String get dailyProgramTestsBannerCta;

  /// No description provided for @dailyProgramMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dailyProgramMinutesOnly(int minutes);

  /// No description provided for @dailyProgramHeavyPomodoro.
  ///
  /// In en, this message translates to:
  /// **'Extra focus Pomodoro'**
  String get dailyProgramHeavyPomodoro;

  /// No description provided for @dailyProgramStroop.
  ///
  /// In en, this message translates to:
  /// **'Stroop daily drill'**
  String get dailyProgramStroop;

  /// No description provided for @dailyProgramNBack.
  ///
  /// In en, this message translates to:
  /// **'N-Back training'**
  String get dailyProgramNBack;

  /// No description provided for @dailyProgramDigitSpan.
  ///
  /// In en, this message translates to:
  /// **'Digit Span practice'**
  String get dailyProgramDigitSpan;

  /// No description provided for @dailyProgramNoMultitask.
  ///
  /// In en, this message translates to:
  /// **'No-multitasking rule'**
  String get dailyProgramNoMultitask;

  /// No description provided for @dailyProgramSingleScreenRule.
  ///
  /// In en, this message translates to:
  /// **'Single-screen-only rule'**
  String get dailyProgramSingleScreenRule;

  /// No description provided for @dailyProgramSearchWaitRule.
  ///
  /// In en, this message translates to:
  /// **'Log every search urge, then wait one hour'**
  String get dailyProgramSearchWaitRule;

  /// No description provided for @dailyProgramDetoxBlock.
  ///
  /// In en, this message translates to:
  /// **'Extended screen-free block'**
  String get dailyProgramDetoxBlock;

  /// No description provided for @dailyProgramAppUsageReview.
  ///
  /// In en, this message translates to:
  /// **'App usage review'**
  String get dailyProgramAppUsageReview;

  /// No description provided for @dailyProgramFullRecoveryBlock.
  ///
  /// In en, this message translates to:
  /// **'Full recovery focus block'**
  String get dailyProgramFullRecoveryBlock;

  /// No description provided for @dailyProgramHourlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Structured hourly plan'**
  String get dailyProgramHourlyPlan;

  /// No description provided for @dailyProgramPersonalizedLocked.
  ///
  /// In en, this message translates to:
  /// **'Personalized daily program'**
  String get dailyProgramPersonalizedLocked;

  /// No description provided for @dailyProgramHourly07.
  ///
  /// In en, this message translates to:
  /// **'07:00 — Wake, hydrate, light stretch'**
  String get dailyProgramHourly07;

  /// No description provided for @dailyProgramHourly08.
  ///
  /// In en, this message translates to:
  /// **'08:00 — Focused reading'**
  String get dailyProgramHourly08;

  /// No description provided for @dailyProgramHourly09.
  ///
  /// In en, this message translates to:
  /// **'09:00 — Deep Pomodoro block'**
  String get dailyProgramHourly09;

  /// No description provided for @dailyProgramHourly10.
  ///
  /// In en, this message translates to:
  /// **'10:00 — Movement / walk'**
  String get dailyProgramHourly10;

  /// No description provided for @dailyProgramHourly11.
  ///
  /// In en, this message translates to:
  /// **'11:00 — Deep Pomodoro block'**
  String get dailyProgramHourly11;

  /// No description provided for @dailyProgramHourly12.
  ///
  /// In en, this message translates to:
  /// **'12:00 — Meal + short rest (no feeds)'**
  String get dailyProgramHourly12;

  /// No description provided for @dailyProgramHourly13.
  ///
  /// In en, this message translates to:
  /// **'13:00 — Deep Pomodoro block'**
  String get dailyProgramHourly13;

  /// No description provided for @dailyProgramHourly14.
  ///
  /// In en, this message translates to:
  /// **'14:00 — Screen-free recovery block'**
  String get dailyProgramHourly14;

  /// No description provided for @dailyProgramHourly15.
  ///
  /// In en, this message translates to:
  /// **'15:00 — Cognitive drills (N-Back + Digit Span)'**
  String get dailyProgramHourly15;

  /// No description provided for @dailyProgramHourly16.
  ///
  /// In en, this message translates to:
  /// **'16:00 — Deep Pomodoro block'**
  String get dailyProgramHourly16;

  /// No description provided for @dailyProgramHourly17.
  ///
  /// In en, this message translates to:
  /// **'17:00 — Outdoor / sunlight break'**
  String get dailyProgramHourly17;

  /// No description provided for @dailyProgramHourly18.
  ///
  /// In en, this message translates to:
  /// **'18:00 — Light single-task focus'**
  String get dailyProgramHourly18;

  /// No description provided for @dailyProgramHourly19.
  ///
  /// In en, this message translates to:
  /// **'19:00 — Digital sunset start'**
  String get dailyProgramHourly19;

  /// No description provided for @dailyProgramHourly20.
  ///
  /// In en, this message translates to:
  /// **'20:00 — Calm reading'**
  String get dailyProgramHourly20;

  /// No description provided for @dailyProgramHourly21.
  ///
  /// In en, this message translates to:
  /// **'21:00 — Evening written review'**
  String get dailyProgramHourly21;

  /// No description provided for @dailyProgramHourly22.
  ///
  /// In en, this message translates to:
  /// **'22:00 — Wind-down, prepare sleep'**
  String get dailyProgramHourly22;

  /// No description provided for @dailyProgramActivityLine.
  ///
  /// In en, this message translates to:
  /// **'{title} — {minutes} min'**
  String dailyProgramActivityLine(String title, int minutes);

  /// No description provided for @settingsActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete that action. Please try again.'**
  String get settingsActionFailed;

  /// No description provided for @testsCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get testsCatalogTitle;

  /// No description provided for @testsCatalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick checks for reasoning, screen habits, focus, and memory.'**
  String get testsCatalogSubtitle;

  /// No description provided for @homeQuickTestsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick tests'**
  String get homeQuickTestsHeading;

  /// No description provided for @homeQuickTestIq.
  ///
  /// In en, this message translates to:
  /// **'IQ'**
  String get homeQuickTestIq;

  /// No description provided for @homeQuickTestDigitalBrainRot.
  ///
  /// In en, this message translates to:
  /// **'Brain rot'**
  String get homeQuickTestDigitalBrainRot;

  /// No description provided for @homeQuickTestFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get homeQuickTestFocus;

  /// No description provided for @homeQuickTestMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get homeQuickTestMemory;

  /// No description provided for @homeQuickTestAll.
  ///
  /// In en, this message translates to:
  /// **'All tests'**
  String get homeQuickTestAll;

  /// No description provided for @v2ProfileTestsCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests catalog'**
  String get v2ProfileTestsCatalogTitle;

  /// No description provided for @v2ProfileTestsCatalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'IQ, digital brain rot, focus, and memory'**
  String get v2ProfileTestsCatalogSubtitle;

  /// No description provided for @quickTestProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quickTestProgress(int current, int total);

  /// No description provided for @iqTestTitle.
  ///
  /// In en, this message translates to:
  /// **'IQ check'**
  String get iqTestTitle;

  /// No description provided for @iqTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'5 pattern and matrix reasoning questions'**
  String get iqTestSubtitle;

  /// No description provided for @iqTestContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get iqTestContinue;

  /// No description provided for @iqTestFinish.
  ///
  /// In en, this message translates to:
  /// **'See score'**
  String get iqTestFinish;

  /// No description provided for @iqTestDone.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get iqTestDone;

  /// No description provided for @iqTestResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reasoning score'**
  String get iqTestResultTitle;

  /// No description provided for @iqTestResultDetail.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String iqTestResultDetail(int correct, int total);

  /// No description provided for @iqTestDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A short practice snapshot — not a clinical IQ test.'**
  String get iqTestDisclaimer;

  /// No description provided for @iqQ1Stem.
  ///
  /// In en, this message translates to:
  /// **'Which number continues the pattern: 2, 4, 8, 16, ?'**
  String get iqQ1Stem;

  /// No description provided for @iqQ1OptA.
  ///
  /// In en, this message translates to:
  /// **'18'**
  String get iqQ1OptA;

  /// No description provided for @iqQ1OptB.
  ///
  /// In en, this message translates to:
  /// **'24'**
  String get iqQ1OptB;

  /// No description provided for @iqQ1OptC.
  ///
  /// In en, this message translates to:
  /// **'32'**
  String get iqQ1OptC;

  /// No description provided for @iqQ1OptD.
  ///
  /// In en, this message translates to:
  /// **'30'**
  String get iqQ1OptD;

  /// No description provided for @iqQ2Stem.
  ///
  /// In en, this message translates to:
  /// **'Find the odd one out: Circle, Square, Triangle, Apple'**
  String get iqQ2Stem;

  /// No description provided for @iqQ2OptA.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get iqQ2OptA;

  /// No description provided for @iqQ2OptB.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get iqQ2OptB;

  /// No description provided for @iqQ2OptC.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get iqQ2OptC;

  /// No description provided for @iqQ2OptD.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get iqQ2OptD;

  /// No description provided for @iqQ3Stem.
  ///
  /// In en, this message translates to:
  /// **'If every shape gains one side each step (triangle → square → pentagon), what is next?'**
  String get iqQ3Stem;

  /// No description provided for @iqQ3OptA.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get iqQ3OptA;

  /// No description provided for @iqQ3OptB.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get iqQ3OptB;

  /// No description provided for @iqQ3OptC.
  ///
  /// In en, this message translates to:
  /// **'Pentagon'**
  String get iqQ3OptC;

  /// No description provided for @iqQ3OptD.
  ///
  /// In en, this message translates to:
  /// **'Hexagon'**
  String get iqQ3OptD;

  /// No description provided for @iqQ4Stem.
  ///
  /// In en, this message translates to:
  /// **'Complete the analogy: Book is to Reading as Fork is to ?'**
  String get iqQ4Stem;

  /// No description provided for @iqQ4OptA.
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get iqQ4OptA;

  /// No description provided for @iqQ4OptB.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get iqQ4OptB;

  /// No description provided for @iqQ4OptC.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get iqQ4OptC;

  /// No description provided for @iqQ4OptD.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get iqQ4OptD;

  /// No description provided for @iqQ5Stem.
  ///
  /// In en, this message translates to:
  /// **'In a 3×3 grid, the missing cell that keeps rows summing to 15 is?'**
  String get iqQ5Stem;

  /// No description provided for @iqQ5OptA.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get iqQ5OptA;

  /// No description provided for @iqQ5OptB.
  ///
  /// In en, this message translates to:
  /// **'4'**
  String get iqQ5OptB;

  /// No description provided for @iqQ5OptC.
  ///
  /// In en, this message translates to:
  /// **'6'**
  String get iqQ5OptC;

  /// No description provided for @iqQ5OptD.
  ///
  /// In en, this message translates to:
  /// **'9'**
  String get iqQ5OptD;

  /// No description provided for @digitalBrainRotTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital brain rot'**
  String get digitalBrainRotTestTitle;

  /// No description provided for @digitalBrainRotTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'8 questions about screens, scrolling, and attention'**
  String get digitalBrainRotTestSubtitle;

  /// No description provided for @digitalBrainRotContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get digitalBrainRotContinue;

  /// No description provided for @digitalBrainRotFinish.
  ///
  /// In en, this message translates to:
  /// **'See clarity score'**
  String get digitalBrainRotFinish;

  /// No description provided for @digitalBrainRotDone.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get digitalBrainRotDone;

  /// No description provided for @digitalBrainRotResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital clarity'**
  String get digitalBrainRotResultTitle;

  /// No description provided for @digitalBrainRotResultClarityLabel.
  ///
  /// In en, this message translates to:
  /// **'Clarity score (higher is healthier)'**
  String get digitalBrainRotResultClarityLabel;

  /// No description provided for @digitalBrainRotResultHealthy.
  ///
  /// In en, this message translates to:
  /// **'Your screen habits look relatively steady.'**
  String get digitalBrainRotResultHealthy;

  /// No description provided for @digitalBrainRotResultModerate.
  ///
  /// In en, this message translates to:
  /// **'Some friction is showing — short focus blocks can help.'**
  String get digitalBrainRotResultModerate;

  /// No description provided for @digitalBrainRotResultHigh.
  ///
  /// In en, this message translates to:
  /// **'Screen pull looks strong right now — protect attention windows.'**
  String get digitalBrainRotResultHigh;

  /// No description provided for @digitalBrainRotDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Self-report only — not a medical diagnosis.'**
  String get digitalBrainRotDisclaimer;

  /// No description provided for @digitalBrainRotQ1Stem.
  ///
  /// In en, this message translates to:
  /// **'I open social apps without a clear goal.'**
  String get digitalBrainRotQ1Stem;

  /// No description provided for @digitalBrainRotQ2Stem.
  ///
  /// In en, this message translates to:
  /// **'I struggle to stay with one task for 10 minutes.'**
  String get digitalBrainRotQ2Stem;

  /// No description provided for @digitalBrainRotQ3Stem.
  ///
  /// In en, this message translates to:
  /// **'I scroll past bedtime more nights than not.'**
  String get digitalBrainRotQ3Stem;

  /// No description provided for @digitalBrainRotQ4Stem.
  ///
  /// In en, this message translates to:
  /// **'Short videos make longer reading feel harder.'**
  String get digitalBrainRotQ4Stem;

  /// No description provided for @digitalBrainRotQ5Stem.
  ///
  /// In en, this message translates to:
  /// **'I check my phone within minutes of waking up.'**
  String get digitalBrainRotQ5Stem;

  /// No description provided for @digitalBrainRotQ6Stem.
  ///
  /// In en, this message translates to:
  /// **'Notifications pull me away mid-conversation.'**
  String get digitalBrainRotQ6Stem;

  /// No description provided for @digitalBrainRotQ7Stem.
  ///
  /// In en, this message translates to:
  /// **'I feel restless when I leave my phone in another room.'**
  String get digitalBrainRotQ7Stem;

  /// No description provided for @digitalBrainRotQ8Stem.
  ///
  /// In en, this message translates to:
  /// **'I can put my phone away during important work.'**
  String get digitalBrainRotQ8Stem;
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
