import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/usage_ask_flags.dart';
import '../data/usage_data_source.dart';
import '../data/usage_day_total.dart';
import '../domain/usage_math.dart';
import 'v3_state_providers.dart';

export '../data/usage_ask_flags.dart';

final usageDataSourceProvider = Provider<UsageDataSource>((ref) {
  return ChannelUsageDataSource();
});

class UsageSnapshot {
  const UsageSnapshot({
    required this.hasAccess,
    required this.days,
    required this.ask,
  });

  final bool hasAccess;
  final List<UsageDayTotal> days;
  final UsageAskFlags ask;

  double? yesterdayHours(DateTime now) => UsageMath.yesterdayHours(days, now);

  double? average7Hours(DateTime now) =>
      UsageMath.averageHours(days, now: now, window: 7);

  ({double from, double to})? firstVsLast7() =>
      UsageMath.firstVsLastWindow(days);
}

final usageSnapshotProvider =
    AsyncNotifierProvider<UsageSnapshotNotifier, UsageSnapshot>(
  UsageSnapshotNotifier.new,
);

class UsageSnapshotNotifier extends AsyncNotifier<UsageSnapshot> {
  @override
  Future<UsageSnapshot> build() => refresh();

  Future<UsageSnapshot> refresh() async {
    final source = ref.read(usageDataSourceProvider);
    final repo = ref.read(v3StateRepositoryProvider);
    final hasAccess = await source.hasAccess();
    final ask = await repo.loadUsageAskFlags();
    var days = await repo.loadUsageCache();
    if (hasAccess) {
      days = await source.dailyTotals(30);
      await repo.saveUsageCache(days);
    }
    final snap = UsageSnapshot(hasAccess: hasAccess, days: days, ask: ask);
    state = AsyncData(snap);
    return snap;
  }

  /// Call once when the sheet is actually presented.
  Future<void> recordAskShown() async {
    final repo = ref.read(v3StateRepositoryProvider);
    final current = await repo.loadUsageAskFlags();
    if (current.askCount >= 2) return;
    await repo.saveUsageAskFlags(
      UsageAskFlags(
        askCount: current.askCount + 1,
        ask1Declined: current.ask1Declined,
      ),
    );
    await refresh();
  }

  /// «Later» on ask #1 (askCount becomes 1 after [recordAskShown]).
  Future<void> recordAskDeclined() async {
    final repo = ref.read(v3StateRepositoryProvider);
    final current = await repo.loadUsageAskFlags();
    await repo.saveUsageAskFlags(
      UsageAskFlags(
        askCount: current.askCount,
        ask1Declined: true,
      ),
    );
    await refresh();
  }
}
