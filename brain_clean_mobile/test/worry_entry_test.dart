import 'package:brain_clean_mobile/features/worry/domain/worry_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('worryEntryIsToday uses local calendar day', () {
    final now = DateTime(2026, 7, 9, 23, 30);
    final entry = WorryEntry(
      id: '1',
      content: 'test',
      createdAt: DateTime.utc(2026, 7, 9, 20),
    );
    expect(worryEntryIsToday(entry, now), isTrue);

    final yesterday = WorryEntry(
      id: '2',
      content: 'old',
      createdAt: DateTime.utc(2026, 7, 8, 12),
    );
    expect(worryEntryIsToday(yesterday, now), isFalse);
  });
}
