import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/hive_boxes.dart';

const settingsProTileKey = Key('settings_pro_tile');
const settingsResetKey = Key('settings_reset_data');

/// App settings — account, notifications, data, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'إعادة تعيين البيانات',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: const Text(
          'سيتم حذف جميع بياناتك المحلية. هل أنت متأكد؟',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Color(0xFFEF4444)),
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
    final prefs = ref.watch(appPreferencesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text(
          'الإعدادات',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B949E)),
      ),
      body: ListView(
        children: [
          _SectionHeader('الحساب'),
          ListTile(
            key: settingsProTileKey,
            title: Text(
              prefs.isProUser ? 'Brain Clean Pro ✓' : 'ترقية إلى Pro',
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
          _SectionHeader('الإشعارات'),
          SwitchListTile(
            title: const Text(
              'تنبيهات الأحاسيس السلبية',
              style: TextStyle(color: Color(0xFFE6EDF3)),
            ),
            value: prefs.emotionNotificationsEnabled,
            activeThumbColor: const Color(0xFF1D9E75),
            onChanged: (v) => ref
                .read(appPreferencesProvider.notifier)
                .setEmotionNotifications(v),
          ),
          SwitchListTile(
            title: const Text(
              'تذكير يومي بالتركيز',
              style: TextStyle(color: Color(0xFFE6EDF3)),
            ),
            value: prefs.dailyFocusReminderEnabled,
            activeThumbColor: const Color(0xFF1D9E75),
            onChanged: (v) => ref
                .read(appPreferencesProvider.notifier)
                .setDailyFocusReminder(v),
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader('البيانات'),
          ListTile(
            key: settingsResetKey,
            title: const Text(
              'إعادة تعيين البيانات',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
            onTap: () => _confirmReset(context, ref),
          ),
          ListTile(
            title: const Text(
              'تصدير بياناتي',
              style: TextStyle(color: Color(0xFFE6EDF3)),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً...')),
              );
            },
          ),
          const Divider(color: Color(0xFF30363D)),
          _SectionHeader('حول التطبيق'),
          const ListTile(
            title: Text('الإصدار', style: TextStyle(color: Color(0xFFE6EDF3))),
            trailing: Text('1.0.0', style: TextStyle(color: Color(0xFF8B949E))),
          ),
          ListTile(
            title: const Text(
              'سياسة الخصوصية',
              style: TextStyle(color: Color(0xFFE6EDF3)),
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text(
              'تواصل معنا',
              style: TextStyle(color: Color(0xFFE6EDF3)),
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
