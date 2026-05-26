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
}
