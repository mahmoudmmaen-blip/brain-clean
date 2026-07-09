import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/anxiety/data/anxiety_repository_impl.dart';
import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_level.dart';
import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AnxietyRepositoryImpl repository;

  setUp(() async {
    HiveBootstrap.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('bc_anxiety_hive_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();
    if (Hive.isBoxOpen(HiveBoxes.anxietyPersistence)) {
      await Hive.box(HiveBoxes.anxietyPersistence).close();
    }
    final box = await Hive.openBox<dynamic>(HiveBoxes.anxietyPersistence);
    repository = AnxietyRepositoryImpl(box: box);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  test('persists and restores latest anxiety result across box reopen', () async {
    final result = AnxietyResult(
      answers: const [0, 1, 2, 1, 0, 1, 2, 3],
      score: 50,
      level: AnxietyLevel.moderate,
      timestamp: DateTime.utc(2026, 7, 9, 10),
    );

    await repository.saveResult(result);
    if (Hive.isBoxOpen(HiveBoxes.anxietyPersistence)) {
      await Hive.box(HiveBoxes.anxietyPersistence).close();
    }
    final reopened = await Hive.openBox<dynamic>(HiveBoxes.anxietyPersistence);
    final reloadRepo = AnxietyRepositoryImpl(box: reopened);

    final restored = await reloadRepo.getLatestResult();
    expect(restored, isNotNull);
    expect(restored!.score, closeTo(50, 0.01));
    expect(restored.level, AnxietyLevel.moderate);
    expect(restored.answers, result.answers);
  });

  test('returns null when no result saved', () async {
    expect(await repository.getLatestResult(), isNull);
  });
}
