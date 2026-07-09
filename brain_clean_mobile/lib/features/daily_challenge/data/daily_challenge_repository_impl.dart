import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/daily_challenge.dart';
import '../domain/daily_challenge_repository.dart';

class DailyChallengeRepositoryImpl implements DailyChallengeRepository {
  DailyChallengeRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _todayKey = 'daily_challenge_today';

  final Box<dynamic>? _boxOverride;

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.dailyChallenge);
  }

  @override
  Future<void> saveTodayChallenge(DailyChallenge challenge) async {
    try {
      final box = await _openBox();
      await box.put(_todayKey, challenge.toJson());
    } catch (e) {
      debugPrint('DailyChallengeRepositoryImpl: saveTodayChallenge failed: $e');
    }
  }

  @override
  Future<DailyChallenge?> getTodayChallenge() async {
    try {
      final box = await _openBox();
      final raw = box.get(_todayKey);
      if (raw is! Map) return null;
      final challenge = DailyChallenge.fromJson(
        Map<String, dynamic>.from(raw),
      );
      if (_dateOnly(challenge.date) != _dateOnly(DateTime.now())) {
        return null;
      }
      return challenge;
    } catch (e) {
      debugPrint('DailyChallengeRepositoryImpl: getTodayChallenge failed: $e');
      return null;
    }
  }

  @override
  Future<void> markCompleted() async {
    try {
      final existing = await getTodayChallenge();
      if (existing == null || existing.isCompleted) return;
      await saveTodayChallenge(
        existing.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('DailyChallengeRepositoryImpl: markCompleted failed: $e');
    }
  }
}
