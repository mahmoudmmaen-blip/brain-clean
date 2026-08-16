import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/security/security_status_provider.dart';
import '../../core/services/external_link_service.dart';
import '../../core/services/smart_notification_service.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/theme/app_color_theme.dart';
import '../../core/theme/app_color_theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../pro/application/subscription_service_provider.dart';

const settingsProTileKey = Key('settings_pro_tile');
const settingsResetKey = Key('settings_reset_data');
const settingsPrivacyPolicyKey = Key('settings_privacy_policy');
const settingsContactUsKey = Key('settings_contact_us');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(loc.settingsResetDataConfirmTitle,
            style: const TextStyle(color: Color(0xFFE6EDF3))),
        content: Text(loc.settingsResetDataConfirmBody,
            style: const TextStyle(color: Color(0xFF8B949E))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.commonConfirm,
                style: const TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    for (final name in [
      HiveBoxes.recoveryProtocol,
      HiveBoxes.diagnosticPersistence,
      HiveBoxes.emotionLog,
      HiveBoxes.dailySnapshots,
      HiveBoxes.appMeta,
    ]) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).clear();
      }
    }
    ref.invalidate(appPreferencesProvider);
    if (context.mounted) context.go(AppRoutes.splash);
  }

  Future<void> _openExternal(
    BuildContext context,
    Future<bool> Function() open,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await open();
    if (!context.mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.settingsLinkUnavailable)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);
    final isPro = ref.watch(isProUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(loc.settingsTitle,
            style: const TextStyle(color: Color(0xFFE6EDF3))),
        iconTheme: const IconThemeData(color: Color(0xFF8B949E)),
      ),
      body: ListView(
        children: [
          _SectionHeader(loc.settingsAccountSection),
          ListTile(
            key: settingsProTileKey,
            title: Text(
              isPro ? loc.settingsProActive : loc.settingsUpgradeToPro,
              style: TextStyle(
                color:
                    isPro ? const Color(0xFF1D9E75) : const Color(0xFFE6EDF3),
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: isPro
                ? null
                : Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: const Color(0xFF8B949E),
                  ),
            onTap: () => context.push(
              isPro
                  ? AppRoutes.v2PremiumStatusWithSource('settings')
                  : AppRoutes.v2PremiumWithSource('settings'),
            ),
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsAppearanceSection),
          const _ColorThemeSection(),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsNotificationsSection),
          SwitchListTile(
            title: Text(loc.settingsEmotionNotifications,
                style: const TextStyle(color: Color(0xFFE6EDF3))),
            value: prefs.emotionNotificationsEnabled,
            activeThumbColor: const Color(0xFF1D9E75),
            onChanged: (v) async {
              await ref
                  .read(appPreferencesProvider.notifier)
                  .setEmotionNotifications(v);
              await ref.read(smartNotificationServiceProvider).rescheduleAll();
            },
          ),
          SwitchListTile(
            title: Text(loc.settingsDailyFocusReminder,
                style: const TextStyle(color: Color(0xFFE6EDF3))),
            value: prefs.dailyFocusReminderEnabled,
            activeThumbColor: const Color(0xFF1D9E75),
            onChanged: (v) async {
              await ref
                  .read(appPreferencesProvider.notifier)
                  .setDailyFocusReminder(v);
              await ref.read(smartNotificationServiceProvider).rescheduleAll();
            },
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsSecuritySection),
          SwitchListTile(
            title: Text(loc.settingsBiometricLock,
                style: const TextStyle(color: Color(0xFFE6EDF3))),
            subtitle: Text(loc.settingsBiometricLockSubtitle,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
            value: ref.watch(biometricLockSettingsProvider),
            activeThumbColor: const Color(0xFF1D9E75),
            onChanged: (enabled) async {
              final ok = await ref
                  .read(biometricLockSettingsProvider.notifier)
                  .setEnabled(enabled);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.settingsBiometricUnavailable)),
                );
              }
            },
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsDataSection),
          ListTile(
            key: settingsResetKey,
            title: Text(loc.settingsResetData,
                style: const TextStyle(color: Color(0xFFEF4444))),
            subtitle: Text(
              loc.settingsResetDataConfirmBody,
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
            ),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsAboutSection),
          ListTile(
            title: Text(loc.settingsVersion,
                style: const TextStyle(color: Color(0xFFE6EDF3))),
            trailing: Text(
              AppConfig.appVersion,
              style: const TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
          ListTile(
            key: settingsPrivacyPolicyKey,
            title: Text(loc.settingsPrivacyPolicy,
                style: const TextStyle(color: Color(0xFFE6EDF3))),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: const Color(0xFF8B949E),
            ),
            onTap: () => _openExternal(
              context,
              externalLinkService.openPrivacyPolicy,
            ),
          ),
          ListTile(
            key: settingsContactUsKey,
            title: Text(loc.settingsContactUs,
                style: const TextStyle(color: Color(0xFFE6EDF3))),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: const Color(0xFF8B949E),
            ),
            onTap: () => _openExternal(
              context,
              externalLinkService.openContactEmail,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(label,
          style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }
}

String _colorThemeName(AppLocalizations loc, AppColorTheme theme) {
  // Temporary reuse of existing l10n keys (Midnight ≈ Dark, Daylight ≈ Light).
  // Prefer dedicated keys e.g. colorThemeMorningDark / colorThemeMorningLight later.
  return switch (theme) {
    AppColorTheme.dark => loc.colorThemeMidnightName,
    AppColorTheme.light => loc.colorThemeDaylightName,
  };
}

class _ColorThemeSection extends ConsumerWidget {
  const _ColorThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedColorThemeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        children: AppColorTheme.values.map((themeDef) {
          return _ColorThemeSwatch(
            key: Key('color_theme_swatch_${themeDef.name}'),
            theme: themeDef,
            label: _colorThemeName(loc, themeDef),
            selected: themeDef == selected,
            onTap: () {
              ref.read(selectedColorThemeProvider.notifier).select(themeDef);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ColorThemeSwatch extends StatelessWidget {
  const _ColorThemeSwatch({
    super.key,
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppColorTheme theme;
  final String label;
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
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
