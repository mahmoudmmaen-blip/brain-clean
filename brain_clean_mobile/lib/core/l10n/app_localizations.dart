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
