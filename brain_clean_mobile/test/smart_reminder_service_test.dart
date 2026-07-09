import 'package:brain_clean_mobile/features/smart_reminders/domain/app_open_event.dart';
import 'package:brain_clean_mobile/features/smart_reminders/domain/smart_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 9, 12);

  AppOpenEvent eventAt(DateTime openedAt) => AppOpenEvent(
        openedAt: openedAt,
        hourOfDay: openedAt.hour,
      );

  group('SmartReminderService.detectPeakHour', () {
    test('returns null when fewer than 3 events in last 7 days', () {
      final events = [
        eventAt(now.subtract(const Duration(days: 1))),
        eventAt(now.subtract(const Duration(days: 2))),
      ];
      expect(
        SmartReminderService.detectPeakHour(events, now: now),
        isNull,
      );
    });

    test('returns hour when 3+ opens share the same hour', () {
      final events = [
        eventAt(DateTime(2026, 7, 9, 20)),
        eventAt(DateTime(2026, 7, 8, 20, 15)),
        eventAt(DateTime(2026, 7, 7, 20, 30)),
      ];
      expect(
        SmartReminderService.detectPeakHour(events, now: now),
        20,
      );
    });

    test('breaks ties by choosing the earlier hour', () {
      final events = [
        eventAt(DateTime(2026, 7, 9, 10)),
        eventAt(DateTime(2026, 7, 8, 10)),
        eventAt(DateTime(2026, 7, 7, 10)),
        eventAt(DateTime(2026, 7, 9, 14)),
        eventAt(DateTime(2026, 7, 8, 14)),
        eventAt(DateTime(2026, 7, 7, 14)),
      ];
      expect(
        SmartReminderService.detectPeakHour(events, now: now),
        10,
      );
    });

    test('returns null when no hour reaches 3 occurrences', () {
      final events = [
        eventAt(DateTime(2026, 7, 9, 9)),
        eventAt(DateTime(2026, 7, 8, 11)),
        eventAt(DateTime(2026, 7, 7, 13)),
      ];
      expect(
        SmartReminderService.detectPeakHour(events, now: now),
        isNull,
      );
    });
  });

  group('SmartReminderService.shouldSchedule', () {
    test('is true only when detected hour exists', () {
      expect(SmartReminderService.shouldSchedule(null), isFalse);
      expect(SmartReminderService.shouldSchedule(18), isTrue);
    });
  });
}
