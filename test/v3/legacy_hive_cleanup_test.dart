import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    HiveBootstrap.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('bc_legacy_hive_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  test('hasLegacyBoxes detects old V2 box names', () async {
    expect(await HiveBootstrap.hasLegacyBoxes(), isFalse);
    await Hive.openBox<dynamic>(HiveBoxes.dailySession);
    expect(await HiveBootstrap.hasLegacyBoxes(), isTrue);
  });

  test('deleteLegacyBoxes removes old boxes and keeps v3_state', () async {
    await Hive.openBox<dynamic>(HiveBoxes.dailySession);
    await Hive.openBox<dynamic>(HiveBoxes.v3State);
    await Hive.box(HiveBoxes.v3State).put('keep', true);
    await Hive.box(HiveBoxes.dailySession).close();
    await Hive.box(HiveBoxes.v3State).close();

    await HiveBootstrap.deleteLegacyBoxes();

    expect(await Hive.boxExists(HiveBoxes.dailySession), isFalse);
    expect(await Hive.boxExists(HiveBoxes.v3State), isTrue);
  });
}
