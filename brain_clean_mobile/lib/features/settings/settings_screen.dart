import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/security/security_status_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/notifications_service.dart';
import '../../core/services/smart_notification_service.dart';
import '../../core/services/weekly_report_service.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/theme/app_color_theme.dart';
import '../../core/theme/app_color_theme_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../pro/application/subscription_service_provider.dart';

const settingsProTileKey = Key('settings_pro_tile');
const settingsResetKey = Key('settings_reset_data');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            loc.settingsResetDataConfirmTitle,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Text(
            loc.settingsResetDataConfirmBody,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(loc.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                loc.commonConfirm,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);
    final isPro = ref.watch(isProUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(loc.settingsAccountSection),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  key: settingsProTileKey,
                  title: Text(
                    isPro ? loc.settingsProActive : loc.settingsUpgradeToPro,
                    style: TextStyle(
                      color: isPro ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: isPro
                      ? null
                      : Icon(
                          Icons.chevron_left,
                          color: colorScheme.onSurfaceVariant,
                        ),
                  onTap: isPro ? null : () => context.push(AppRoutes.proPaywall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(loc.settingsAppearanceSection),
                const _ColorThemeSection(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsBiometricLock,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    loc.settingsBiometricLockSubtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  value: ref.watch(biometricLockSettingsProvider),
                  activeThumbColor: colorScheme.primary,
                  onChanged: (enabled) async {
                    final ok = await ref
                        .read(biometricLockSettingsProvider.notifier)
                        .setEnabled(enabled);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.settingsBiometricUnavailable),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(loc.settingsNotificationsSection),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsEmotionNotifications,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  value: prefs.emotionNotificationsEnabled,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (v) async {
                    await ref
                        .read(appPreferencesProvider.notifier)
                        .setEmotionNotifications(v);
                    await ref.read(smartNotificationServiceProvider).rescheduleAll();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsDailyFocusReminder,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  value: prefs.dailyFocusReminderEnabled,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (v) async {
                    await ref
                        .read(appPreferencesProvider.notifier)
                        .setDailyFocusReminder(v);
                    await ref.read(smartNotificationServiceProvider).rescheduleAll();
                  },
                ),
                const _DailyReminderTile(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(loc.settingsSubscriptionSection),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    isPro ? loc.settingsProActive : loc.settingsUpgradeToPro,
                    style: TextStyle(
                      color: isPro
                          ? const Color(0xFFFBBF24)
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isPro ? loc.proPriceHint : loc.proPriceMonthly,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: isPro
                      ? Icon(Icons.verified, color: const Color(0xFFFBBF24))
                      : Icon(
                          Icons.chevron_left,
                          color: colorScheme.onSurfaceVariant,
                        ),
                  onTap: isPro ? null : () => context.push(AppRoutes.proPaywall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(loc.settingsDataSection),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  key: settingsResetKey,
                  title: Text(
                    loc.settingsResetData,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () => _confirmReset(context, ref),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsExportData,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.settingsComingSoon)),
                    );
                  },
                ),
                _SectionHeader(loc.settingsAboutSection),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsVersion,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsPrivacyPolicy,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.settingsContactUs,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyReminderTile extends ConsumerStatefulWidget {
  const _DailyReminderTile();

  @override
  ConsumerState<_DailyReminderTile> createState() => _DailyReminderTileState();
}

class _DailyReminderTileState extends ConsumerState<_DailyReminderTile> {
  final _service = NotificationsService();
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _service.isDailyReminderEnabled();
    if (mounted) setState(() => _enabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_enabled == null) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          loc.settingsDailyReminder,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        subtitle: Text(
          loc.settingsDailyReminderSub,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        value: true,
        onChanged: null,
      );
    }

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        loc.settingsDailyReminder,
        style: TextStyle(color: colorScheme.onSurface),
      ),
      subtitle: Text(
        loc.settingsDailyReminderSub,
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
      ),
      value: _enabled!,
      activeThumbColor: colorScheme.primary,
      onChanged: (enabled) async {
        final locale = Localizations.localeOf(context);
        setState(() => _enabled = enabled);
        await _service.setDailyReminderEnabled(enabled);
        if (enabled) {
          await _service.scheduleDailyReminder(
            title: loc.notifDailyTitle,
            body: loc.notifDailyBody,
            locale: locale,
          );
        } else {
          await _service.cancelAll();
          try {
            await ref.read(smartNotificationServiceProvider).rescheduleAll();
            await ref.read(weeklyReportServiceProvider).schedule();
          } catch (_) {}
        }
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _colorThemeName(AppLocalizations loc, AppColorTheme theme) {
  return switch (theme) {
    AppColorTheme.midnight => loc.colorThemeMidnightName,
    AppColorTheme.aurora => loc.colorThemeAuroraName,
    AppColorTheme.pine => loc.colorThemePineName,
    AppColorTheme.solar => loc.colorThemeSolarName,
    AppColorTheme.slate => loc.colorThemeSlateName,
    AppColorTheme.daylight => loc.colorThemeDaylightName,
  };
}

class _ColorThemeSection extends ConsumerWidget {
  const _ColorThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedColorThemeProvider);
    final isPro = ref.watch(isProUserProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        children: AppColorTheme.values.map((themeDef) {
          final locked = themeDef.isPro && !isPro;
          return _ColorThemeSwatch(
            key: Key('color_theme_swatch_${themeDef.name}'),
            theme: themeDef,
            label: _colorThemeName(loc, themeDef),
            locked: locked,
            selected: themeDef == selected,
            onTap: () {
              if (locked) {
                context.push(AppRoutes.proPaywall);
              } else {
                ref
                    .read(selectedColorThemeProvider.notifier)
                    .select(themeDef);
              }
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
    required this.locked,
    required this.selected,
    required this.onTap,
  });

  final AppColorTheme theme;
  final String label;
  final bool locked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? colorScheme.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check, color: colorScheme.onPrimary, size: 20)
                      : null,
                ),
                if (locked)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
