import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/storage/hive_bootstrap.dart';
import '../../core/storage/hive_boxes.dart';
import 'clarity_result.dart';
import 'day_progress.dart';
import 'evening_check_in.dart';
import 'focus_log.dart';
import 'sos_log.dart';
import 'user_inputs.dart';
import 'user_profile.dart';
import 'v3_app_state.dart';
import 'v3_storage_keys.dart';

abstract class V3StateRepository {
  Future<V3AppState> load();
  Future<void> saveProfile(UserProfile profile);
  Future<void> saveDayProgress(DayProgress progress);
  Future<void> appendClarityResult(ClarityResult result);
  Future<void> appendEveningCheckIn(EveningCheckIn checkIn);
  Future<void> appendSosLog(SosLog log);
  Future<void> appendFocusLog(FocusLog log);
  Future<void> saveUserInputs(UserInputs inputs);
  Future<void> setDay7PaywallShown(bool shown);
  Future<void> clearDayProgressOnly();
  Future<void> clearAll();
}

class V3StateLocalRepository implements V3StateRepository {
  V3StateLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const schemaVersion = 1;

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    final override = _boxOverride;
    if (override != null) return override;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.v3State);
  }

  Future<void> _ensureSchema(Box<dynamic> box) async {
    if (box.get(V3StorageKeys.schemaVersion) == null) {
      await box.put(V3StorageKeys.schemaVersion, schemaVersion);
    }
  }

  @override
  Future<V3AppState> load() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);

      UserProfile? profile;
      final rawProfile = box.get(V3StorageKeys.userProfile);
      if (rawProfile is Map) {
        profile = UserProfile.fromJson(Map<String, dynamic>.from(rawProfile));
      }

      final dayProgress = _readList(
        box.get(V3StorageKeys.dayProgress),
        DayProgress.fromJson,
      );

      final clarityResults = _readList(
        box.get(V3StorageKeys.clarityResults),
        ClarityResult.fromJson,
      );

      final eveningCheckIns = _readList(
        box.get(V3StorageKeys.eveningCheckIns),
        EveningCheckIn.fromJson,
      );

      final sosLogs = _readList(
        box.get(V3StorageKeys.sosLogs),
        SosLog.fromJson,
      );

      final focusLogs = _readList(
        box.get(V3StorageKeys.focusLogs),
        FocusLog.fromJson,
      );

      final rawInputs = box.get(V3StorageKeys.userInputs);
      final userInputs = rawInputs is Map
          ? UserInputs.fromJson(Map<String, dynamic>.from(rawInputs))
          : const UserInputs();

      return V3AppState(
        profile: profile,
        dayProgress: dayProgress,
        clarityResults: clarityResults,
        eveningCheckIns: eveningCheckIns,
        sosLogs: sosLogs,
        focusLogs: focusLogs,
        userInputs: userInputs,
        day7PaywallShown: box.get(V3StorageKeys.day7PaywallShown) == true,
      );
    } catch (e, st) {
      debugPrint('V3StateLocalRepository.load failed: $e\n$st');
      return const V3AppState();
    }
  }

  List<T> _readList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];
    final out = <T>[];
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('V3StateLocalRepository: skip corrupt row: $e');
      }
    }
    return out;
  }

  Future<List<DayProgress>> _readDayProgress(Box<dynamic> box) async {
    return _readList(box.get(V3StorageKeys.dayProgress), DayProgress.fromJson);
  }

  Future<void> _writeDayProgress(
    Box<dynamic> box,
    List<DayProgress> items,
  ) async {
    await box.put(
      V3StorageKeys.dayProgress,
      items.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final box = await _openBox();
    await _ensureSchema(box);
    await box.put(V3StorageKeys.userProfile, profile.toJson());
  }

  @override
  Future<void> saveDayProgress(DayProgress progress) async {
    final box = await _openBox();
    await _ensureSchema(box);
    final items = await _readDayProgress(box);
    final next = [...items.where((p) => p.day != progress.day), progress]
      ..sort((a, b) => a.day.compareTo(b.day));
    await _writeDayProgress(box, next);
  }

  Future<void> _appendToList<T>(
    String key,
    T item,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final box = await _openBox();
    await _ensureSchema(box);
    final existing = _readList(box.get(key), fromJson);
    await box.put(key, [...existing.map(toJson), toJson(item)]);
  }

  @override
  Future<void> appendClarityResult(ClarityResult result) async {
    await _appendToList(
      V3StorageKeys.clarityResults,
      result,
      (r) => r.toJson(),
      ClarityResult.fromJson,
    );
  }

  @override
  Future<void> appendEveningCheckIn(EveningCheckIn checkIn) async {
    await _appendToList(
      V3StorageKeys.eveningCheckIns,
      checkIn,
      (r) => r.toJson(),
      EveningCheckIn.fromJson,
    );
  }

  @override
  Future<void> appendSosLog(SosLog log) async {
    await _appendToList(
      V3StorageKeys.sosLogs,
      log,
      (r) => r.toJson(),
      SosLog.fromJson,
    );
  }

  @override
  Future<void> appendFocusLog(FocusLog log) async {
    await _appendToList(
      V3StorageKeys.focusLogs,
      log,
      (r) => r.toJson(),
      FocusLog.fromJson,
    );
  }

  @override
  Future<void> saveUserInputs(UserInputs inputs) async {
    final box = await _openBox();
    await _ensureSchema(box);
    await box.put(V3StorageKeys.userInputs, inputs.toJson());
  }

  @override
  Future<void> setDay7PaywallShown(bool shown) async {
    final box = await _openBox();
    await _ensureSchema(box);
    await box.put(V3StorageKeys.day7PaywallShown, shown);
  }

  @override
  Future<void> clearDayProgressOnly() async {
    final box = await _openBox();
    await box.delete(V3StorageKeys.dayProgress);
  }

  @override
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
    await _ensureSchema(box);
  }
}
