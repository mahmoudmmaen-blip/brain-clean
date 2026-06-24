import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/xp_ledger_repository_provider.dart';
import '../domain/xp_rejected.dart';
import '../domain/xp_source.dart';

part 'verified_xp_provider.g.dart';

/// Verified XP total — derived sum over the signed append-only ledger.
@Riverpod(keepAlive: true)
class VerifiedTotalXp extends _$VerifiedTotalXp {
  @override
  Future<int> build() async {
    return ref.read(xpLedgerRepositoryProvider).verifiedTotalXp();
  }

  /// Awards XP through the ledger and refreshes the derived total.
  Future<bool> award({
    required XpSource source,
    required int amount,
    String? refId,
  }) async {
    if (amount <= 0) return false;
    try {
      await ref.read(xpLedgerRepositoryProvider).append(
            source,
            amount,
            refId: refId,
          );
      ref.invalidateSelf();
      return true;
    } on XpRejected catch (e) {
      debugPrint('VerifiedTotalXp.award rejected: $e');
      return false;
    } catch (e) {
      debugPrint('VerifiedTotalXp.award failed: $e');
      return false;
    }
  }
}

/// Sync-friendly XP for widgets — defaults to 0 while loading.
@riverpod
int verifiedTotalXpSync(VerifiedTotalXpSyncRef ref) {
  return ref.watch(verifiedTotalXpProvider).maybeWhen(
        data: (value) => value,
        orElse: () => 0,
      );
}
