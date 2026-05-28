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
  /// **'Five daily habits · penalty box for missed check-ins'**
  String get dashboardOpenRecoveryGridSubtitle;

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
  /// **'Some habits were missed. Open the penalty box to record accountability.'**
  String get recoveryMissedHabitsSubtitle;

  /// No description provided for @recoveryOpenPenaltyBox.
  ///
  /// In en, this message translates to:
  /// **'Open Penalty Box'**
  String get recoveryOpenPenaltyBox;

  /// No description provided for @recoveryDayEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Check off each habit as you complete it today.'**
  String get recoveryDayEmptyHint;

  /// No description provided for @recoveryPenaltyCount.
  ///
  /// In en, this message translates to:
  /// **'Penalties recorded: {count}'**
  String recoveryPenaltyCount(int count);

  /// No description provided for @recoveryPenaltyBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Penalty Box'**
  String get recoveryPenaltyBoxTitle;

  /// No description provided for @recoveryPenaltyBoxMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirming applies a −{deduction} BC_score accountability entry for missed habits today.'**
  String recoveryPenaltyBoxMessage(int deduction);

  /// No description provided for @recoveryPenaltyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm penalty'**
  String get recoveryPenaltyConfirm;

  /// No description provided for @recoveryPenaltyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get recoveryPenaltyCancel;

  /// No description provided for @recoveryPenaltyApplied.
  ///
  /// In en, this message translates to:
  /// **'Penalty recorded for today.'**
  String get recoveryPenaltyApplied;
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
