import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/daily_program_repository.dart';
import '../domain/daily_program_service.dart';
import '../domain/daily_program_state.dart';
import '../domain/daily_step.dart';

class DailyProgramRepositoryImpl implements DailyProgramRepository {
  DailyProgramRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _todayKey = 'daily_program_today';

  final Box<dynamic>? _boxOverride;

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.dailyProgram);
  }

  /// Hive cannot write Freezed objects; persist plain JSON maps only.
  Map<String, dynamic> _toHiveJson(DailyProgramState state) {
    return <String, dynamic>{
      'date': state.date.toIso8601String(),
      'dayNumber': state.dayNumber,
      'steps': state.steps.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> _fromHiveMap(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final steps = map['steps'];
    if (steps is List) {
      map['steps'] = steps
          .map((e) => e is Map ? Map<String, dynamic>.from(e) : e)
          .toList();
    }
    return map;
  }

  Future<void> _save(DailyProgramState state) async {
    final box = await _openBox();
    await box.put(_todayKey, _toHiveJson(state));
  }

  Future<DailyProgramState?> _readStoredToday() async {
    final box = await _openBox();
    final raw = box.get(_todayKey);
    if (raw is! Map) return null;
    final existing = DailyProgramState.fromJson(
      _fromHiveMap(Map<dynamic, dynamic>.from(raw)),
    );
    if (_dateOnly(existing.date) != _dateOnly(DateTime.now())) {
      return null;
    }
    return existing;
  }

  @override
  Future<DailyProgramState> getToday({required int dayNumber}) async {
    try {
      final safeDay = dayNumber < 1 ? 1 : dayNumber;
      final existing = await _readStoredToday();
      if (existing != null) {
        final migratedSteps =
            DailyProgramService.ensureCurrentStepSchema(existing.steps);
        final synced = existing.copyWith(
          dayNumber: safeDay,
          steps: migratedSteps,
        );
        final needsSave = synced.dayNumber != existing.dayNumber ||
            migratedSteps.length != existing.steps.length ||
            !_sameStepOrder(existing.steps, migratedSteps);
        if (needsSave) {
          await _save(synced);
        }
        return synced;
      }

      final fresh = DailyProgramState(
        date: _dateOnly(DateTime.now()),
        dayNumber: safeDay,
        steps: DailyProgramService.buildTodaySteps(),
      );
      await _save(fresh);
      return fresh;
    } catch (e) {
      debugPrint('DailyProgramRepositoryImpl: getToday failed: $e');
      return DailyProgramState(
        date: _dateOnly(DateTime.now()),
        dayNumber: dayNumber < 1 ? 1 : dayNumber,
        steps: DailyProgramService.buildTodaySteps(),
      );
    }
  }

  @override
  Future<DailyProgramState> completeStep(DailyStep step) async {
    final current = await _readStoredToday() ??
        await getToday(dayNumber: 1);
    final updated = current.copyWith(
      steps: DailyProgramService.afterComplete(current.steps, step),
    );
    await _save(updated);
    return updated;
  }

  @override
  Future<DailyProgramState> skipStep(DailyStep step) async {
    final current = await _readStoredToday() ??
        await getToday(dayNumber: 1);
    final updated = current.copyWith(
      steps: DailyProgramService.afterSkip(current.steps, step),
    );
    await _save(updated);
    return updated;
  }

  bool _sameStepOrder(
    List<DailyStepEntry> a,
    List<DailyStepEntry> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].step != b[i].step || a[i].status != b[i].status) return false;
    }
    return true;
  }
}
