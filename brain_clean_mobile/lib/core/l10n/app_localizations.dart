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
  /// **'Clarity Score'**
  String get dashboardTitle;

  /// No description provided for @dashboardEmptyDiagnosticPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete a Focus Check to see your clarity score.'**
  String get dashboardEmptyDiagnosticPrompt;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey starts here'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'As you follow your Daily Program, progress will show here'**
  String get dashboardEmptySubtitle;

  /// No description provided for @dashboardEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Start check-in'**
  String get dashboardEmptyCta;

  /// No description provided for @dashboardRetakeDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Retake Focus Check'**
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
  /// **'Clarity Check'**
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
  /// **'Accountability note'**
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
  /// **'Saving…'**
  String get detoxSyncing;

  /// No description provided for @detoxSyncError.
  ///
  /// In en, this message translates to:
  /// **'Could not finish saving. Your check-in is kept on this device.'**
  String get detoxSyncError;

  /// No description provided for @diagnosticBrainRotTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Check'**
  String get diagnosticBrainRotTitle;

  /// No description provided for @diagnosticBhiTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Habits Check'**
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
  /// **'Clarity Check'**
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
  /// **'What your answers suggest'**
  String get diagnosticBrainRotInterpretationTitle;

  /// No description provided for @diagnosticContinueToBhi.
  ///
  /// In en, this message translates to:
  /// **'Continue to Digital Habits Check'**
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
  /// **'Calculating your clarity score…'**
  String get diagnosticBrainRotScoring;

  /// No description provided for @diagnosticSyncError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your Focus Check. Please try again.'**
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
  /// **'Clarity: {score}/10'**
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

  /// No description provided for @splashInitError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t finish loading. Please reopen the app.'**
  String get splashInitError;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Home'**
  String get homeTitle;

  /// No description provided for @homeEmptyDiagnosticPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete a Focus Check to unlock your live clarity tracker.'**
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
  /// **'Clarity check-in'**
  String get homeOpenDiagnostic;

  /// No description provided for @homeOpenDiagnosticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short questionnaire + focus sliders'**
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
  /// **'Full progress dashboard'**
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

  /// No description provided for @cognitiveHubEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No tests taken yet — try one now!'**
  String get cognitiveHubEmptyHint;

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
  /// **'This focus check is ready when you are. Try a short run to see how it feels.'**
  String get cognitivePlaceholderBody;

  /// No description provided for @cognitivePlaceholderComplete.
  ///
  /// In en, this message translates to:
  /// **'Save this practice result'**
  String get cognitivePlaceholderComplete;

  /// No description provided for @cognitivePlaceholderRecorded.
  ///
  /// In en, this message translates to:
  /// **'Practice score saved: {score}%'**
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

  /// No description provided for @recoverySleepCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get recoverySleepCheckTitle;

  /// No description provided for @recoverySleepCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enough, regular sleep today (20% of today’s score)'**
  String get recoverySleepCheckSubtitle;

  /// No description provided for @recoveryWaterCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Water intake'**
  String get recoveryWaterCheckTitle;

  /// No description provided for @recoveryWaterCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enough hydration today (20% of today’s score)'**
  String get recoveryWaterCheckSubtitle;

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
  /// **'Local data needed a fresh start. Your progress begins again from today.'**
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
  /// **'Heavy screen day'**
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
  /// **'Build digital calm one day at a time'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Program'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Each day: prepare, focus, reflect, complete, and rest — guided gently'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Start your journey now'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'A short check-in first — then your Daily Program guides each day'**
  String get onboardingPage3Body;

  /// No description provided for @onboardingStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingStartQuiz;

  /// No description provided for @proPaywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Pro'**
  String get proPaywallTitle;

  /// No description provided for @proPaywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock calm Pro features'**
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
  /// **'Deeper mood and habit insights'**
  String get proFeatureEmotionWheel;

  /// No description provided for @proFeatureFocusChallenges.
  ///
  /// In en, this message translates to:
  /// **'Longer silence & focus sessions'**
  String get proFeatureFocusChallenges;

  /// No description provided for @proFeatureAdvancedReports.
  ///
  /// In en, this message translates to:
  /// **'Advanced 30 / 90-day clarity insights'**
  String get proFeatureAdvancedReports;

  /// No description provided for @proFeatureExportData.
  ///
  /// In en, this message translates to:
  /// **'Export your local data'**
  String get proFeatureExportData;

  /// No description provided for @proFeatureCustomReminders.
  ///
  /// In en, this message translates to:
  /// **'Custom reminders'**
  String get proFeatureCustomReminders;

  /// No description provided for @proFeatureExtraQuotes.
  ///
  /// In en, this message translates to:
  /// **'Larger daily quote library'**
  String get proFeatureExtraQuotes;

  /// No description provided for @proFeatureCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Extra Pro insights'**
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

  /// No description provided for @proPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong completing your purchase. Please try again.'**
  String get proPurchaseError;

  /// No description provided for @proPlansUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Plans are unavailable right now. Try again later or restore if you already subscribed.'**
  String get proPlansUnavailable;

  /// No description provided for @paywallRetryLoad.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get paywallRetryLoad;

  /// No description provided for @paywallLifetimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay once, keep forever'**
  String get paywallLifetimeLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
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

  /// No description provided for @settingsProCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Pro'**
  String get settingsProCardTitle;

  /// No description provided for @settingsProStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get settingsProStatusFree;

  /// No description provided for @settingsProStatusPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get settingsProStatusPro;

  /// No description provided for @settingsProBenefitHint.
  ///
  /// In en, this message translates to:
  /// **'Pro unlocks extra features while keeping the core Daily Program free.'**
  String get settingsProBenefitHint;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get settingsRestorePurchases;

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

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder at 9:00 AM'**
  String get settingsDailyReminderSub;

  /// No description provided for @notifDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for your daily exercise 🧠'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In en, this message translates to:
  /// **'Open Brain Clean and start your day with focus'**
  String get notifDailyBody;

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
  /// **'This clears all local progress, journals, daily program, and settings on this device. You will start over. Encryption keys are kept. Continue?'**
  String get settingsResetDataConfirmBody;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export data — coming soon'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataPro.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get settingsExportDataPro;

  /// No description provided for @settingsExportReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Share a local summary of your progress.'**
  String get settingsExportReadyBody;

  /// No description provided for @settingsExportShared.
  ///
  /// In en, this message translates to:
  /// **'Local progress summary ready to share.'**
  String get settingsExportShared;

  /// No description provided for @settingsExportProOnly.
  ///
  /// In en, this message translates to:
  /// **'Export is a Pro feature.'**
  String get settingsExportProOnly;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon…'**
  String get settingsComingSoon;

  /// No description provided for @settingsAdvancedInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'30 / 90-day insights'**
  String get settingsAdvancedInsightsTitle;

  /// No description provided for @settingsAdvancedInsightsLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced clarity insights with Pro.'**
  String get settingsAdvancedInsightsLocked;

  /// No description provided for @settingsCustomRemindersLocked.
  ///
  /// In en, this message translates to:
  /// **'Custom reminder schedules unlock with Pro.'**
  String get settingsCustomRemindersLocked;

  /// No description provided for @silenceDurationProLocked.
  ///
  /// In en, this message translates to:
  /// **'Longer sessions unlock with Pro.'**
  String get silenceDurationProLocked;

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

  /// No description provided for @settingsLinkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link on this device.'**
  String get settingsLinkOpenFailed;

  /// No description provided for @settingsLocalModeHint.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device.'**
  String get settingsLocalModeHint;

  /// No description provided for @emotionWheelTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion wheel'**
  String get emotionWheelTitle;

  /// No description provided for @emotionImpactDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log emotion'**
  String get emotionImpactDialogTitle;

  /// No description provided for @emotionLogDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Logging this emotion helps you understand your day and track your progress gently. Do you want to log it?'**
  String get emotionLogDialogBody;

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

  /// No description provided for @silenceChallengeDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get silenceChallengeDurationLabel;

  /// No description provided for @silenceChallengeDurationOption.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String silenceChallengeDurationOption(int minutes);

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
  /// **'No emotions logged yet — open the Emotion Wheel when you\'re ready'**
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

  /// No description provided for @shareScoreText.
  ///
  /// In en, this message translates to:
  /// **'I scored {score} on Brain Clean! 🧠\nDownload the app and start your journey:'**
  String shareScoreText(int score);

  /// No description provided for @shareProfileText.
  ///
  /// In en, this message translates to:
  /// **'I\'m at level {level} in Brain Clean! 🏆\nJoin me:'**
  String shareProfileText(int level);

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

  /// No description provided for @weeklyReportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data this week — keep going!'**
  String get weeklyReportEmpty;

  /// No description provided for @weeklyReportEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get weeklyReportEmptyCta;

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
  /// **'Brain Clarity (BCI)'**
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

  /// No description provided for @bciOneLiner.
  ///
  /// In en, this message translates to:
  /// **'60% weekly assessment + 40% daily adherence over the last 7 days'**
  String get bciOneLiner;

  /// No description provided for @bciFullExplanation.
  ///
  /// In en, this message translates to:
  /// **'Brain Clarity (BCI) is a live 0–100 score that updates daily. 60% comes from your weekly assessment (BHI test and mental clarity), and 40% from how consistently you followed your recovery protocol over the last 7 days. If you haven’t completed the weekly assessment yet, the score is based on adherence only.'**
  String get bciFullExplanation;

  /// No description provided for @calmIndexOneLiner.
  ///
  /// In en, this message translates to:
  /// **'The inverse of your anxiety test — less anxiety means more calm'**
  String get calmIndexOneLiner;

  /// No description provided for @calmIndexFullExplanation.
  ///
  /// In en, this message translates to:
  /// **'The Calm Index is calculated from your anxiety test: 100 minus your anxiety score. It appears on the chart once you have at least two anxiety test results, and days between tests are estimated with a gradual fill.'**
  String get calmIndexFullExplanation;

  /// No description provided for @metricInfoA11yLabel.
  ///
  /// In en, this message translates to:
  /// **'What does this number mean?'**
  String get metricInfoA11yLabel;

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

  /// No description provided for @biometricFallbackPin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN instead'**
  String get biometricFallbackPin;

  /// No description provided for @securityCompromisedBanner.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device.'**
  String get securityCompromisedBanner;

  /// No description provided for @emotionOasisTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion Oasis — Safa'**
  String get emotionOasisTitle;

  /// No description provided for @emotionOasisHint.
  ///
  /// In en, this message translates to:
  /// **'Share how you\'re feeling right now...'**
  String get emotionOasisHint;

  /// No description provided for @emotionOasisAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Talk to Safa'**
  String get emotionOasisAnalyze;

  /// No description provided for @emotionOasisPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get emotionOasisPromptLabel;

  /// No description provided for @navTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navTabHome;

  /// No description provided for @navTabExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get navTabExercises;

  /// No description provided for @navTabSafa.
  ///
  /// In en, this message translates to:
  /// **'Safa'**
  String get navTabSafa;

  /// No description provided for @navTabJourney.
  ///
  /// In en, this message translates to:
  /// **'My Journey'**
  String get navTabJourney;

  /// No description provided for @navTabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navTabMore;

  /// No description provided for @sosFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Quick support'**
  String get sosFabTooltip;

  /// No description provided for @exercisesTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesTabTitle;

  /// No description provided for @exercisesCardCognitiveHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exercisesCardCognitiveHubTitle;

  /// No description provided for @exercisesCardCognitiveHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'20 science-backed exercises'**
  String get exercisesCardCognitiveHubSubtitle;

  /// No description provided for @exercisesCardPomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get exercisesCardPomodoroTitle;

  /// No description provided for @exercisesCardPomodoroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'25-minute focus'**
  String get exercisesCardPomodoroSubtitle;

  /// No description provided for @exercisesCardBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathing Exercise'**
  String get exercisesCardBreathingTitle;

  /// No description provided for @exercisesCardBreathingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4·4·4·4 box breathing'**
  String get exercisesCardBreathingSubtitle;

  /// No description provided for @exercisesCardGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Games'**
  String get exercisesCardGamesTitle;

  /// No description provided for @exercisesCardGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge your brain'**
  String get exercisesCardGamesSubtitle;

  /// No description provided for @exercisesCardSingleTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Single Task'**
  String get exercisesCardSingleTaskTitle;

  /// No description provided for @exercisesCardSingleTaskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Single-point focus'**
  String get exercisesCardSingleTaskSubtitle;

  /// No description provided for @exercisesCardDeepThinkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Thinking'**
  String get exercisesCardDeepThinkingTitle;

  /// No description provided for @exercisesCardDeepThinkingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10 distraction-free minutes'**
  String get exercisesCardDeepThinkingSubtitle;

  /// No description provided for @exercisesCardSukoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Sukoon'**
  String get exercisesCardSukoonTitle;

  /// No description provided for @exercisesCardSukoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wakeful rest — clear your mind'**
  String get exercisesCardSukoonSubtitle;

  /// No description provided for @safaTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Safa'**
  String get safaTabTitle;

  /// No description provided for @safaTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI guide · here when you need her'**
  String get safaTabSubtitle;

  /// No description provided for @safaTalkButton.
  ///
  /// In en, this message translates to:
  /// **'Talk to Safa'**
  String get safaTalkButton;

  /// No description provided for @safaOasisButton.
  ///
  /// In en, this message translates to:
  /// **'Emotion Oasis'**
  String get safaOasisButton;

  /// No description provided for @safaTrialExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your free Safa trial has ended — continue with her by subscribing to Pro'**
  String get safaTrialExpiredMessage;

  /// No description provided for @safaMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Safa is an AI self-support companion, not a replacement for a qualified professional. If things feel bigger than you can handle, seek support from a qualified person.'**
  String get safaMedicalDisclaimer;

  /// No description provided for @journeyTabTitle.
  ///
  /// In en, this message translates to:
  /// **'My Journey'**
  String get journeyTabTitle;

  /// No description provided for @journeyCardBciTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Clarity Index (BCI)'**
  String get journeyCardBciTitle;

  /// No description provided for @journeyCardDiagnosticTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Check'**
  String get journeyCardDiagnosticTitle;

  /// No description provided for @journeyCardWeeklyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get journeyCardWeeklyReportTitle;

  /// No description provided for @journeyQuickLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick links'**
  String get journeyQuickLinksTitle;

  /// No description provided for @moreTabTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTabTitle;

  /// No description provided for @moreProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get moreProfile;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @morePro.
  ///
  /// In en, this message translates to:
  /// **'Brain Clean Pro'**
  String get morePro;

  /// No description provided for @moreAccountability.
  ///
  /// In en, this message translates to:
  /// **'Accountability Partner'**
  String get moreAccountability;

  /// No description provided for @moreVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String moreVersion(String version);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 🌤️'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening 🌙'**
  String get homeGreetingEvening;

  /// No description provided for @homeHeroName.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get homeHeroName;

  /// No description provided for @homeStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get homeStreakLabel;

  /// No description provided for @homeBciLabel.
  ///
  /// In en, this message translates to:
  /// **'Brain Clarity Index'**
  String get homeBciLabel;

  /// No description provided for @homeBciTrend.
  ///
  /// In en, this message translates to:
  /// **'↑ this week'**
  String get homeBciTrend;

  /// No description provided for @homeActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s activities'**
  String get homeActivitiesTitle;

  /// No description provided for @homeActivitiesOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get homeActivitiesOf;

  /// No description provided for @homeSafaMessage.
  ///
  /// In en, this message translates to:
  /// **'Proud of you! Keep going 💚'**
  String get homeSafaMessage;

  /// No description provided for @homeProFeature.
  ///
  /// In en, this message translates to:
  /// **'Charts + advanced AI'**
  String get homeProFeature;

  /// No description provided for @homeActivityExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get homeActivityExercise;

  /// No description provided for @homeActivityWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get homeActivityWater;

  /// No description provided for @homeActivitySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get homeActivitySleep;

  /// No description provided for @homeActivityMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get homeActivityMovement;

  /// No description provided for @settingsSubscriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscriptionSection;

  /// No description provided for @anxietyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Anxiety Assessment'**
  String get anxietyScreenTitle;

  /// No description provided for @anxietyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Anxiety Result'**
  String get anxietyResultTitle;

  /// No description provided for @anxietyProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String anxietyProgressLabel(int current, int total);

  /// No description provided for @anxietyQ1.
  ///
  /// In en, this message translates to:
  /// **'Do you overthink a lot before sleep?'**
  String get anxietyQ1;

  /// No description provided for @anxietyQ2.
  ///
  /// In en, this message translates to:
  /// **'Do you replay scenarios in your head more than once?'**
  String get anxietyQ2;

  /// No description provided for @anxietyQ3.
  ///
  /// In en, this message translates to:
  /// **'Do you often expect the worst?'**
  String get anxietyQ3;

  /// No description provided for @anxietyQ4.
  ///
  /// In en, this message translates to:
  /// **'Is it hard for you to stop thinking?'**
  String get anxietyQ4;

  /// No description provided for @anxietyQ5.
  ///
  /// In en, this message translates to:
  /// **'Do you feel like your mind is always running?'**
  String get anxietyQ5;

  /// No description provided for @anxietyQ6.
  ///
  /// In en, this message translates to:
  /// **'Do you notice physical tension (tight shoulders, stomach, fast breathing)?'**
  String get anxietyQ6;

  /// No description provided for @anxietyQ7.
  ///
  /// In en, this message translates to:
  /// **'Do you avoid tasks or situations because of anxiety?'**
  String get anxietyQ7;

  /// No description provided for @anxietyQ8.
  ///
  /// In en, this message translates to:
  /// **'Does anxiety affect your focus or sleep on a daily basis?'**
  String get anxietyQ8;

  /// No description provided for @anxietyOptionNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get anxietyOptionNever;

  /// No description provided for @anxietyOptionSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get anxietyOptionSometimes;

  /// No description provided for @anxietyOptionOften.
  ///
  /// In en, this message translates to:
  /// **'Often'**
  String get anxietyOptionOften;

  /// No description provided for @anxietyOptionAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get anxietyOptionAlways;

  /// No description provided for @anxietyLevelCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get anxietyLevelCalm;

  /// No description provided for @anxietyLevelModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get anxietyLevelModerate;

  /// No description provided for @anxietyLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get anxietyLevelHigh;

  /// No description provided for @anxietyLevelSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get anxietyLevelSevere;

  /// No description provided for @anxietyInterpretationCalm.
  ///
  /// In en, this message translates to:
  /// **'Your anxiety is in a normal range — keep up your current pace.'**
  String get anxietyInterpretationCalm;

  /// No description provided for @anxietyInterpretationModerate.
  ///
  /// In en, this message translates to:
  /// **'Early signs of chronic anxiety — an anxiety journal can help a lot.'**
  String get anxietyInterpretationModerate;

  /// No description provided for @anxietyInterpretationHigh.
  ///
  /// In en, this message translates to:
  /// **'Anxiety is affecting your life — Safa will guide you step by step.'**
  String get anxietyInterpretationHigh;

  /// No description provided for @anxietyInterpretationSevere.
  ///
  /// In en, this message translates to:
  /// **'We recommend seeing a specialist + start the anxiety program with Safa.'**
  String get anxietyInterpretationSevere;

  /// No description provided for @anxietyStartProgramCta.
  ///
  /// In en, this message translates to:
  /// **'Start the program with Safa'**
  String get anxietyStartProgramCta;

  /// No description provided for @anxietyRetakeTest.
  ///
  /// In en, this message translates to:
  /// **'Retake the test'**
  String get anxietyRetakeTest;

  /// No description provided for @anxietyJourneyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Anxiety Assessment'**
  String get anxietyJourneyCardTitle;

  /// No description provided for @anxietyJourneyCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'8 questions · chronic anxiety screening'**
  String get anxietyJourneyCardSubtitle;

  /// No description provided for @anxietyJourneyCardLatestScore.
  ///
  /// In en, this message translates to:
  /// **'Latest score: {score}%'**
  String anxietyJourneyCardLatestScore(int score);

  /// No description provided for @anxietySaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your result. Please try again.'**
  String get anxietySaveError;

  /// No description provided for @anxietyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your result.'**
  String get anxietyLoadError;

  /// No description provided for @anxietyNoResultYet.
  ///
  /// In en, this message translates to:
  /// **'No result yet. Complete a short check-in first.'**
  String get anxietyNoResultYet;

  /// No description provided for @worryWindowTitle.
  ///
  /// In en, this message translates to:
  /// **'Worry Window'**
  String get worryWindowTitle;

  /// No description provided for @worryJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Worry Journal'**
  String get worryJournalTitle;

  /// No description provided for @worrySafaPrompt.
  ///
  /// In en, this message translates to:
  /// **'Write what\'s on your mind right now — it doesn\'t have to be organized, just get it out 🌿'**
  String get worrySafaPrompt;

  /// No description provided for @worryJournalHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s worrying you today?'**
  String get worryJournalHint;

  /// No description provided for @worryDurationTen.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get worryDurationTen;

  /// No description provided for @worryDurationFifteen.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get worryDurationFifteen;

  /// No description provided for @worryRuleReminder.
  ///
  /// In en, this message translates to:
  /// **'💡 Not before bedtime'**
  String get worryRuleReminder;

  /// No description provided for @worryTimerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get worryTimerStart;

  /// No description provided for @worryTimerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get worryTimerPause;

  /// No description provided for @worryTimerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get worryTimerReset;

  /// No description provided for @worryWindowCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Well done — you emptied your mind 💚 Sleep will be calmer tonight.'**
  String get worryWindowCompleteMessage;

  /// No description provided for @worrySaveAndClose.
  ///
  /// In en, this message translates to:
  /// **'Save & close'**
  String get worrySaveAndClose;

  /// No description provided for @worrySaveFab.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get worrySaveFab;

  /// No description provided for @worrySavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'✓ Saved'**
  String get worrySavedSnackbar;

  /// No description provided for @worryPastEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s entries'**
  String get worryPastEntriesTitle;

  /// No description provided for @worryNoEntriesToday.
  ///
  /// In en, this message translates to:
  /// **'No entries yet today.'**
  String get worryNoEntriesToday;

  /// No description provided for @worryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load entries.'**
  String get worryLoadError;

  /// No description provided for @worryDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard writing?'**
  String get worryDiscardTitle;

  /// No description provided for @worryDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved text. Close without saving?'**
  String get worryDiscardBody;

  /// No description provided for @worrySettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Worry Window'**
  String get worrySettingsSectionTitle;

  /// No description provided for @worrySettingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get worrySettingsReminderTime;

  /// No description provided for @worrySettingsReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get worrySettingsReminderEnabled;

  /// No description provided for @worryTimingWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Worry window should be before bedtime — pick an earlier time.'**
  String get worryTimingWarning;

  /// No description provided for @worryNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Worry window time 🧠'**
  String get worryNotifTitle;

  /// No description provided for @worryNotifBody.
  ///
  /// In en, this message translates to:
  /// **'10 minutes to empty your mind — you\'ll stay calmer all night'**
  String get worryNotifBody;

  /// No description provided for @homeActivityWorryJournal.
  ///
  /// In en, this message translates to:
  /// **'✍️ Worry Journal'**
  String get homeActivityWorryJournal;

  /// No description provided for @homeActivityWorryWindow.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Worry Window'**
  String get homeActivityWorryWindow;

  /// No description provided for @safaProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Your program with Safa 🌿'**
  String get safaProgramTitle;

  /// No description provided for @safaProgramCta.
  ///
  /// In en, this message translates to:
  /// **'Start with Safa'**
  String get safaProgramCta;

  /// No description provided for @safaProgramLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your program.'**
  String get safaProgramLoadError;

  /// No description provided for @safaProgramFallbackCalm.
  ///
  /// In en, this message translates to:
  /// **'Your anxiety is under control — keep your current pace. Use the worry journal if pressure builds. Safa is here if you need support. You are on the right path 💚'**
  String get safaProgramFallbackCalm;

  /// No description provided for @safaProgramFallbackModerate.
  ///
  /// In en, this message translates to:
  /// **'Early chronic anxiety signs — the worry journal will help a lot. Try a daily worry window at 5 PM. Safa will check in weekly. Small daily steps make a difference 🌿'**
  String get safaProgramFallbackModerate;

  /// No description provided for @safaProgramFallbackHigh.
  ///
  /// In en, this message translates to:
  /// **'Anxiety is affecting your days — start a daily worry window and add light movement. Safa will build a weekly plan with you. You are stronger than anxiety 💪'**
  String get safaProgramFallbackHigh;

  /// No description provided for @safaProgramFallbackSevere.
  ///
  /// In en, this message translates to:
  /// **'Anxiety is high — consider seeing a specialist alongside the program. Start the worry journal daily. Safa is with you every step. You do not have to face this alone 🤝'**
  String get safaProgramFallbackSevere;

  /// No description provided for @calmIndexLegendBci.
  ///
  /// In en, this message translates to:
  /// **'Brain Clarity (BCI)'**
  String get calmIndexLegendBci;

  /// No description provided for @calmIndexLegendCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm Index'**
  String get calmIndexLegendCalm;

  /// No description provided for @safaCheckinIcon.
  ///
  /// In en, this message translates to:
  /// **'🌙'**
  String get safaCheckinIcon;

  /// No description provided for @safaCheckinTitle.
  ///
  /// In en, this message translates to:
  /// **'A note from Safa'**
  String get safaCheckinTitle;

  /// No description provided for @safaCheckinBody.
  ///
  /// In en, this message translates to:
  /// **'I noticed you journal worries at night often — that can affect your sleep. Would you like to move your worry window to the afternoon?'**
  String get safaCheckinBody;

  /// No description provided for @safaCheckinAction.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get safaCheckinAction;

  /// No description provided for @safaCheckinTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Worry window reminder updated.'**
  String get safaCheckinTimeUpdated;

  /// No description provided for @dailyChallengeIcon.
  ///
  /// In en, this message translates to:
  /// **'🧠'**
  String get dailyChallengeIcon;

  /// No description provided for @dailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s challenge'**
  String get dailyChallengeTitle;

  /// No description provided for @dailyChallengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done ✓'**
  String get dailyChallengeCompleted;

  /// No description provided for @dailyChallengeStart.
  ///
  /// In en, this message translates to:
  /// **'Start challenge'**
  String get dailyChallengeStart;

  /// No description provided for @dailyChallengeReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay challenge 🔄'**
  String get dailyChallengeReplay;

  /// No description provided for @dailyChallengeGameNBack.
  ///
  /// In en, this message translates to:
  /// **'N-Back Memory'**
  String get dailyChallengeGameNBack;

  /// No description provided for @dailyChallengeGameSpeedSort.
  ///
  /// In en, this message translates to:
  /// **'Speed Sort'**
  String get dailyChallengeGameSpeedSort;

  /// No description provided for @dailyChallengeGameColorWord.
  ///
  /// In en, this message translates to:
  /// **'Color Word'**
  String get dailyChallengeGameColorWord;

  /// No description provided for @dailyChallengeGameNumberMemory.
  ///
  /// In en, this message translates to:
  /// **'Number Memory'**
  String get dailyChallengeGameNumberMemory;

  /// No description provided for @dailyChallengeGamePatternMatch.
  ///
  /// In en, this message translates to:
  /// **'Pattern Match'**
  String get dailyChallengeGamePatternMatch;

  /// No description provided for @dailyChallengeGameCrossword.
  ///
  /// In en, this message translates to:
  /// **'Crossword'**
  String get dailyChallengeGameCrossword;

  /// No description provided for @dailyChallengeSubtitleNBack.
  ///
  /// In en, this message translates to:
  /// **'Train your working memory'**
  String get dailyChallengeSubtitleNBack;

  /// No description provided for @dailyChallengeSubtitleSpeedSort.
  ///
  /// In en, this message translates to:
  /// **'Speed up your logical thinking'**
  String get dailyChallengeSubtitleSpeedSort;

  /// No description provided for @dailyChallengeSubtitleColorWord.
  ///
  /// In en, this message translates to:
  /// **'Challenge your visual focus'**
  String get dailyChallengeSubtitleColorWord;

  /// No description provided for @dailyChallengeSubtitleNumberMemory.
  ///
  /// In en, this message translates to:
  /// **'Strengthen your number memory'**
  String get dailyChallengeSubtitleNumberMemory;

  /// No description provided for @dailyChallengeSubtitlePatternMatch.
  ///
  /// In en, this message translates to:
  /// **'Sharpen your visual discrimination'**
  String get dailyChallengeSubtitlePatternMatch;

  /// No description provided for @dailyChallengeSubtitleCrossword.
  ///
  /// In en, this message translates to:
  /// **'Expand your Arabic vocabulary'**
  String get dailyChallengeSubtitleCrossword;

  /// No description provided for @weeklyReportEntryIcon.
  ///
  /// In en, this message translates to:
  /// **'📊'**
  String get weeklyReportEntryIcon;

  /// No description provided for @weeklyReportEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReportEntryTitle;

  /// No description provided for @weeklyReportEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'See your progress this week'**
  String get weeklyReportEntrySubtitle;

  /// No description provided for @weeklyReportLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your weekly report.'**
  String get weeklyReportLoadError;

  /// No description provided for @weeklyReportBciLabel.
  ///
  /// In en, this message translates to:
  /// **'Brain Clarity Index'**
  String get weeklyReportBciLabel;

  /// No description provided for @weeklyReportBciNoData.
  ///
  /// In en, this message translates to:
  /// **'No data recorded this week'**
  String get weeklyReportBciNoData;

  /// No description provided for @weeklyReportBciUp.
  ///
  /// In en, this message translates to:
  /// **'↑ +{percent}%'**
  String weeklyReportBciUp(String percent);

  /// No description provided for @weeklyReportBciDown.
  ///
  /// In en, this message translates to:
  /// **'↓ -{percent}%'**
  String weeklyReportBciDown(String percent);

  /// No description provided for @weeklyReportBciFlat.
  ///
  /// In en, this message translates to:
  /// **'→ Steady'**
  String get weeklyReportBciFlat;

  /// No description provided for @weeklyReportActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity summary'**
  String get weeklyReportActivityTitle;

  /// No description provided for @weeklyReportStatGamesIcon.
  ///
  /// In en, this message translates to:
  /// **'🎮'**
  String get weeklyReportStatGamesIcon;

  /// No description provided for @weeklyReportStatGames.
  ///
  /// In en, this message translates to:
  /// **'games'**
  String get weeklyReportStatGames;

  /// No description provided for @weeklyReportStatChallengesIcon.
  ///
  /// In en, this message translates to:
  /// **'🧩'**
  String get weeklyReportStatChallengesIcon;

  /// No description provided for @weeklyReportStatChallenges.
  ///
  /// In en, this message translates to:
  /// **'challenges'**
  String get weeklyReportStatChallenges;

  /// No description provided for @weeklyReportStatChallengesValue.
  ///
  /// In en, this message translates to:
  /// **'{count}/7'**
  String weeklyReportStatChallengesValue(int count);

  /// No description provided for @weeklyReportStatWorryIcon.
  ///
  /// In en, this message translates to:
  /// **'✍️'**
  String get weeklyReportStatWorryIcon;

  /// No description provided for @weeklyReportStatWorry.
  ///
  /// In en, this message translates to:
  /// **'worry notes'**
  String get weeklyReportStatWorry;

  /// No description provided for @weeklyReportStatStreakIcon.
  ///
  /// In en, this message translates to:
  /// **'🔥'**
  String get weeklyReportStatStreakIcon;

  /// No description provided for @weeklyReportStatStreak.
  ///
  /// In en, this message translates to:
  /// **'streak days'**
  String get weeklyReportStatStreak;

  /// No description provided for @weeklyReportBestGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Star of the week 🏆'**
  String get weeklyReportBestGameTitle;

  /// No description provided for @weeklyReportBestGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best performance this week'**
  String get weeklyReportBestGameSubtitle;

  /// No description provided for @weeklyReportCalmTitle.
  ///
  /// In en, this message translates to:
  /// **'Calm Index'**
  String get weeklyReportCalmTitle;

  /// No description provided for @weeklyReportSafaAvatar.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weeklyReportSafaAvatar;

  /// No description provided for @smartReminderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart reminder'**
  String get smartReminderSectionTitle;

  /// No description provided for @smartReminderToggle.
  ///
  /// In en, this message translates to:
  /// **'Smart reminder'**
  String get smartReminderToggle;

  /// No description provided for @smartReminderStatusDetected.
  ///
  /// In en, this message translates to:
  /// **'Reminder will arrive at {hour}:00 based on your habit 🎯'**
  String smartReminderStatusDetected(int hour);

  /// No description provided for @smartReminderStatusLearning.
  ///
  /// In en, this message translates to:
  /// **'Open the app 3 days in a row so we can learn your favorite time'**
  String get smartReminderStatusLearning;

  /// No description provided for @smartReminderInfoChip.
  ///
  /// In en, this message translates to:
  /// **'Learns from your behavior automatically'**
  String get smartReminderInfoChip;

  /// No description provided for @dailyProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Program'**
  String get dailyProgramTitle;

  /// No description provided for @dailyProgramLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load today\'s program.'**
  String get dailyProgramLoadError;

  /// No description provided for @dailyProgramGreetingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Good morning 🌿'**
  String get dailyProgramGreetingGeneric;

  /// No description provided for @dailyProgramGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name} 🌿'**
  String dailyProgramGreetingNamed(String name);

  /// No description provided for @dailyProgramDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dailyProgramDayLabel(int day);

  /// No description provided for @dailyProgramRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} steps left'**
  String dailyProgramRemaining(int count);

  /// No description provided for @dailyProgramRemainingZero.
  ///
  /// In en, this message translates to:
  /// **'All steps done'**
  String get dailyProgramRemainingZero;

  /// No description provided for @dailyProgramProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String dailyProgramProgressPercent(int percent);

  /// No description provided for @dailyProgramDoneCta.
  ///
  /// In en, this message translates to:
  /// **'Done ✅'**
  String get dailyProgramDoneCta;

  /// No description provided for @dailyProgramChooseMood.
  ///
  /// In en, this message translates to:
  /// **'Choose your mood'**
  String get dailyProgramChooseMood;

  /// No description provided for @dailyProgramOpenEmotionWheel.
  ///
  /// In en, this message translates to:
  /// **'Open Emotion Wheel'**
  String get dailyProgramOpenEmotionWheel;

  /// No description provided for @dailyProgramOpenCalmExercise.
  ///
  /// In en, this message translates to:
  /// **'Open Calm Exercise'**
  String get dailyProgramOpenCalmExercise;

  /// No description provided for @dailyProgramOpenSingleTask.
  ///
  /// In en, this message translates to:
  /// **'Open Single Task'**
  String get dailyProgramOpenSingleTask;

  /// No description provided for @dailyProgramOpenWorryJournal.
  ///
  /// In en, this message translates to:
  /// **'Open Worry Journal'**
  String get dailyProgramOpenWorryJournal;

  /// No description provided for @dailyProgramSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get dailyProgramSkip;

  /// No description provided for @dailyProgramAllStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'All steps today'**
  String get dailyProgramAllStepsTitle;

  /// No description provided for @dailyProgramCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'🏁 You finished today\'s journey! Proud of you 💚'**
  String get dailyProgramCompleteTitle;

  /// No description provided for @dailyProgramViewReport.
  ///
  /// In en, this message translates to:
  /// **'See today\'s report'**
  String get dailyProgramViewReport;

  /// No description provided for @dailyProgramHomeIcon.
  ///
  /// In en, this message translates to:
  /// **'🌿'**
  String get dailyProgramHomeIcon;

  /// No description provided for @dailyProgramHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Daily Program'**
  String get dailyProgramHomeTitle;

  /// No description provided for @dailyProgramHomeStart.
  ///
  /// In en, this message translates to:
  /// **'Start your day journey'**
  String get dailyProgramHomeStart;

  /// No description provided for @dailyProgramHomeInProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} steps left'**
  String dailyProgramHomeInProgress(int count);

  /// No description provided for @dailyProgramHomeDone.
  ///
  /// In en, this message translates to:
  /// **'You finished today\'s journey ✅'**
  String get dailyProgramHomeDone;

  /// No description provided for @dailyProgramWaterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'💧 Did you drink a glass of water?'**
  String get dailyProgramWaterSheetTitle;

  /// No description provided for @dailyProgramWaterSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Water helps your brain work better'**
  String get dailyProgramWaterSheetSubtitle;

  /// No description provided for @dailyProgramWaterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, I drank ✅'**
  String get dailyProgramWaterConfirm;

  /// No description provided for @dailyProgramWaterLater.
  ///
  /// In en, this message translates to:
  /// **'Not yet — I\'ll drink now'**
  String get dailyProgramWaterLater;

  /// No description provided for @dailyProgramMovementSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'🚶 Did you move today?'**
  String get dailyProgramMovementSheetTitle;

  /// No description provided for @dailyProgramMovementSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Even 5 minutes of walking helps'**
  String get dailyProgramMovementSheetSubtitle;

  /// No description provided for @dailyProgramMovementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes ✅'**
  String get dailyProgramMovementConfirm;

  /// No description provided for @dailyProgramMovementDoNow.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it now'**
  String get dailyProgramMovementDoNow;

  /// No description provided for @dailyProgramMovementSkipToday.
  ///
  /// In en, this message translates to:
  /// **'Not able today'**
  String get dailyProgramMovementSkipToday;

  /// No description provided for @dayEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Close your day gently 💚'**
  String get dayEndTitle;

  /// No description provided for @dayEndSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every step you took today is enough. Closing with calm is progress.'**
  String get dayEndSubtitle;

  /// No description provided for @dayEndSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day summary'**
  String get dayEndSummaryTitle;

  /// No description provided for @dayEndProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} steps completed'**
  String dayEndProgressSummary(int completed, int total);

  /// No description provided for @dayEndSkippedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped — that is okay'**
  String dayEndSkippedSummary(int count);

  /// No description provided for @dayEndRemainingSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} still open'**
  String dayEndRemainingSummary(int count);

  /// No description provided for @dayEndReflection0.
  ///
  /// In en, this message translates to:
  /// **'What was the best thing that happened today?'**
  String get dayEndReflection0;

  /// No description provided for @dayEndReflection1.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do again tomorrow?'**
  String get dayEndReflection1;

  /// No description provided for @dayEndReflection2.
  ///
  /// In en, this message translates to:
  /// **'What did you feel today?'**
  String get dayEndReflection2;

  /// No description provided for @dayEndReflection3.
  ///
  /// In en, this message translates to:
  /// **'One thing you\'re grateful for today?'**
  String get dayEndReflection3;

  /// No description provided for @dayEndClosingMessage.
  ///
  /// In en, this message translates to:
  /// **'Rest well 🌙 Tomorrow is a fresh start.'**
  String get dayEndClosingMessage;

  /// No description provided for @dayEndFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Close my day'**
  String get dayEndFinishButton;

  /// No description provided for @sukoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Sukoon'**
  String get sukoonTitle;

  /// No description provided for @sukoonIntro.
  ///
  /// In en, this message translates to:
  /// **'Sit in stillness. Let your mind wander — think, drift, or think of nothing at all.\nScience shows these quiet moments restore your attention.'**
  String get sukoonIntro;

  /// No description provided for @sukoonDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sukoonDurationLabel;

  /// No description provided for @sukoonDuration3.
  ///
  /// In en, this message translates to:
  /// **'3 minutes'**
  String get sukoonDuration3;

  /// No description provided for @sukoonDuration5.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get sukoonDuration5;

  /// No description provided for @sukoonDuration10.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get sukoonDuration10;

  /// No description provided for @sukoonDuration15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get sukoonDuration15;

  /// No description provided for @sukoonDurationOption.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sukoonDurationOption(int minutes);

  /// No description provided for @sukoonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get sukoonStart;

  /// No description provided for @sukoonPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get sukoonPause;

  /// No description provided for @sukoonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sukoonContinue;

  /// No description provided for @sukoonRestart.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get sukoonRestart;

  /// No description provided for @sukoonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get sukoonReset;

  /// No description provided for @sukoonInterruptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Stillness was interrupted — no problem. You can continue or start fresh 🌿'**
  String get sukoonInterruptedMessage;

  /// No description provided for @sukoonCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'You finished {minutes} minutes of stillness 🌿 Your mind rested.'**
  String sukoonCompleteTitle(int minutes);

  /// No description provided for @sukoonWanderHint.
  ///
  /// In en, this message translates to:
  /// **'Where did your mind go? (optional)'**
  String get sukoonWanderHint;

  /// No description provided for @sukoonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get sukoonSave;

  /// No description provided for @sukoonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get sukoonSkip;

  /// No description provided for @socialMediaUsageLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading social media time…'**
  String get socialMediaUsageLoading;

  /// No description provided for @socialMediaUsagePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your social media time'**
  String get socialMediaUsagePromptTitle;

  /// No description provided for @socialMediaUsagePromptBody.
  ///
  /// In en, this message translates to:
  /// **'A gentle view of today\'s screen time — no blocking, no judgment. Enable Usage Access in system settings.'**
  String get socialMediaUsagePromptBody;

  /// No description provided for @socialMediaUsageGrantButton.
  ///
  /// In en, this message translates to:
  /// **'Open Usage Access settings'**
  String get socialMediaUsageGrantButton;

  /// No description provided for @socialMediaUsageTodayTotal.
  ///
  /// In en, this message translates to:
  /// **'You spent {minutes} minutes on social media today'**
  String socialMediaUsageTodayTotal(int minutes);

  /// No description provided for @socialMediaUsageTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instagram · TikTok · Snapchat · Facebook · X — for awareness only'**
  String get socialMediaUsageTodaySubtitle;
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
