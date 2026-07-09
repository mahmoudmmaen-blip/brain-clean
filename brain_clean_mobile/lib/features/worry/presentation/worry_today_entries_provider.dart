import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/worry_entry.dart';
import '../data/worry_repository_provider.dart';

part 'worry_today_entries_provider.g.dart';

@riverpod
Future<List<WorryEntry>> worryTodayEntries(WorryTodayEntriesRef ref) {
  return ref.watch(worryRepositoryProvider).getTodayEntries();
}

@riverpod
Future<bool> worryHabitDoneToday(WorryHabitDoneTodayRef ref) async {
  final entries = await ref.watch(worryTodayEntriesProvider.future);
  return entries.isNotEmpty;
}
