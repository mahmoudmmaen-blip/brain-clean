import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_dominant_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('detectDominantAnxietyType', () {
    test('defaults to rumination when no type qualifies', () {
      expect(
        detectDominantAnxietyType(const [0, 0, 0, 0, 0, 0, 0, 0]),
        AnxietyDominantType.rumination,
      );
    });

    test('detects night worry when Q1 is high', () {
      expect(
        detectDominantAnxietyType(const [3, 0, 0, 0, 0, 0, 0, 0]),
        AnxietyDominantType.nightWorry,
      );
    });

    test('detects rumination when Q2+Q4 average is highest', () {
      expect(
        detectDominantAnxietyType(const [2, 3, 0, 3, 0, 0, 0, 0]),
        AnxietyDominantType.rumination,
      );
    });

    test('detects catastrophizing when Q3 dominates', () {
      expect(
        detectDominantAnxietyType(const [2, 0, 3, 0, 0, 0, 0, 0]),
        AnxietyDominantType.catastrophizing,
      );
    });

    test('detects physical when Q6 dominates', () {
      expect(
        detectDominantAnxietyType(const [2, 0, 0, 0, 0, 3, 0, 0]),
        AnxietyDominantType.physical,
      );
    });
  });
}
