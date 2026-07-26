import 'dart:io';

import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/storage/app_data_reset.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('AppDataReset', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('bc_reset_test_');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('targetBoxNames covers every HiveBoxes.allDurable entry', () {
      expect(AppDataReset.targetBoxNames, HiveBoxes.allDurable);
      expect(
        AppDataReset.targetBoxNames.toSet(),
        {
          HiveBoxes.recoveryProtocol,
          HiveBoxes.diagnosticPersistence,
          HiveBoxes.anxietyPersistence,
          HiveBoxes.emotionLog,
          HiveBoxes.dailySnapshots,
          HiveBoxes.appMeta,
          HiveBoxes.journeyData,
          HiveBoxes.journalSpaces,
          HiveBoxes.goldenMemories,
          HiveBoxes.xpLedger,
          HiveBoxes.dailyChallenge,
          HiveBoxes.smartReminders,
          HiveBoxes.dailyProgram,
          HiveBoxes.sukoon,
        },
      );
    });

    test('intentionally includes dailyProgram box in reset targets', () {
      expect(
        AppDataReset.targetBoxNames,
        contains(HiveBoxes.dailyProgram),
      );
    });

    test('clears all open durable boxes and restores encryption flag', () async {
      final seeded = <String>[];
      for (final name in HiveBoxes.allDurable) {
        final box = await Hive.openBox<dynamic>(name);
        await box.put('probe_$name', 'value');
        seeded.add(name);
      }

      final cleared = await AppDataReset.clearAllOpenDurableBoxes();

      expect(cleared.toSet(), seeded.toSet());
      for (final name in HiveBoxes.allDurable) {
        final box = Hive.box<dynamic>(name);
        if (name == HiveBoxes.appMeta) {
          expect(box.keys.length, 1);
          expect(box.get(HiveMetaKeys.boxesEncryptedV1), isTrue);
        } else {
          expect(box.isEmpty, isTrue, reason: '$name should be empty');
        }
      }
    });

    test('skips boxes that are not open', () async {
      await Hive.openBox<dynamic>(HiveBoxes.appMeta);
      await Hive.box<dynamic>(HiveBoxes.appMeta).put('x', 1);

      final cleared = await AppDataReset.clearAllOpenDurableBoxes();

      expect(cleared, [HiveBoxes.appMeta]);
      expect(
        Hive.box<dynamic>(HiveBoxes.appMeta).get(HiveMetaKeys.boxesEncryptedV1),
        isTrue,
      );
    });
  });
}
