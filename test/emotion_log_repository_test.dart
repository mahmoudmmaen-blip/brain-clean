import 'package:brain_clean_mobile/features/emotions/data/emotion_log_repository.dart';
import 'package:brain_clean_mobile/features/emotions/domain/emotion_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

const _sadness = EmotionModel(
  category: EmotionCategory.sadness,
  label: 'حزن',
  intensity: 1,
  recoveryImpact: -0.08,
);

const _joy = EmotionModel(
  category: EmotionCategory.joy,
  label: 'فرح',
  intensity: 3,
  recoveryImpact: 0.10,
);

void main() {
  late InMemoryHiveBox box;
  late EmotionLogRepository repo;

  setUp(() {
    box = InMemoryHiveBox();
    repo = EmotionLogRepository(box);
  });

  test('append stores the entry keyed by epoch millis', () async {
    final timestamp = DateTime.utc(2026, 5, 1, 8);
    await repo.append(
      emotion: _sadness,
      appliedImpact: -0.08,
      timestamp: timestamp,
    );

    expect(box.keys, [timestamp.millisecondsSinceEpoch.toString()]);
    final stored = box.get(timestamp.millisecondsSinceEpoch.toString()) as Map;
    expect(stored['label'], 'حزن');
    expect(stored['category'], EmotionCategory.sadness.name);
    expect(stored['intensity'], 1);
    expect(stored['appliedImpact'], -0.08);
    expect(stored['timestamp'], timestamp.toIso8601String());
    expect(repo.count, 1);
  });

  test('recentEntries returns newest first', () async {
    await repo.append(
      emotion: _sadness,
      appliedImpact: -0.08,
      timestamp: DateTime.utc(2026, 5, 1),
    );
    await repo.append(
      emotion: _joy,
      appliedImpact: 0.10,
      timestamp: DateTime.utc(2026, 5, 3),
    );

    final entries = repo.recentEntries();

    expect(entries.map((e) => e.label), ['فرح', 'حزن']);
    expect(entries.first.recoveryImpact, 0.10);
    expect(entries.first.category, EmotionCategory.joy.name);
  });

  test('recentEntries honours the limit', () async {
    for (var day = 1; day <= 7; day++) {
      await repo.append(
        emotion: _joy,
        appliedImpact: 0.10,
        timestamp: DateTime.utc(2026, 5, day),
      );
    }

    expect(repo.recentEntries(limit: 3), hasLength(3));
    expect(repo.recentEntries(limit: 3).first.timestamp, DateTime.utc(2026, 5, 7));
    expect(repo.recentEntries(limit: 20), hasLength(7));
  });

  test('malformed rows are skipped without throwing', () async {
    await box.put('not-a-map', 'garbage');
    await box.put('missing-label', {
      'category': 'joy',
      'timestamp': DateTime.utc(2026, 5, 2).toIso8601String(),
    });
    await box.put('missing-timestamp', {'label': 'فرح', 'category': 'joy'});
    await box.put('valid', {
      'label': 'فرح',
      'category': 'joy',
      'timestamp': DateTime.utc(2026, 5, 4).toIso8601String(),
    });

    final entries = repo.recentEntries();

    expect(entries, hasLength(1));
    expect(entries.single.label, 'فرح');
    // appliedImpact absent → defaults to 0.
    expect(entries.single.recoveryImpact, 0);
  });
}
