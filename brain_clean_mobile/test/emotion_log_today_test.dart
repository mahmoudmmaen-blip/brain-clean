import 'package:brain_clean_mobile/features/emotions/data/emotion_log_repository.dart';
import 'package:brain_clean_mobile/features/emotions/domain/emotion_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late EmotionLogRepository repository;

  setUp(() {
    box = InMemoryHiveBox();
    repository = EmotionLogRepository(box);
  });

  final joy = EmotionModel.catalog.firstWhere(
    (e) => e.category == EmotionCategory.joy && e.intensity == 1,
  );

  test('hasLoggedToday is false when empty', () {
    expect(repository.hasLoggedToday(), isFalse);
    expect(repository.latestTodayTimestamp(), isNull);
  });

  test('hasLoggedToday detects today entries and after baseline', () async {
    final earlier = DateTime.now().subtract(const Duration(minutes: 5));
    await repository.append(
      emotion: joy,
      appliedImpact: 0,
      timestamp: earlier,
    );

    expect(repository.hasLoggedToday(), isTrue);
    expect(repository.latestTodayTimestamp(), earlier);
    expect(repository.hasLoggedToday(after: earlier), isFalse);

    final later = earlier.add(const Duration(minutes: 1));
    await repository.append(
      emotion: joy,
      appliedImpact: 0,
      timestamp: later,
    );

    expect(repository.hasLoggedToday(after: earlier), isTrue);
    expect(repository.latestTodayTimestamp(), later);
  });

  test('hasLoggedToday ignores yesterday entries', () async {
    await repository.append(
      emotion: joy,
      appliedImpact: 0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    );

    expect(repository.hasLoggedToday(), isFalse);
    expect(repository.latestTodayTimestamp(), isNull);
  });
}
