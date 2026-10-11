import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/hive_meta_keys.dart';
import '../../core/data/app_meta_box_provider.dart';
import '../../core/services/app_notification_service.dart';

const twentyTwentyPayload = 'twenty_twenty';
const _notificationIdBase = 202020;

class TwentyTwentySettings {
  const TwentyTwentySettings({
    this.enabled = false,
    this.startHour = 9,
    this.endHour = 18,
  });

  final bool enabled;
  final int startHour;
  final int endHour;

  TwentyTwentySettings copyWith({
    bool? enabled,
    int? startHour,
    int? endHour,
  }) {
    return TwentyTwentySettings(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }
}

class TwentyTwentyController extends StateNotifier<TwentyTwentySettings> {
  TwentyTwentyController(this._ref) : super(const TwentyTwentySettings()) {
    _hydrate();
  }

  final Ref _ref;

  Box<dynamic> get _box => _ref.read(appMetaBoxProvider);

  void _hydrate() {
    try {
      final enabled =
          _box.get(HiveMetaKeys.twentyTwentyEnabled, defaultValue: false)
              as bool;
      final start =
          _box.get(HiveMetaKeys.twentyTwentyStartHour, defaultValue: 9) as int;
      final end =
          _box.get(HiveMetaKeys.twentyTwentyEndHour, defaultValue: 18) as int;
      state = TwentyTwentySettings(
        enabled: enabled,
        startHour: start.clamp(0, 23),
        endHour: end.clamp(0, 23),
      );
    } catch (_) {
      state = const TwentyTwentySettings();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _box.put(HiveMetaKeys.twentyTwentyEnabled, enabled);
    await reschedule();
  }

  Future<void> setHours({required int startHour, required int endHour}) async {
    state = state.copyWith(startHour: startHour, endHour: endHour);
    await _box.put(HiveMetaKeys.twentyTwentyStartHour, startHour);
    await _box.put(HiveMetaKeys.twentyTwentyEndHour, endHour);
    await reschedule();
  }

  Future<void> reschedule() async {
    final notifications = _ref.read(appNotificationServiceProvider);
    await notifications.cancelIds(
      List.generate(48, (i) => _notificationIdBase + i),
    );
    if (!state.enabled) return;
    if (state.endHour <= state.startHour) return;

    await notifications.initialize();
    final now = tz.TZDateTime.now(tz.local);
    var slot = 0;
    for (var hour = state.startHour; hour < state.endHour; hour++) {
      for (final minute in [0, 20, 40]) {
        if (slot >= 48) return;
        var when = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (when.isBefore(now)) {
          when = when.add(const Duration(days: 1));
        }
        await notifications.scheduleZoned(
          id: _notificationIdBase + slot,
          when: when,
          title: '20-20-20',
          body: 'Look 20 feet away for 20 seconds',
          payload: twentyTwentyPayload,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        slot++;
      }
    }
  }
}

final twentyTwentyControllerProvider =
    StateNotifierProvider<TwentyTwentyController, TwentyTwentySettings>((ref) {
  return TwentyTwentyController(ref);
});
