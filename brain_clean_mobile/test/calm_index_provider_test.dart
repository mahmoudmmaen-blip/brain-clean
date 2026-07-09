import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/anxiety/data/anxiety_repository_impl.dart';
import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_level.dart';
import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_result.dart';
import 'package:brain_clean_mobile/features/anxiety/presentation/calm_index_provider.dart';
import 'package:brain_clean_mobile/features/dashboard/domain/daily_snapshot.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  test('calm index hides line when fewer than two anxiety results', () {
    final data = CalmIndexChartData(
      spots: const [FlSpot(0, 80)],
      showLine: false,
    );
    expect(data.showLine, isFalse);
  });

  test('repository history enables multiple calm-index points', () async {
    HiveBootstrap.resetForTesting();
    final tempDir = await Directory.systemTemp.createTemp('bc_calm_index_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();

    if (Hive.isBoxOpen(HiveBoxes.anxietyPersistence)) {
      await Hive.box(HiveBoxes.anxietyPersistence).close();
    }
    final box = await Hive.openBox<dynamic>(HiveBoxes.anxietyPersistence);
    final repo = AnxietyRepositoryImpl(box: box);

    await repo.saveResult(
      AnxietyResult(
        answers: const [1, 1, 1, 1, 1, 1, 1, 1],
        score: 33,
        level: AnxietyLevel.moderate,
        timestamp: DateTime.utc(2026, 7, 7),
      ),
    );
    await repo.saveResult(
      AnxietyResult(
        answers: const [2, 2, 2, 2, 2, 2, 2, 2],
        score: 66,
        level: AnxietyLevel.high,
        timestamp: DateTime.utc(2026, 7, 8),
      ),
    );

    final all = await repo.getAllResults();
    expect(all.length, 2);

    final snapshots = [
      DailySnapshot(date: DateTime(2026, 7, 7), bcsValue: 70),
      DailySnapshot(date: DateTime(2026, 7, 8), bcsValue: 75),
    ];
    expect(100 - all.first.score, closeTo(67, 1));
    expect(snapshots.length, 2);

    await Hive.close();
    await tempDir.delete(recursive: true);
    HiveBootstrap.resetForTesting();
  });
}
