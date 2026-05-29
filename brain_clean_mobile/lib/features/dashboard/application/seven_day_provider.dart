import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/daily_snapshots_repository.dart';
import '../domain/daily_snapshot.dart';

part 'seven_day_provider.g.dart';

@riverpod
List<DailySnapshot> sevenDaySnapshots(SevenDaySnapshotsRef ref) {
  try {
    final stored = ref.watch(dailySnapshotsRepositoryProvider).loadAll();
    return padSevenDaySnapshots(stored);
  } catch (_) {
    return padSevenDaySnapshots(const []);
  }
}
