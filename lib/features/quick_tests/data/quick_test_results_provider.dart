import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../domain/quick_test_ids.dart';
import '../domain/quick_test_result.dart';

class QuickTestResultsState {
  const QuickTestResultsState({
    this.iq,
    this.digitalBrainRot,
  });

  final QuickTestResult? iq;
  final QuickTestResult? digitalBrainRot;

  QuickTestResultsState copyWith({
    QuickTestResult? iq,
    QuickTestResult? digitalBrainRot,
  }) {
    return QuickTestResultsState(
      iq: iq ?? this.iq,
      digitalBrainRot: digitalBrainRot ?? this.digitalBrainRot,
    );
  }
}

/// Latest Phase 5 quick-test scores in [HiveBoxes.appMeta] (additive keys only).
class QuickTestResultsController extends StateNotifier<QuickTestResultsState> {
  QuickTestResultsController(this._box) : super(const QuickTestResultsState()) {
    state = _load();
  }

  final Box<dynamic> _box;

  QuickTestResultsState _load() {
    try {
      return QuickTestResultsState(
        iq: _read(HiveMetaKeys.iqTestResultJson),
        digitalBrainRot: _read(HiveMetaKeys.digitalBrainRotResultJson),
      );
    } catch (e) {
      debugPrint('QuickTestResultsController: load failed: $e');
      return const QuickTestResultsState();
    }
  }

  QuickTestResult? _read(String key) {
    final raw = _box.get(key);
    if (raw is! String || raw.isEmpty) return null;
    return QuickTestResult.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> record(QuickTestResult result) async {
    try {
      final key = switch (result.testId) {
        QuickTestIds.iq => HiveMetaKeys.iqTestResultJson,
        QuickTestIds.digitalBrainRot => HiveMetaKeys.digitalBrainRotResultJson,
        _ => null,
      };
      if (key == null) return;
      await _box.put(key, jsonEncode(result.toJson()));
      state = switch (result.testId) {
        QuickTestIds.iq => state.copyWith(iq: result),
        QuickTestIds.digitalBrainRot =>
          state.copyWith(digitalBrainRot: result),
        _ => state,
      };
    } catch (e) {
      debugPrint('QuickTestResultsController: persist failed: $e');
    }
  }
}

final quickTestResultsProvider =
    StateNotifierProvider<QuickTestResultsController, QuickTestResultsState>(
  (ref) => QuickTestResultsController(ref.watch(appMetaBoxProvider)),
);
