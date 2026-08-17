import 'dart:convert';

import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/features/cognitive_tests/application/cognitive_test_results_provider.dart';
import 'package:brain_clean_mobile/features/cognitive_tests/domain/cognitive_test_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

CognitiveTestResult _result(String testId, double score) => CognitiveTestResult(
      testId: testId,
      normalizedScore: score,
      completedAt: DateTime.utc(2026, 5, 4, 9),
    );

ProviderContainer _containerFor(InMemoryHiveBox box) {
  final container = ProviderContainer(
    overrides: [appMetaBoxProvider.overrideWithValue(box)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('CognitiveTestResults.build', () {
    test('starts empty when nothing has been persisted', () {
      final container = _containerFor(InMemoryHiveBox());

      final state = container.read(cognitiveTestResultsProvider);

      expect(state.visualAttention, isNull);
      expect(state.memorySequence, isNull);
    });

    test('hydrates both results from persisted JSON', () {
      final box = InMemoryHiveBox({
        HiveMetaKeys.cognitiveVisualResultJson:
            jsonEncode(_result('visual_attention', 72.5).toJson()),
        HiveMetaKeys.cognitiveMemoryResultJson:
            jsonEncode(_result('memory_sequence', 40).toJson()),
      });

      final state = _containerFor(box).read(cognitiveTestResultsProvider);

      expect(state.visualAttention?.testId, 'visual_attention');
      expect(state.visualAttention?.normalizedScore, 72.5);
      expect(state.memorySequence?.testId, 'memory_sequence');
      expect(state.memorySequence?.normalizedScore, 40);
    });

    test('ignores empty and non-string stored values', () {
      final box = InMemoryHiveBox({
        HiveMetaKeys.cognitiveVisualResultJson: '',
        HiveMetaKeys.cognitiveMemoryResultJson: 42,
      });

      final state = _containerFor(box).read(cognitiveTestResultsProvider);

      expect(state.visualAttention, isNull);
      expect(state.memorySequence, isNull);
    });

    test('degrades to an empty state when stored JSON is corrupt', () {
      final box = InMemoryHiveBox({
        HiveMetaKeys.cognitiveVisualResultJson: '{not json',
      });

      final state = _containerFor(box).read(cognitiveTestResultsProvider);

      expect(state.visualAttention, isNull);
      expect(state.memorySequence, isNull);
    });
  });

  group('recording results', () {
    test('recordVisual updates state and persists JSON without touching memory',
        () async {
      final box = InMemoryHiveBox();
      final container = _containerFor(box);
      final notifier = container.read(cognitiveTestResultsProvider.notifier);

      await notifier.recordVisual(_result('visual_attention', 61));

      expect(
        container.read(cognitiveTestResultsProvider).visualAttention?.testId,
        'visual_attention',
      );
      expect(container.read(cognitiveTestResultsProvider).memorySequence, isNull);
      final stored = jsonDecode(
        box.get(HiveMetaKeys.cognitiveVisualResultJson) as String,
      ) as Map<String, dynamic>;
      expect(stored['testId'], 'visual_attention');
      expect(stored['normalizedScore'], 61);
      expect(box.get(HiveMetaKeys.cognitiveMemoryResultJson), isNull);
    });

    test('recordMemory keeps a previously recorded visual result', () async {
      final box = InMemoryHiveBox();
      final container = _containerFor(box);
      final notifier = container.read(cognitiveTestResultsProvider.notifier);

      await notifier.recordVisual(_result('visual_attention', 61));
      await notifier.recordMemory(_result('memory_sequence', 33));

      final state = container.read(cognitiveTestResultsProvider);
      expect(state.visualAttention?.normalizedScore, 61);
      expect(state.memorySequence?.normalizedScore, 33);
      expect(box.get(HiveMetaKeys.cognitiveMemoryResultJson), isA<String>());
    });

    test('the latest result of a test replaces the previous one', () async {
      final box = InMemoryHiveBox();
      final container = _containerFor(box);
      final notifier = container.read(cognitiveTestResultsProvider.notifier);

      await notifier.recordVisual(_result('visual_attention', 61));
      await notifier.recordVisual(_result('visual_attention', 88));

      expect(
        container
            .read(cognitiveTestResultsProvider)
            .visualAttention
            ?.normalizedScore,
        88,
      );
      final stored = jsonDecode(
        box.get(HiveMetaKeys.cognitiveVisualResultJson) as String,
      ) as Map<String, dynamic>;
      expect(stored['normalizedScore'], 88);
    });
  });
}
