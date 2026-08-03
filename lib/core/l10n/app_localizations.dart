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
  /// **'Start your first focus session now 🚀'**
  String get homeStreakMotivation;

  /// No description provided for @dailyQuoteSource.
  ///
  /// In en, this message translates to:
  /// **'Neuroscience'**
  String get dailyQuoteSource;

  /// No description provided for @streakFreezeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use streak freeze? Available once per week'**
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
  /// **'Focus days this week'**
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
  /// **'Distractions logged: {count}'**
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
  /// **'Skipping a step never counts as a penalty.'**
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
  /// **'Finishing this step later will count as your day done. Skipping stays allowed with no penalty.'**
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
  /// **'Your Recovery Plan is saved. The daily session player arrives in a later step. You can leave and return without losing progress.'**
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
  /// **'Stay here for now'**
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
