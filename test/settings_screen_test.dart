import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/theme/app_color_theme.dart';
import 'package:brain_clean_mobile/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/localized_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget settingsBody({
    required AppLocalizations loc,
    VoidCallback? onLogout,
    VoidCallback? onDelete,
    ValueChanged<Locale>? onLanguage,
    ValueChanged<AppColorTheme>? onTheme,
    ValueChanged<bool>? onEmotion,
  }) {
    return Scaffold(
      body: SettingsHomeBody(
        loc: loc,
        displayName: 'Alex',
        isPro: false,
        locale: const Locale('en'),
        selectedTheme: AppColorTheme.dark,
        emotionNotificationsEnabled: true,
        dailyFocusReminderEnabled: false,
        biometricLockEnabled: false,
        appVersion: '2.0.1-test',
        onEditDisplayName: () {},
        onOpenPremium: () {},
        onSelectLanguage: onLanguage ?? (_) {},
        onSelectTheme: onTheme ?? (_) {},
        onEmotionNotificationsChanged: onEmotion ?? (_) {},
        onDailyFocusReminderChanged: (_) {},
        onBiometricLockChanged: (_) {},
        onLogout: onLogout ?? () {},
        onDeleteAccount: onDelete ?? () {},
        onOpenPrivacyPolicy: () {},
        onOpenContact: () {},
      ),
    );
  }

  testWidgets('Settings shows required sections with AppColors tokens',
      (tester) async {
    final loc = AppLocalizationsEn();
    var logout = false;
    var delete = false;
    Locale? language;
    AppColorTheme? theme;

    await tester.pumpWidget(
      createLocalizedTestWidget(
        settingsBody(
          loc: loc,
          onLogout: () => logout = true,
          onDelete: () => delete = true,
          onLanguage: (value) => language = value,
          onTheme: (value) => theme = value,
        ),
      ),
    );
    await tester.pump();

    expect(find.text(loc.settingsTitle), findsOneWidget);
    expect(find.text(loc.settingsProfileSection), findsOneWidget);
    expect(find.byKey(settingsProfileIdentityKey), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text(loc.settingsNotificationsSection), findsOneWidget);
    expect(find.text(loc.settingsEmotionNotifications), findsOneWidget);
    expect(find.text(loc.settingsAppearanceSection), findsOneWidget);
    expect(find.byKey(const Key('color_theme_swatch_dark')), findsOneWidget);
    expect(find.byKey(const Key('color_theme_swatch_light')), findsOneWidget);
    expect(find.text(loc.settingsLanguageSection), findsOneWidget);
    expect(find.byKey(settingsLanguageArKey), findsOneWidget);
    expect(find.byKey(settingsLanguageEnKey), findsOneWidget);
    expect(find.text(loc.settingsAccountSection), findsOneWidget);
    expect(find.byKey(settingsLogoutKey), findsOneWidget);
    expect(find.byKey(settingsDeleteAccountKey), findsOneWidget);
    expect(find.byKey(settingsResetKey), findsOneWidget);
    expect(find.text(loc.settingsAboutSection), findsOneWidget);
    expect(find.text(loc.settingsVersion), findsOneWidget);
    expect(find.text('2.0.1-test'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('color_theme_swatch_light')));
    await tester.tap(find.byKey(const Key('color_theme_swatch_light')));
    await tester.pump();
    expect(theme, AppColorTheme.light);

    await tester.ensureVisible(find.byKey(settingsLanguageArKey));
    await tester.tap(find.byKey(settingsLanguageArKey));
    await tester.pump();
    expect(language, const Locale('ar'));

    await tester.ensureVisible(find.byKey(settingsLogoutKey));
    await tester.tap(find.byKey(settingsLogoutKey));
    await tester.pump();
    expect(logout, isTrue);

    await tester.ensureVisible(find.byKey(settingsDeleteAccountKey));
    await tester.tap(find.byKey(settingsDeleteAccountKey));
    await tester.pump();
    expect(delete, isTrue);
  });
}
