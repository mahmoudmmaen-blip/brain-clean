import 'package:brain_clean_mobile/v3/data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late V3StateLocalRepository repo;

  setUp(() {
    box = InMemoryHiveBox();
    repo = V3StateLocalRepository(box: box);
  });

  test('round-trips profile and day progress', () async {
    final profile = UserProfile(
      goal: 'focus',
      reminderTime: '20:00',
      eveningCheckIn: true,
      onboardingDone: true,
      createdAt: DateTime(2025, 1, 1),
      locale: 'ar',
      name: 'Sara',
    );
    await repo.saveProfile(profile);
    await repo.saveDayProgress(
      DayProgress(
        day: 1,
        lessonDone: true,
        practiceDone: true,
        usedEasy: false,
        challengeAccepted: true,
        completedAt: DateTime(2025, 1, 2),
      ),
    );

    final loaded = await repo.load();
    expect(loaded.profile?.name, 'Sara');
    expect(loaded.dayProgress, hasLength(1));
    expect(loaded.dayProgress.first.day, 1);
  });

  test('clearDayProgressOnly keeps profile', () async {
    await repo.saveProfile(
      UserProfile(
        goal: 'calm',
        reminderTime: '19:00',
        eveningCheckIn: false,
        onboardingDone: true,
        createdAt: DateTime(2025, 1, 1),
        locale: 'en',
      ),
    );
    await repo.saveDayProgress(
      const DayProgress(
        day: 2,
        lessonDone: false,
        practiceDone: false,
        usedEasy: false,
        challengeAccepted: false,
      ),
    );
    await repo.clearDayProgressOnly();
    final loaded = await repo.load();
    expect(loaded.profile?.goal, 'calm');
    expect(loaded.dayProgress, isEmpty);
  });
}
