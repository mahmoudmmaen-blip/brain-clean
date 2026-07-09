import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../worry/data/worry_repository_provider.dart';

part 'safa_night_journal_checkin_provider.g.dart';

@riverpod
Future<bool> showSafaNightJournalCheckin(
  ShowSafaNightJournalCheckinRef ref,
) async {
  final prefs = ref.watch(appPreferencesProvider);
  final dismissedUntil = prefs.safaCheckinDismissedUntil;
  if (dismissedUntil != null && DateTime.now().isBefore(dismissedUntil)) {
    return false;
  }

  final entries = await ref.watch(worryRepositoryProvider).getAllEntries();
  final nightEntries =
      entries.where((e) => e.createdAt.toLocal().hour >= 21).length;
  return nightEntries >= 3;
}
