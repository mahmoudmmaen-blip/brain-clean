import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// English [AppLocalizations] generated from ARB — use instead of hardcoded literals.
AppLocalizations get testL10n => AppLocalizationsEn();

/// Reads [AppLocalizations] from a pumped widget tree at [anchor].
AppLocalizations l10nFromTester(WidgetTester tester, Finder anchor) {
  return AppLocalizations.of(tester.element(anchor))!;
}
