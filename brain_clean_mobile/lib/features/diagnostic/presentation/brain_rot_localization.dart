import '../../../core/l10n/app_localizations.dart';

/// Maps question index (0–9) to localized Brain Rot prompt text.
String brainRotQuestionText(AppLocalizations loc, int index) => switch (index) {
      0 => loc.diagnosticBrainRotQ1,
      1 => loc.diagnosticBrainRotQ2,
      2 => loc.diagnosticBrainRotQ3,
      3 => loc.diagnosticBrainRotQ4,
      4 => loc.diagnosticBrainRotQ5,
      5 => loc.diagnosticBrainRotQ6,
      6 => loc.diagnosticBrainRotQ7,
      7 => loc.diagnosticBrainRotQ8,
      8 => loc.diagnosticBrainRotQ9,
      _ => loc.diagnosticBrainRotQ10,
    };
