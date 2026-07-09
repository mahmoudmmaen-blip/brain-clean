import '../domain/app_open_event.dart';
import '../domain/smart_reminder_config.dart';

abstract interface class SmartReminderRepository {
  Future<void> logAppOpen();

  Future<List<AppOpenEvent>> getRecentEvents();

  Future<void> saveConfig(SmartReminderConfig config);

  Future<SmartReminderConfig> getConfig();
}
