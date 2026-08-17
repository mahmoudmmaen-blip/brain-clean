import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/features/focus/data/thinking_log_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late ThinkingLogRepository repo;

  setUp(() {
    box = InMemoryHiveBox();
    repo = ThinkingLogRepository(box);
  });

  group('loadEntries', () {
    test('returns empty list when nothing is stored', () {
      expect(repo.loadEntries(), isEmpty);
    });

    test('stringifies non-string list items', () async {
      await box.put(HiveMetaKeys.thinkingLog, [1, true, 'note']);

      expect(repo.loadEntries(), ['1', 'true', 'note']);
    });

    test('returns empty list when the stored value is not a list', () async {
      await box.put(HiveMetaKeys.thinkingLog, 'corrupt');

      expect(repo.loadEntries(), isEmpty);
    });
  });

  group('appendEntry', () {
    test('appends a timestamped topic|insight row', () async {
      await repo.appendEntry('تركيز', 'insight one');

      final entries = repo.loadEntries();
      expect(entries, hasLength(1));
      final parts = entries.single.split('|');
      expect(parts, hasLength(3));
      expect(DateTime.tryParse(parts[0]), isNotNull);
      expect(parts[1], 'تركيز');
      expect(parts[2], 'insight one');
    });

    test('trims the insight and preserves previous entries', () async {
      await repo.appendEntry('a', 'first');
      await repo.appendEntry('b', '  second  ');

      final entries = repo.loadEntries();
      expect(entries, hasLength(2));
      expect(entries.first, endsWith('|a|first'));
      expect(entries.last, endsWith('|b|second'));
    });

    test('ignores blank insights', () async {
      await repo.appendEntry('a', '   ');

      expect(repo.loadEntries(), isEmpty);
    });
  });
}
