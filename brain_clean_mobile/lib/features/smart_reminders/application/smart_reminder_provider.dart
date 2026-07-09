import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/smart_reminder_notification_scheduler.dart';
import '../data/smart_reminder_repository_provider.dart';
import '../domain/smart_reminder_config.dart';
import '../domain/smart_reminder_service.dart';

part 'smart_reminder_provider.g.dart';

@Riverpod(keepAlive: true)
class SmartReminder extends _$SmartReminder {
  @override
  Future<SmartReminderConfig> build() async {
    return ref.read(smartReminderRepositoryProvider).getConfig();
  }

  Future<void> analyzeAndSchedule() async {
    try {
      final repo = ref.read(smartReminderRepositoryProvider);
      final events = await repo.getRecentEvents();
      final config = state.valueOrNull ?? await repo.getConfig();
      final detectedHour = SmartReminderService.detectPeakHour(events);

      final scheduler = ref.read(smartReminderNotificationSchedulerProvider);

      if (!config.isEnabled) {
        await scheduler.cancel();
        return;
      }

      if (detectedHour == null) {
        final updated = config.copyWith(
          detectedHour: null,
          lastUpdated: DateTime.now(),
        );
        await repo.saveConfig(updated);
        state = AsyncData(updated);
        await scheduler.cancel();
        return;
      }

      final updated = config.copyWith(
        detectedHour: detectedHour,
        lastUpdated: DateTime.now(),
      );
      await repo.saveConfig(updated);
      state = AsyncData(updated);

      if (SmartReminderService.shouldSchedule(detectedHour)) {
        await scheduler.scheduleAtHour(detectedHour);
      }
    } catch (_) {
      // Never crash startup flows.
    }
  }

  Future<void> toggleEnabled(bool enabled) async {
    try {
      final repo = ref.read(smartReminderRepositoryProvider);
      final current = state.valueOrNull ?? await repo.getConfig();
      final updated = current.copyWith(
        isEnabled: enabled,
        lastUpdated: DateTime.now(),
      );
      await repo.saveConfig(updated);
      state = AsyncData(updated);

      final scheduler = ref.read(smartReminderNotificationSchedulerProvider);
      if (!enabled) {
        await scheduler.cancel();
        return;
      }

      final hour = updated.detectedHour;
      if (hour != null && SmartReminderService.shouldSchedule(hour)) {
        await scheduler.scheduleAtHour(hour);
      } else {
        await analyzeAndSchedule();
      }
    } catch (_) {}
  }
}
