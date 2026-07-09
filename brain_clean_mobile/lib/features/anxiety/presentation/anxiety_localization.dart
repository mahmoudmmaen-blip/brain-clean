import '../../../core/l10n/app_localizations.dart';
import '../domain/anxiety_level.dart';

String anxietyQuestionFor(AppLocalizations loc, int index) {
  switch (index) {
    case 0:
      return loc.anxietyQ1;
    case 1:
      return loc.anxietyQ2;
    case 2:
      return loc.anxietyQ3;
    case 3:
      return loc.anxietyQ4;
    case 4:
      return loc.anxietyQ5;
    case 5:
      return loc.anxietyQ6;
    case 6:
      return loc.anxietyQ7;
    case 7:
      return loc.anxietyQ8;
    default:
      return '';
  }
}

String anxietyLevelLabelFor(AppLocalizations loc, AnxietyLevel level) {
  switch (level) {
    case AnxietyLevel.calm:
      return loc.anxietyLevelCalm;
    case AnxietyLevel.moderate:
      return loc.anxietyLevelModerate;
    case AnxietyLevel.high:
      return loc.anxietyLevelHigh;
    case AnxietyLevel.severe:
      return loc.anxietyLevelSevere;
  }
}

String anxietyInterpretationFor(AppLocalizations loc, AnxietyLevel level) {
  switch (level) {
    case AnxietyLevel.calm:
      return loc.anxietyInterpretationCalm;
    case AnxietyLevel.moderate:
      return loc.anxietyInterpretationModerate;
    case AnxietyLevel.high:
      return loc.anxietyInterpretationHigh;
    case AnxietyLevel.severe:
      return loc.anxietyInterpretationSevere;
  }
}

List<String> anxietyOptionLabels(AppLocalizations loc) => [
      loc.anxietyOptionNever,
      loc.anxietyOptionSometimes,
      loc.anxietyOptionOften,
      loc.anxietyOptionAlways,
    ];
