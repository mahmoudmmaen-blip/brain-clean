import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/bc_score_engine.dart';
import '../domain/bc_score_result.dart';
import 'diagnostic_controller.dart';

part 'bc_score_provider.g.dart';

/// Recomputes whenever any of the 6 diagnostic sliders changes.
@riverpod
BcScoreResult bcScoreLive(BcScoreLiveRef ref) {
  final metrics = ref.watch(diagnosticControllerProvider);
  return BcScoreEngine.calculate(metrics);
}

/// Snapshot saved on diagnostic submit — shown on dashboard.
@riverpod
class BcScoreSession extends _$BcScoreSession {
  @override
  BcScoreResult? build() => null;

  void commit(BcScoreResult result) {
    state = result;
  }

  void clear() => state = null;
}
