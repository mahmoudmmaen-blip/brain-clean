import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../domain/cognitive_test_result.dart';
import '../domain/cognitive_test_scorer.dart';

part 'cognitive_test_results_provider.g.dart';

class CognitiveTestResultsState {
  const CognitiveTestResultsState({
    this.visualAttention,
    this.memorySequence,
  });

  final CognitiveTestResult? visualAttention;
  final CognitiveTestResult? memorySequence;

  CognitiveTestResultsState copyWith({
    CognitiveTestResult? visualAttention,
    CognitiveTestResult? memorySequence,
  }) {
    return CognitiveTestResultsState(
      visualAttention: visualAttention ?? this.visualAttention,
      memorySequence: memorySequence ?? this.memorySequence,
    );
  }
}

/// Latest cognitive mini-game results — feeds [CognitiveTestScorer] → live BHI.
@Riverpod(keepAlive: true)
class CognitiveTestResults extends _$CognitiveTestResults {
  @override
  CognitiveTestResultsState build() => _loadFromMeta();

  CognitiveTestResultsState _loadFromMeta() {
    try {
      final box = ref.read(appMetaBoxProvider);
      CognitiveTestResult? visual;
      CognitiveTestResult? memory;

      final visualRaw = box.get(HiveMetaKeys.cognitiveVisualResultJson);
      if (visualRaw is String && visualRaw.isNotEmpty) {
        visual = CognitiveTestResult.fromJson(
          jsonDecode(visualRaw) as Map<String, dynamic>,
        );
      }

      final memoryRaw = box.get(HiveMetaKeys.cognitiveMemoryResultJson);
      if (memoryRaw is String && memoryRaw.isNotEmpty) {
        memory = CognitiveTestResult.fromJson(
          jsonDecode(memoryRaw) as Map<String, dynamic>,
        );
      }

      return CognitiveTestResultsState(
        visualAttention: visual,
        memorySequence: memory,
      );
    } catch (e) {
      debugPrint('CognitiveTestResults: load failed: $e');
      return const CognitiveTestResultsState();
    }
  }

  Future<void> recordVisual(CognitiveTestResult result) async {
    state = state.copyWith(visualAttention: result);
    await _persistVisual(result);
  }

  Future<void> recordMemory(CognitiveTestResult result) async {
    state = state.copyWith(memorySequence: result);
    await _persistMemory(result);
  }

  Future<void> _persistVisual(CognitiveTestResult result) async {
    try {
      await ref.read(appMetaBoxProvider).put(
            HiveMetaKeys.cognitiveVisualResultJson,
            jsonEncode(result.toJson()),
          );
    } catch (e) {
      debugPrint('CognitiveTestResults: persist visual failed: $e');
    }
  }

  Future<void> _persistMemory(CognitiveTestResult result) async {
    try {
      await ref.read(appMetaBoxProvider).put(
            HiveMetaKeys.cognitiveMemoryResultJson,
            jsonEncode(result.toJson()),
          );
    } catch (e) {
      debugPrint('CognitiveTestResults: persist memory failed: $e');
    }
  }
}
