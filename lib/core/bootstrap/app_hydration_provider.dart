import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/detox/presentation/detox_protocol_controller.dart';
import '../../features/diagnostic/data/diagnostic_local_repository_provider.dart';
import '../../features/diagnostic/data/diagnostic_repository_provider.dart';
import '../../features/diagnostic/domain/diagnostic_metrics.dart';
import '../../features/diagnostic/domain/diagnostic_session.dart';
import '../../features/diagnostic/presentation/bc_score_provider.dart';
import '../../features/diagnostic/presentation/diagnostic_controller.dart';
import '../../features/diagnostic/presentation/diagnostic_session_flow_provider.dart';
import '../../features/recovery/presentation/recovery_bc_penalty_provider.dart';
import '../../features/recovery/presentation/recovery_protocol_controller.dart';
import '../storage/hive_bootstrap.dart';

part 'app_hydration_provider.g.dart';

/// Result of cold-start hydration — drives splash routing.
class AppHydrationSnapshot {
  const AppHydrationSnapshot({
    required this.hasCommittedSession,
    required this.hasDraftProgress,
  });

  final bool hasCommittedSession;
  final bool hasDraftProgress;
}

/// Restores Hive + Riverpod state before the home or diagnostic routes mount.
@Riverpod(keepAlive: true)
class AppHydration extends _$AppHydration {
  @override
  Future<AppHydrationSnapshot> build() async => hydrateAll();

  Future<AppHydrationSnapshot> hydrateAll() async {
    await HiveBootstrap.warmUpPersistentBoxes();

    // Recovery grid (local-first).
    await ref.read(recoveryProtocolControllerProvider.future);

    final local = await ref.read(diagnosticLocalRepositoryProvider).loadBundle();

    var committed = local.committedSession;
    if (committed != null) {
      ref.read(bcScoreSessionProvider.notifier).commit(committed);
    }

    if (local.metrics != null) {
      ref
          .read(diagnosticControllerProvider.notifier)
          .restoreFromPersistence(local.metrics!);
    }

    if (local.questionnaire != null) {
      ref
          .read(diagnosticSessionFlowProvider.notifier)
          .restoreFromPersistence(local.questionnaire!);
    }

    committed = await _mergeRemoteSessionIfNewer(committed);
    if (committed != null) {
      ref.read(bcScoreSessionProvider.notifier).commit(committed);
    }

    await ref
        .read(recoveryDiagnosticPenaltySyncProvider.notifier)
        .syncFromRecoveryGrid();

    // Detox remote hydrate (non-blocking for routing).
    ref.read(detoxProtocolControllerProvider);

    return AppHydrationSnapshot(
      hasCommittedSession: ref.read(bcScoreSessionProvider) != null,
      hasDraftProgress: local.hasDraftProgress,
    );
  }

  Future<DiagnosticSession?> _mergeRemoteSessionIfNewer(
    DiagnosticSession? local,
  ) async {
    try {
      final remote =
          await ref.read(diagnosticRepositoryProvider).fetchLatest();
      if (remote == null) return local;

      if (local == null) {
        await ref
            .read(diagnosticLocalRepositoryProvider)
            .saveCommittedSession(remote);
        return remote;
      }

      if (remote.committedAt.isAfter(local.committedAt)) {
        await ref
            .read(diagnosticLocalRepositoryProvider)
            .saveCommittedSession(remote);
        return remote;
      }
    } catch (e) {
      debugPrint('AppHydration: remote diagnostic merge skipped: $e');
    }
    return local;
  }
}
