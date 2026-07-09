import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/worry/data/worry_repository_impl.dart';
import 'package:brain_clean_mobile/features/worry/domain/worry_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late WorryRepositoryImpl repository;

  setUp(() async {
    HiveBootstrap.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('bc_worry_hive_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();
    if (Hive.isBoxOpen(HiveBoxes.journalSpaces)) {
      await Hive.box(HiveBoxes.journalSpaces).close();
    }
    final box = await Hive.openBox<dynamic>(HiveBoxes.journalSpaces);
    repository = WorryRepositoryImpl(box: box);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  test('persists entries and filters today entries', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toUtc();
    final today = DateTime.now().toUtc();

    await repository.saveEntry(
      WorryEntry(
        id: 'old',
        content: 'yesterday worry',
        createdAt: yesterday,
        sessionMinutes: 10,
      ),
    );
    await repository.saveEntry(
      WorryEntry(
        id: 'new',
        content: 'today worry',
        createdAt: today,
        sessionMinutes: 15,
      ),
    );

    final todayEntries = await repository.getTodayEntries();
    expect(todayEntries.length, 1);
    expect(todayEntries.first.content, 'today worry');
    expect(todayEntries.first.sessionMinutes, 15);

    final all = await repository.getAllEntries();
    expect(all.length, 2);
  });

  test('appends multiple entries same day', () async {
    final now = DateTime.now().toUtc();
    await repository.saveEntry(
      WorryEntry(id: 'a', content: 'first', createdAt: now),
    );
    await repository.saveEntry(
      WorryEntry(
        id: 'b',
        content: 'second',
        createdAt: now.add(const Duration(minutes: 5)),
      ),
    );

    final todayEntries = await repository.getTodayEntries();
    expect(todayEntries.length, 2);
  });
}
