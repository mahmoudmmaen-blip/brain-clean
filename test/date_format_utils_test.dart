import 'package:brain_clean_mobile/core/utils/date_format_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatUtils.dayKey', () {
    test('zero-pads month and day', () {
      expect(DateFormatUtils.dayKey(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('utcDayKey converts before formatting', () {
      final local = DateTime.utc(2026, 3, 7, 23, 30).toLocal();
      expect(DateFormatUtils.utcDayKey(local), '2026-03-07');
    });
  });

  group('DateFormatUtils.countdown', () {
    test('formats mm:ss with padded minutes', () {
      expect(DateFormatUtils.countdown(0), '00:00');
      expect(DateFormatUtils.countdown(65), '01:05');
      expect(DateFormatUtils.countdown(3599), '59:59');
      expect(DateFormatUtils.countdown(3600), '60:00');
    });

    test('omits minute padding when requested', () {
      expect(DateFormatUtils.countdown(65, padMinutes: false), '1:05');
    });

    test('clamps negative input', () {
      expect(DateFormatUtils.countdown(-10), '00:00');
    });
  });
}
