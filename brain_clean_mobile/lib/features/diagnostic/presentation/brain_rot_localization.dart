import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../domain/diagnostic_model.dart';

/// Arabic locale uses [BrainRotTest.questionsAr]; English uses ARB strings.
String brainRotQuestionFor(
  BuildContext context,
  AppLocalizations loc,
  int index,
) {
  if (index < 0 || index >= BrainRotTest.questionCount) {
    return '';
  }
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  if (isArabic) {
    return BrainRotTest.questionsAr[index];
  }
  return _englishQuestion(loc, index);
}

String _englishQuestion(AppLocalizations loc, int index) => switch (index) {
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
