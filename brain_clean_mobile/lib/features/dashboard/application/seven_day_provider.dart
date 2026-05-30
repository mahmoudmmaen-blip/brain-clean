import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/daily_snapshots_repository.dart';
import '../domain/daily_snapshot.dart';

part 'seven_day_provider.g.dart';

@riverpod
Future<List<DailySnapshot>> sevenDaySnapshots(SevenDaySnapshotsRef ref) async {
  try {
    final stored = ref.watch(dailySnapshotsRepositoryProvider).loadAll();
    return padSevenDaySnapshots(stored);
  } catch (error, _) {
    throw Exception(error);
  }
}
