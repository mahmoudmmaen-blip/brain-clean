import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/hive_meta_keys.dart';
import '../../features/home/application/streak_freeze_provider.dart';
import '../../core/services/app_notification_service.dart';
import '../../core/data/app_meta_box_provider.dart';
import '../../core/services/cloud_sync_service.dart';
import '../../features/dashboard/application/habit_state_provider.dart';
import '../../features/dashboard/data/daily_snapshots_repository.dart';
import '../../features/dashboard/domain/daily_snapshot.dart';
import '../../features/diagnostic/presentation/bc_score_provider.dart';

/// Runs once per calendar day on app resume — snapshots BCS and resets habits.
class MidnightResetService with WidgetsBindingObserver {
  MidnightResetService({
    required T Function<T>(ProviderListenable<T> provider) read,
  }) : _read = read;

  MidnightResetService.fromContainer(ProviderContainer container)
      : _read = container.read;

  final T Function<T>(ProviderListenable<T> provider) _read;

  static DateTime todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> triggerResetIfNeeded() async {
    try {
      final meta = _read(appMetaBoxProvider);
      final today = todayDateOnly();
      final lastRaw = meta.get(HiveMetaKeys.lastResetDate) as String?;
      if (lastRaw == formatDate(today)) return;

      final session = _read(bcScoreSessionProvider);
      final bcsValue = session?.bcScore ?? 0;
      final yesterday = today.subtract(const Duration(days: 1));
      final snapshot = DailySnapshot(date: yesterday, bcsValue: bcsValue);

      try {
        await _read(dailySnapshotsRepositoryProvider).save(snapshot);
        await _read(cloudSyncServiceProvider).syncDailySnapshot(snapshot);
      } catch (_) {
        // Local save is best-effort; continue reset flow.
      }

      _read(habitStateProvider.notifier).resetAll();

      final freeze = _read(streakFreezeControllerProvider);
      if (freeze.isFrozen) {
        await _read(streakFreezeControllerProvider.notifier).consumeFrozenDay();
        try {
          final isArabic = (_read(appMetaBoxProvider)
                  .get(HiveMetaKeys.locale, defaultValue: 'ar') as String) ==
              'ar';
          await _read(appNotificationServiceProvider).showSimple(
            id: 6001,
            title: isArabic ? 'تجميد Streak ❄️' : 'Streak Freeze ❄️',
            body: isArabic
                ? 'تم استخدام تجميد الـ Streak ❄️'
                : 'Streak freeze used ❄️',
          );
        } catch (_) {}
      }

      if (today.weekday == DateTime.monday) {
        await _read(streakFreezeControllerProvider.notifier)
            .resetWeeklyAllowance();
      }

      await meta.put(HiveMetaKeys.lastResetDate, formatDate(today));
    } catch (_) {
      // Hive boxes may be unavailable in tests or during cold start races.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      triggerResetIfNeeded();
    }
  }
}
