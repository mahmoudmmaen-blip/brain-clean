import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';
import '../domain/daily_snapshot.dart';

/// Local persistence for 7-day BCS history.
class DailySnapshotsRepository {
  DailySnapshotsRepository(this._box);

  final Box<dynamic> _box;

  List<DailySnapshot> loadAll() {
    final items = <DailySnapshot>[];
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value is DailySnapshot) {
        items.add(value);
      }
    }
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Future<void> save(DailySnapshot snapshot) async {
    final key = _dateKey(snapshot.date);
    await _box.put(key, snapshot);
    await _trimToMax(7);
  }

  Future<void> _trimToMax(int max) async {
    final all = loadAll();
    if (all.length <= max) return;
    final toRemove = all.sublist(0, all.length - max);
    for (final snap in toRemove) {
      await _box.delete(_dateKey(snap.date));
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final dailySnapshotsBoxProvider = Provider<Box<dynamic>>((ref) {
  if (!Hive.isBoxOpen(HiveBoxes.dailySnapshots)) {
    throw StateError('Hive box ${HiveBoxes.dailySnapshots} is not open');
  }
  return Hive.box<dynamic>(HiveBoxes.dailySnapshots);
});

final dailySnapshotsRepositoryProvider =
    Provider<DailySnapshotsRepository>((ref) {
  return DailySnapshotsRepository(ref.watch(dailySnapshotsBoxProvider));
});

/// Pads to exactly 7 entries — missing days at the start use bcsValue 0.
List<DailySnapshot> padSevenDaySnapshots(List<DailySnapshot> stored) {
  final sorted = [...stored]..sort((a, b) => a.date.compareTo(b.date));
  final recent =
      sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
  final padCount = 7 - recent.length;
  final padded = <DailySnapshot>[];
  for (var i = 0; i < padCount; i++) {
    padded.add(
      DailySnapshot(
        date: DateTime(2000, 1, 1).add(Duration(days: i)),
        bcsValue: 0,
      ),
    );
  }
  padded.addAll(recent);
  return padded;
}
