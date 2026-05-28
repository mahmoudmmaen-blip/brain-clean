import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/diagnostic_local_repository_provider.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';
import 'diagnostic_controller.dart';

part 'bc_score_provider.g.dart';

/// Recomputes BHI pillars whenever sliders or detox check-ins change.
///
/// Delegates to [diagnosticLiveModelProvider] — authoritative path is
/// [DiagnosticSessionComposer.resolveLiveModel].
@riverpod
DiagnosticModel bcScoreLive(BcScoreLiveRef ref) =>
    ref.watch(diagnosticLiveModelProvider);

/// Snapshot saved on diagnostic submit — shown on dashboard.
@riverpod
class BcScoreSession extends _$BcScoreSession {
  @override
  DiagnosticSession? build() => null;

  void commit(DiagnosticSession session) {
    session.ensurePillarBoundCoherence();
    state = session;
    ref.read(diagnosticLocalRepositoryProvider).saveCommittedSession(session);
  }

  void clear() {
    state = null;
    ref.read(diagnosticLocalRepositoryProvider).clearCommittedSession();
  }
}
