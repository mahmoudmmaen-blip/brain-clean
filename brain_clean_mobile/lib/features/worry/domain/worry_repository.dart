import 'worry_entry.dart';

abstract class WorryRepository {
  Future<void> saveEntry(WorryEntry entry);

  Future<List<WorryEntry>> getTodayEntries();

  Future<List<WorryEntry>> getAllEntries();
}
