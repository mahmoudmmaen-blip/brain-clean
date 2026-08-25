import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import '../../quick_tests/domain/quick_test_ids.dart';
import '../../quick_tests/domain/quick_test_result.dart';
import '../domain/bri_question_bank.dart';
import '../domain/bri_result.dart';
import '../domain/bri_scorer.dart';

/// Latest free BRI result from Hive `app_meta`.
class BriResultsController extends StateNotifier<BriResult?> {
  BriResultsController(this._box) : super(null) {
    state = _load();
  }

  final Box<dynamic> _box;

  BriResult? _load() {
    try {
      final raw = _box.get(HiveMetaKeys.briResultJson);
      if (raw is! String || raw.isEmpty) return null;
      return BriResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('BriResultsController: load failed: $e');
      return null;
    }
  }

  int get daysUntilRetest => BriScorer.daysUntilRetest(state);

  bool get canRetake => daysUntilRetest == 0;

  Future<void> record(BriResult result) async {
    try {
      await _box.put(HiveMetaKeys.briResultJson, jsonEncode(result.toJson()));
      state = result;
    } catch (e) {
      debugPrint('BriResultsController: persist failed: $e');
    }
  }
}

final briResultsProvider =
    StateNotifierProvider<BriResultsController, BriResult?>((ref) {
  return BriResultsController(ref.watch(appMetaBoxProvider));
});

/// Persists BRI and mirrors clarity into digital brain-rot for program blend.
Future<void> persistBriAndMirrorDigital({
  required WidgetRef ref,
  required BriResult bri,
}) async {
  await ref.read(briResultsProvider.notifier).record(bri);
  // Daily program / coverage treat digitalBrainRot.scorePercent as clarity.
  await ref.read(quickTestResultsProvider.notifier).record(
        QuickTestResult(
          testId: QuickTestIds.digitalBrainRot,
          scorePercent: bri.clarityScore,
          completedAt: bri.completedAt,
          totalCount: BriQuestionBank.questionCount,
        ),
      );
}
