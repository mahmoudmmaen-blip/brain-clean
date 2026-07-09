import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_level.dart';
import 'package:brain_clean_mobile/features/anxiety/domain/safa_program_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('safaProgramFallbackArabic returns non-empty text per level', () {
    for (final level in AnxietyLevel.values) {
      expect(safaProgramFallbackArabic(level).isNotEmpty, isTrue);
    }
  });

  test('severe fallback mentions specialist', () {
    expect(
      safaProgramFallbackArabic(AnxietyLevel.severe),
      contains('مختص'),
    );
  });
}
