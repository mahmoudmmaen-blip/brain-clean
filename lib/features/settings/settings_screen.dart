import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/app_snack_bar.dart';
import '../../core/presentation/confirm_dialog.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/security/security_status_provider.dart';
import '../../core/services/external_link_service.dart';
import '../../core/services/smart_notification_service.dart';
import '../../core/services/weekly_report_service.dart';
import '../../core/storage/hive_bootstrap.dart';
import '../../core/theme/app_color_theme.dart';
import '../../core/theme/app_color_theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_constants.dart';
import '../../core/theme/v2_shell_visual.dart';
import '../pro/application/subscription_service_provider.dart';

const settingsProTileKey = Key('settings_pro_tile');
const settingsResetKey = Key('settings_reset_data');
const settingsPrivacyPolicyKey = Key('settings_privacy_policy');
const settingsContactUsKey = Key('settings_contact_us');
const settingsLogoutKey = Key('settings_logout');
const settingsDeleteAccountKey = Key('settings_delete_account');
const settingsProfileIdentityKey = Key('settings_profile_identity');
const settingsLanguageArKey = Key('settings_language_ar');
const settingsLanguageEnKey = Key('settings_language_en');

const double _kGapBeforeFirstSection = AppDesignConstants.v2GapMajor;
const double _kGapBetweenSections = AppDesignConstants.v2GapSection;
const double _kGapSectionToRow = AppDesignConstants.v2GapSectionLabel;
const int _kDisplayNameMaxLength = 40;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _editDisplayName(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final current = ref.read(appPreferencesProvider).profileDisplayName.trim();
    final controller = TextEditingController(text: current);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            loc.v2ProfileEditNameTitle,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: _kDisplayNameMaxLength,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: loc.v2ProfileEditNameHint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              counterStyle: const TextStyle(color: AppColors.textSecondary),
            ),
            onSubmitted: (value) => Navigator.of(ctx).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text(loc.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              style: V2ShellVisual.primaryFilled(),
              child: Text(loc.commonConfirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (saved == null || !context.mounted) return;
    try {
      await ref
          .read(appPreferencesProvider.notifier)
          .setProfileDisplayName(saved);
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, loc.v2ProfileNameSaveFailed);
    }
  }

  Future<void> _openExternal(
    BuildContext context,
    Future<bool> Function() open,
  ) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final ok = await open();
      if (!context.mounted || ok) return;
      showAppSnackBar(context, loc.settingsLinkUnavailable);
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, loc.settingsLinkUnavailable);
    }
  }

  Future<void> _selectLanguage(WidgetRef ref, Locale next) async {
    try {
      ref.read(localeProvider.notifier).state = next;
      await persistLocale(ref, next);
      ref.read(smartNotificationServiceProvider).rescheduleAll();
      ref.read(weeklyReportServiceProvider).schedule();
    } catch (_) {
      // Locale still updates in memory; persistence is best-effort.
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: loc.settingsLogoutConfirmTitle,
      message: loc.settingsLogoutConfirmBody,
      confirmLabel: loc.commonConfirm,
      cancelLabel: loc.commonCancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref
          .read(appPreferencesProvider.notifier)
          .markOnboardingIncomplete();
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, loc.settingsActionFailed);
      return;
    }
    if (context.mounted) context.go(AppRoutes.splash);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: loc.settingsDeleteAccountConfirmTitle,
      message: loc.settingsDeleteAccountConfirmBody,
      confirmLabel: loc.commonConfirm,
      cancelLabel: loc.commonCancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await HiveBootstrap.clearAllDurableBoxes();
      ref.invalidate(appPreferencesProvider);
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, loc.settingsActionFailed);
      return;
    }
    if (context.mounted) context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);
    final isPro = ref.watch(isProUserProvider);
    final locale = ref.watch(localeProvider);
    final selectedTheme = ref.watch(selectedColorThemeProvider);
    final stored = prefs.profileDisplayName.trim();
    final displayName =
        stored.isEmpty ? loc.v2ProfileDefaultIdentity : stored;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SettingsHomeBody(
          loc: loc,
          displayName: displayName,
          isPro: isPro,
          locale: locale,
          selectedTheme: selectedTheme,
          emotionNotificationsEnabled: prefs.emotionNotificationsEnabled,
          dailyFocusReminderEnabled: prefs.dailyFocusReminderEnabled,
          biometricLockEnabled: ref.watch(biometricLockSettingsProvider),
          appVersion: AppConfig.appVersion,
          onEditDisplayName: () => _editDisplayName(context, ref),
          onOpenPremium: () => context.push(
            isPro
                ? AppRoutes.v2PremiumStatusWithSource('settings')
                : AppRoutes.v2PremiumWithSource('settings'),
          ),
          onSelectLanguage: (next) => _selectLanguage(ref, next),
          onSelectTheme: (theme) async {
            try {
              await ref
                  .read(selectedColorThemeProvider.notifier)
                  .select(theme);
            } catch (_) {}
          },
          onEmotionNotificationsChanged: (v) async {
            try {
              await ref
                  .read(appPreferencesProvider.notifier)
                  .setEmotionNotifications(v);
              await ref
                  .read(smartNotificationServiceProvider)
                  .rescheduleAll();
            } catch (_) {}
          },
          onDailyFocusReminderChanged: (v) async {
            try {
              await ref
                  .read(appPreferencesProvider.notifier)
                  .setDailyFocusReminder(v);
              await ref
                  .read(smartNotificationServiceProvider)
                  .rescheduleAll();
            } catch (_) {}
          },
          onBiometricLockChanged: (enabled) async {
            try {
              final ok = await ref
                  .read(biometricLockSettingsProvider.notifier)
                  .setEnabled(enabled);
              if (!ok && context.mounted) {
                showAppSnackBar(context, loc.settingsBiometricUnavailable);
              }
            } catch (_) {
              if (!context.mounted) return;
              showAppSnackBar(context, loc.settingsBiometricUnavailable);
            }
          },
          onLogout: () => _logout(context, ref),
          onDeleteAccount: () => _deleteAccount(context, ref),
          onOpenPrivacyPolicy: () => _openExternal(
            context,
            externalLinkService.openPrivacyPolicy,
          ),
          onOpenContact: () => _openExternal(
            context,
            externalLinkService.openContactEmail,
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class SettingsHomeBody extends StatelessWidget {
  const SettingsHomeBody({
    super.key,
    required this.loc,
    required this.displayName,
    required this.isPro,
    required this.locale,
    required this.selectedTheme,
    required this.emotionNotificationsEnabled,
    required this.dailyFocusReminderEnabled,
    required this.biometricLockEnabled,
    required this.appVersion,
    required this.onEditDisplayName,
    required this.onOpenPremium,
    required this.onSelectLanguage,
    required this.onSelectTheme,
    required this.onEmotionNotificationsChanged,
    required this.onDailyFocusReminderChanged,
    required this.onBiometricLockChanged,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onOpenPrivacyPolicy,
    required this.onOpenContact,
  });

  final AppLocalizations loc;
  final String displayName;
  final bool isPro;
  final Locale locale;
  final AppColorTheme selectedTheme;
  final bool emotionNotificationsEnabled;
  final bool dailyFocusReminderEnabled;
  final bool biometricLockEnabled;
  final String appVersion;
  final VoidCallback onEditDisplayName;
  final VoidCallback onOpenPremium;
  final ValueChanged<Locale> onSelectLanguage;
  final ValueChanged<AppColorTheme> onSelectTheme;
  final ValueChanged<bool> onEmotionNotificationsChanged;
  final ValueChanged<bool> onDailyFocusReminderChanged;
  final ValueChanged<bool> onBiometricLockChanged;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onOpenPrivacyPolicy;
  final VoidCallback onOpenContact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: V2ShellVisual.pagePadding(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          V2PageHeader(
            title: loc.settingsTitle,
            subtitle: loc.settingsOrientation,
          ),
          const SizedBox(height: _kGapBeforeFirstSection),
          V2SectionLabel(loc.settingsProfileSection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              V2SettingsRow(
                key: settingsProfileIdentityKey,
                title: displayName,
                subtitle: loc.v2ProfileEditNameHint,
                onTap: onEditDisplayName,
                trailing: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
              V2SettingsRow(
                key: settingsProTileKey,
                title: isPro
                    ? loc.settingsProActive
                    : loc.settingsUpgradeToPro,
                subtitle: isPro
                    ? loc.v2PremiumAlreadyActive
                    : loc.v2PremiumFreeStatus,
                onTap: onOpenPremium,
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.settingsNotificationsSection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              V2SettingsSwitchRow(
                title: loc.settingsEmotionNotifications,
                value: emotionNotificationsEnabled,
                onChanged: onEmotionNotificationsChanged,
              ),
              V2SettingsSwitchRow(
                title: loc.settingsDailyFocusReminder,
                value: dailyFocusReminderEnabled,
                onChanged: onDailyFocusReminderChanged,
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.settingsAppearanceSection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              _ThemeChoiceRow(
                theme: AppColorTheme.dark,
                label: loc.colorThemeMorningDark,
                subtitle: loc.settingsThemeDarkSubtitle,
                selected: selectedTheme == AppColorTheme.dark,
                onTap: () => onSelectTheme(AppColorTheme.dark),
              ),
              _ThemeChoiceRow(
                theme: AppColorTheme.light,
                label: loc.colorThemeMorningLight,
                subtitle: loc.settingsThemeLightSubtitle,
                selected: selectedTheme == AppColorTheme.light,
                onTap: () => onSelectTheme(AppColorTheme.light),
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.settingsLanguageSection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              V2SettingsRow(
                key: settingsLanguageArKey,
                title: loc.settingsLanguageArabic,
                showChevron: false,
                onTap: () => onSelectLanguage(const Locale('ar')),
                trailing: _SelectedMark(selected: locale.languageCode == 'ar'),
              ),
              V2SettingsRow(
                key: settingsLanguageEnKey,
                title: loc.settingsLanguageEnglish,
                showChevron: false,
                onTap: () => onSelectLanguage(const Locale('en')),
                trailing: _SelectedMark(selected: locale.languageCode == 'en'),
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.settingsSecuritySection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              V2SettingsSwitchRow(
                title: loc.settingsBiometricLock,
                subtitle: loc.settingsBiometricLockSubtitle,
                value: biometricLockEnabled,
                onChanged: onBiometricLockChanged,
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.settingsAccountSection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              V2SettingsRow(
                key: settingsLogoutKey,
                title: loc.settingsLogout,
                onTap: onLogout,
              ),
              KeyedSubtree(
                key: settingsResetKey,
                child: V2SettingsRow(
                  key: settingsDeleteAccountKey,
                  title: loc.settingsDeleteAccount,
                  subtitle: loc.settingsDeleteAccountConfirmBody,
                  destructive: true,
                  onTap: onDeleteAccount,
                ),
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.settingsAboutSection),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              V2SettingsRow(
                title: loc.settingsVersion,
                subtitle: appVersion,
                showChevron: false,
              ),
              V2SettingsRow(
                key: settingsPrivacyPolicyKey,
                title: loc.settingsPrivacyPolicy,
                subtitle: loc.v2ProfileLegalHint,
                onTap: onOpenPrivacyPolicy,
              ),
              V2SettingsRow(
                key: settingsContactUsKey,
                title: loc.settingsContactUs,
                subtitle: loc.v2ProfileContactHint,
                onTap: onOpenContact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChoiceRow extends StatelessWidget {
  const _ThemeChoiceRow({
    required this.theme,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final AppColorTheme theme;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = theme == AppColorTheme.dark
        ? AppColors.background
        : AppColors.backgroundLight;
    final checkColor = theme == AppColorTheme.dark
        ? AppColors.textPrimary
        : AppColors.textPrimaryLight;
    return V2SettingsRow(
      title: label,
      subtitle: subtitle,
      showChevron: false,
      onTap: onTap,
      trailing: Semantics(
        label: label,
        selected: selected,
        button: true,
        child: Container(
          key: Key('color_theme_swatch_${theme.name}'),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: preview,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: selected
              ? Icon(Icons.check, color: checkColor, size: 20)
              : null,
        ),
      ),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  const _SelectedMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      selected ? Icons.check_circle : Icons.circle_outlined,
      color: selected ? AppColors.primary : AppColors.border,
    );
  }
}
