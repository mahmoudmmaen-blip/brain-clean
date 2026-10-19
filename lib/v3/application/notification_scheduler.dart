import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/l10n/app_localizations.dart';
import '../../core/services/app_notification_service.dart';
import '../domain/notification_plan.dart';
import '../domain/program_engine.dart';
import 'v3_state_providers.dart';

const clarityRecheckPayload = 'clarity_recheck';

const _dailyId = 8101;
const _eveningId = 8102;
const _clarityId = 8103;

/// Schedules V3 daily / evening / clarity notifications (max 2/day).
class V3NotificationScheduler {
  V3NotificationScheduler(this._ref);

  final Ref _ref;

  AppNotificationService get _notifications =>
      _ref.read(appNotificationServiceProvider);

  Future<void> reschedule({
    required AppLocalizations loc,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    await _notifications.cancelIds(const [_dailyId, _eveningId, _clarityId]);

    try {
      final app = await _ref.read(v3StateRepositoryProvider).load();
      final profile = app.profile;
      if (profile == null || !profile.onboardingDone) return;

      final reminder = _parseHm(profile.reminderTime);
      final current = ProgramEngine.currentDay(app.dayProgress);
      final finished = ProgramEngine.isProgramFinished(app.dayProgress);
      final todayProgress = app.progressForDay(current);
      final todayDone = todayProgress != null &&
          ProgramEngine.isDayCompleted(todayProgress);
      final eveningDone = app.eveningCheckIns.any(
        (e) => e.date == WesternDateKey.of(clock),
      );
      final clarityDone = app.clarityResults.any((r) => r.programDay == current);
      final isClarity = V3NotificationPlan.isClarityRecheckDay(current);

      final plan = V3NotificationPlan.build(
        now: clock,
        currentDay: current,
        programFinished: finished,
        todayDone: todayDone,
        eveningEnabled: profile.eveningCheckIn,
        eveningDoneToday: eveningDone,
        isClarityRecheckDay: isClarity,
        clarityDoneForCurrentDay: clarityDone,
        reminderHour: reminder.$1,
        reminderMinute: reminder.$2,
      );

      for (final item in plan) {
        final when = _nextOccurrence(clock, item.hour, item.minute);
        final copy = _copy(loc, item);
        await _notifications.scheduleZoned(
          id: _idFor(item.kind),
          when: when,
          title: copy.$1,
          body: copy.$2,
          payload: _payloadFor(item.kind),
        );
      }
    } catch (e, st) {
      debugPrint('V3NotificationScheduler.reschedule failed: $e\n$st');
    }
  }

  static (int, int) _parseHm(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 20;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return (h.clamp(0, 23), m.clamp(0, 59));
  }

  static tz.TZDateTime _nextOccurrence(DateTime now, int hour, int minute) {
    final local = tz.local;
    var when = tz.TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final nowTz = tz.TZDateTime.from(now, local);
    if (!when.isAfter(nowTz)) {
      when = when.add(const Duration(days: 1));
    }
    return when;
  }

  static int _idFor(V3NotificationKind kind) => switch (kind) {
        V3NotificationKind.dailyReminder => _dailyId,
        V3NotificationKind.eveningCheckIn => _eveningId,
        V3NotificationKind.clarityRecheck => _clarityId,
      };

  static String _payloadFor(V3NotificationKind kind) => switch (kind) {
        V3NotificationKind.dailyReminder => dailyReminderPayload,
        V3NotificationKind.eveningCheckIn => eveningCheckInPayload,
        V3NotificationKind.clarityRecheck => clarityRecheckPayload,
      };

  static (String, String) _copy(AppLocalizations loc, V3PlannedNotification n) {
    return switch (n.kind) {
      V3NotificationKind.dailyReminder => (
          loc.v3NotifDailyTitle,
          loc.v3NotifDailyBody(n.dayNumber),
        ),
      V3NotificationKind.eveningCheckIn => (
          loc.v3NotifEveningTitle,
          loc.v3NotifEveningBody,
        ),
      V3NotificationKind.clarityRecheck => (
          loc.v3NotifClarityTitle,
          loc.v3NotifClarityBody,
        ),
    };
  }
}

/// Local `yyyy-MM-dd` for evening check-in matching.
abstract final class WesternDateKey {
  static String of(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

final v3NotificationSchedulerProvider = Provider<V3NotificationScheduler>(
  (ref) => V3NotificationScheduler(ref),
);

/// Convenience: reschedule after day progress changes.
Future<void> rescheduleV3Notifications(
  WidgetRef ref,
  AppLocalizations loc,
) {
  return ref.read(v3NotificationSchedulerProvider).reschedule(loc: loc);
}
