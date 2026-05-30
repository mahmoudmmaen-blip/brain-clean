import 'package:brain_clean_mobile/core/application/app_preferences_provider.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/features/emotions/data/emotion_log_repository.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_streak_provider.dart';
import 'package:brain_clean_mobile/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/hive_test_fixtures.dart';
import 'helpers/localized_test_app.dart';

void main() {
  testWidgets('ProfileScreen renders stats row with 3 cards', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _profileTestApp(
        overrides: _baseOverrides(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(profileStatsRowKey), findsOneWidget);
    expect(find.text('يوم تركيز'), findsOneWidget);
    expect(find.text('BCS'), findsOneWidget);
    expect(find.text('إحساس'), findsOneWidget);
  });

  testWidgets('streak badge locked when streakDays is below 7', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _profileTestApp(
        overrides: [
          ..._baseOverrides(),
          homeStreakSnapshotProvider.overrideWith(
            (ref) => const HomeStreakSnapshot(
              days: 3,
              hours: 0,
              minutes: 0,
              seconds: 0,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(profileBadgeStreak7Key),
        matching: find.byType(Opacity),
      ),
      findsOneWidget,
    );
  });

  testWidgets('streak badge unlocked when streakDays is 7 or more', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _profileTestApp(
        overrides: [
          ..._baseOverrides(),
          homeStreakSnapshotProvider.overrideWith(
            (ref) => const HomeStreakSnapshot(
              days: 7,
              hours: 0,
              minutes: 0,
              seconds: 0,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(profileBadgeStreak7Key),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
    expect(find.text('7 أيام متواصلة'), findsOneWidget);
  });

  testWidgets('recent emotions empty state when log is empty', (tester) async {
    await tester.pumpWidget(
      _profileTestApp(overrides: _baseOverrides()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(profileEmptyEmotionsKey), findsOneWidget);
    expect(find.text('لم تسجل أي أحاسيس بعد'), findsOneWidget);
  });
}

List<Override> _baseOverrides() {
  return [
    appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
    emotionLogBoxProvider.overrideWithValue(InMemoryHiveBox()),
    homeStreakTickerProvider.overrideWith((ref) => Stream<int>.value(0)),
    ...diagnosticWidgetTestOverrides(),
  ];
}

Widget _profileTestApp({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: createLocalizedProviderTestWidget(
      const ProfileScreen(),
      locale: const Locale('ar'),
    ),
  );
}
