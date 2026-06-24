import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/security/root_detector.dart';
import '../../../core/services/connectivity_service.dart';
import '../data/xp_ledger_repository_provider.dart';
import '../data/xp_sync_api.dart';
import 'displayed_xp_provider.dart';
import 'verified_xp_provider.dart';

part 'xp_sync_service.g.dart';

@Riverpod(keepAlive: true)
XpSyncApi xpSyncApi(XpSyncApiRef ref) => const XpSyncApi();

/// Pushes [XpSyncState.pendingVerify] entries to [verify-xp] and reconciles totals.
///
/// Offline-first: failures leave entries pending; never blocks the user.
@Riverpod(keepAlive: true)
class XpSyncService extends _$XpSyncService {
  @override
  Future<void> build() async {}

  /// Sync when online + authenticated; no-op otherwise.
  Future<bool> syncIfPossible() async {
    if (RootDetector.isCompromised) return false;
    if (!ref.read(connectivityOnlineProvider)) return false;

    final repo = ref.read(xpLedgerRepositoryProvider);
    final pending = await repo.pendingVerifyEntries();
    if (pending.isEmpty) {
      return false;
    }

    final api = ref.read(xpSyncApiProvider);
    if (!api.hasAuthenticatedSession) return false;

    final response = await api.verifyEntries(pending);
    if (response == null) return false;

    await repo.applyServerVerdicts(
      response.verdicts.map(
        (v) => (id: v.id, accepted: v.accepted),
      ),
    );
    await repo.persistServerTotalXp(response.serverTotalXp);

    ref.invalidate(serverTotalXpProvider);
    ref.invalidate(verifiedTotalXpProvider);
    ref.invalidate(displayedXpProvider);

    if (response.verdicts.any((v) => !v.accepted)) {
      debugPrint(
        'XpSyncService: ${response.verdicts.where((v) => !v.accepted).length} '
        'entries rejected server-side (subtle local exclusion)',
      );
    }

    return true;
  }
}
