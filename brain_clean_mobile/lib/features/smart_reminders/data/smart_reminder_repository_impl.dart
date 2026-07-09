import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/app_open_event.dart';
import '../domain/smart_reminder_config.dart';
import '../domain/smart_reminder_repository.dart';

class SmartReminderRepositoryImpl implements SmartReminderRepository {
  SmartReminderRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _eventsKey = 'app_open_events';
  static const _configKey = 'smart_reminder_config';
  static const _maxEvents = 30;

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.smartReminders);
  }

  List<AppOpenEvent> _parseEvents(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => AppOpenEvent.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> logAppOpen() async {
    try {
      final box = await _openBox();
      final now = DateTime.now();
      final events = _parseEvents(box.get(_eventsKey));
      events.add(
        AppOpenEvent(openedAt: now, hourOfDay: now.hour),
      );
      if (events.length > _maxEvents) {
        events.removeRange(0, events.length - _maxEvents);
      }
      await box.put(
        _eventsKey,
        events.map((event) => event.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('SmartReminderRepositoryImpl: logAppOpen failed: $e');
    }
  }

  @override
  Future<List<AppOpenEvent>> getRecentEvents() async {
    try {
      final box = await _openBox();
      return _parseEvents(box.get(_eventsKey));
    } catch (e) {
      debugPrint('SmartReminderRepositoryImpl: getRecentEvents failed: $e');
      return [];
    }
  }

  @override
  Future<void> saveConfig(SmartReminderConfig config) async {
    try {
      final box = await _openBox();
      await box.put(_configKey, config.toJson());
    } catch (e) {
      debugPrint('SmartReminderRepositoryImpl: saveConfig failed: $e');
    }
  }

  @override
  Future<SmartReminderConfig> getConfig() async {
    try {
      final box = await _openBox();
      final raw = box.get(_configKey);
      if (raw is Map) {
        return SmartReminderConfig.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (e) {
      debugPrint('SmartReminderRepositoryImpl: getConfig failed: $e');
    }
    return const SmartReminderConfig();
  }
}
