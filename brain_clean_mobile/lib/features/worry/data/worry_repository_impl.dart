import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/worry_entry.dart';
import '../domain/worry_repository.dart';

class WorryRepositoryImpl implements WorryRepository {
  WorryRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _entriesKey = 'worry_entries';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.journalSpaces);
  }

  Future<List<WorryEntry>> _readAll() async {
    try {
      final box = await _openBox();
      final raw = box.get(_entriesKey);
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((item) => WorryEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('WorryRepositoryImpl: read failed: $e');
      return [];
    }
  }

  Future<void> _writeAll(List<WorryEntry> entries) async {
    try {
      final box = await _openBox();
      await box.put(_entriesKey, entries.map((e) => e.toJson()).toList());
    } catch (e) {
      debugPrint('WorryRepositoryImpl: write failed: $e');
    }
  }

  @override
  Future<void> saveEntry(WorryEntry entry) async {
    final all = await _readAll();
    all.add(entry);
    await _writeAll(all);
  }

  @override
  Future<List<WorryEntry>> getTodayEntries() async {
    final now = DateTime.now();
    final all = await _readAll();
    return all.where((e) => worryEntryIsToday(e, now)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<WorryEntry>> getAllEntries() async {
    final all = await _readAll();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }
}
