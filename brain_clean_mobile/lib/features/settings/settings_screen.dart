import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/smart_notification_service.dart';
import '../../core/storage/hive_boxes.dart';

const settingsProTileKey = Key('settings_pro_tile');
const settingsResetKey = Key('settings_reset_data');

/// App settings — account, notifications, data, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          loc.settingsResetDataConfirmTitle,
          style: const TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: Text(
          loc.settingsResetDataConfirmBody,
          style: const TextStyle(color: Color(0xFF8B949E)),
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
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(
          loc.settingsTitle,
          style: const TextStyle(color: Color(0xFFE6EDF3)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B949E)),
      ),
      body: ListView(
        children: [
          _SectionHeader(loc.settingsAccountSection),
          ListTile(
            key: settingsProTileKey,
            title: Text(
              prefs.isProUser ? loc.settingsProActive : loc.settingsUpgradeToPro,
              style: TextStyle(
                color: prefs.isProUser
                    ? const Color(0xFF1D9E75)
                    : const Color(0xFFE6EDF3),
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: prefs.isProUser
                ? null
                : const Icon(Icons.chevron_left, color: Color(0xFF8B949E)),
            onTap: prefs.isProUser
                ? null
                : () => context.push(AppRoutes.proPaywall),
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsNotificationsSection),
          SwitchListTile(
            title: Text(
              loc.settingsEmotionNotifications,
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
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
            title: Text(
              loc.settingsDailyFocusReminder,
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
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
          _SectionHeader(loc.settingsDataSection),
          ListTile(
            key: settingsResetKey,
            title: Text(
              loc.settingsResetData,
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
            onTap: () => _confirmReset(context, ref),
          ),
          ListTile(
            title: Text(
              loc.settingsExportData,
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.settingsComingSoon)),
              );
            },
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader(loc.settingsAboutSection),
          ListTile(
            title: Text(
              loc.settingsVersion,
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
          ListTile(
            title: Text(
              loc.settingsPrivacyPolicy,
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              loc.settingsContactUs,
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
            onTap: () {},
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
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
