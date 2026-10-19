import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/v3/application/usage_providers.dart';
import 'package:brain_clean_mobile/v3/application/v3_onboarding_gate_provider.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/data/clarity_result.dart';
import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/data/usage_data_source.dart';
import 'package:brain_clean_mobile/v3/data/user_inputs.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_backup_codec.dart';
import 'package:brain_clean_mobile/v3/data/v3_backup_crypto.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/ui/graduation/graduation_screen.dart';
import 'package:brain_clean_mobile/v3/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

UserProfile _profile({String? name, String locale = 'en'}) => UserProfile(
      name: name,
      goal: 'focus',
      reminderTime: '20:00',
      eveningCheckIn: true,
      onboardingDone: true,
      createdAt: DateTime(2026, 1, 1),
      locale: locale,
    );

void main() {
  test('reset clears data; Pro stays', () async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile(name: 'Ada'));
    await repo.saveDayProgress(
      const DayProgress(
        day: 1,
        lessonDone: true,
        practiceDone: true,
        usedEasy: false,
        challengeAccepted: false,
      ),
    );
    await repo.saveUserInputs(
      const UserInputs(futureLetter: 'hello future'),
    );

    var isPro = true;
    final container = ProviderContainer(
      overrides: [
        v3StateRepositoryProvider.overrideWithValue(repo),
        isProUserProvider.overrideWith((ref) => isPro),
      ],
    );
    addTearDown(container.dispose);

    expect((await repo.load()).profile?.name, 'Ada');
    await repo.clearAll();
    container.read(v3OnboardingGateProvider.notifier).markOnboardingIncomplete();
    container.invalidate(v3AppStateProvider);

    final after = await repo.load();
    expect(after.profile, isNull);
    expect(after.dayProgress, isEmpty);
    expect(after.userInputs.futureLetter, isNull);
    expect(container.read(isProUserProvider), isTrue);
    expect(container.read(v3OnboardingGateProvider), isFalse);
  });

  testWidgets('language switch updates localeProvider', (tester) async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile());
    final fakeUsage = FakeUsageDataSource(hasAccessValue: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v3StateRepositoryProvider.overrideWithValue(repo),
          usageDataSourceProvider.overrideWithValue(fakeUsage),
          isProUserProvider.overrideWith((ref) => false),
          localeProvider.overrideWith((ref) => const Locale('en')),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          home: const V3SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(V3SettingsScreen));
    final container = ProviderScope.containerOf(ctx);
    expect(container.read(localeProvider).languageCode, 'en');

    await tester.tap(find.byKey(const Key('v3_settings_lang_ar')));
    await tester.pumpAndSettle();
    expect(container.read(localeProvider).languageCode, 'ar');
  });

  testWidgets('letter row hidden when empty', (tester) async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile());
    final fakeUsage = FakeUsageDataSource(hasAccessValue: false);
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v3StateRepositoryProvider.overrideWithValue(repo),
          usageDataSourceProvider.overrideWithValue(fakeUsage),
          isProUserProvider.overrideWith((ref) => false),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: supportedLocales,
              home: const V3SettingsScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_settings_letter')), findsNothing);

    await repo.saveUserInputs(const UserInputs(futureLetter: 'Dear me'));
    expect((await repo.load()).userInputs.futureLetter, 'Dear me');
    container.invalidate(v3AppStateProvider);
    final refreshed = await container.read(v3AppStateProvider.future);
    expect(refreshed.userInputs.futureLetter, 'Dear me');
    await tester.pumpAndSettle();
    final letterFinder = find.byKey(const Key('v3_settings_letter'));
    if (letterFinder.evaluate().isEmpty) {
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
    }
    expect(letterFinder, findsOneWidget);
  });

  test('export→import round trip restores identical data', () async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile(name: 'Sam'));
    await repo.saveDayProgress(
      const DayProgress(
        day: 3,
        lessonDone: true,
        practiceDone: true,
        usedEasy: false,
        challengeAccepted: false,
      ),
    );
    await repo.saveUserInputs(
      const UserInputs(futureLetter: 'keep going', rules: ['sleep', 'walk']),
    );
    final before = await repo.dumpBox();

    final plaintext = V3BackupCodec.encodePayload(before);
    final envelope = await V3BackupCrypto.encrypt(
      plaintextJson: plaintext,
      passphrase: 'secret1',
    );
    final restored = V3BackupCodec.decodePayload(
      await V3BackupCrypto.decrypt(
        envelopeJson: envelope,
        passphrase: 'secret1',
      ),
    );

    final other = InMemoryHiveBox();
    final otherRepo = V3StateLocalRepository(box: other);
    await otherRepo.replaceAll(restored);
    expect(await otherRepo.dumpBox(), before);
    final state = await otherRepo.load();
    expect(state.profile?.name, 'Sam');
    expect(state.userInputs.futureLetter, 'keep going');
    expect(state.dayProgress.single.day, 3);
  });

  test('wrong passphrase leaves data unchanged', () async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile(name: 'Keep'));
    final dump = await repo.dumpBox();
    final envelope = await V3BackupCrypto.encrypt(
      plaintextJson: V3BackupCodec.encodePayload(dump),
      passphrase: 'correct',
    );

    await expectLater(
      () => V3BackupCrypto.decrypt(
        envelopeJson: envelope,
        passphrase: 'wrong!!',
      ),
      throwsA(
        isA<V3BackupException>().having((e) => e.code, 'code', 'wrong_passphrase'),
      ),
    );
    expect((await repo.load()).profile?.name, 'Keep');
    expect(await repo.dumpBox(), dump);
  });

  testWidgets('graduation shows seeded before/after', (tester) async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    await repo.saveProfile(_profile());
    await repo.appendClarityResult(
      ClarityResult(
        takenAt: DateTime(2026, 1, 1),
        programDay: 1,
        score: 42,
        areas: const ClarityAreaScores(
          focus: 10,
          control: 10,
          sleep: 10,
          calm: 12,
        ),
        hoursEstimate: 6,
        answers: const {},
      ),
    );
    await repo.appendClarityResult(
      ClarityResult(
        takenAt: DateTime(2026, 1, 30),
        programDay: 30,
        score: 71,
        areas: const ClarityAreaScores(
          focus: 18,
          control: 18,
          sleep: 17,
          calm: 18,
        ),
        hoursEstimate: 4,
        answers: const {},
      ),
    );
    for (var d = 1; d <= 5; d++) {
      await repo.saveDayProgress(
        DayProgress(
          day: d,
          lessonDone: true,
          practiceDone: true,
          usedEasy: false,
          challengeAccepted: false,
          completedAt: DateTime(2026, 1, d),
        ),
      );
    }
    await repo.saveUserInputs(const UserInputs(futureLetter: 'I did it'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v3StateRepositoryProvider.overrideWithValue(repo),
          usageDataSourceProvider.overrideWithValue(
            FakeUsageDataSource(hasAccessValue: false),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          home: const V3GraduationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('v3_graduation_clarity')), findsOneWidget);
    expect(find.textContaining('42'), findsWidgets);
    expect(find.textContaining('71'), findsWidgets);
    expect(find.byKey(const Key('v3_graduation_hours')), findsOneWidget);
    expect(find.byKey(const Key('v3_graduation_letter')), findsOneWidget);
  });
}
