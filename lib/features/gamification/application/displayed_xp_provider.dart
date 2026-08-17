import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/diagnostics/app_error_logger.dart';
import '../data/xp_ledger_repository_provider.dart';
import 'verified_xp_provider.dart';

part 'displayed_xp_provider.g.dart';

/// Cached authoritative server XP total (written after successful [verify-xp]).
@Riverpod(keepAlive: true)
int? serverTotalXp(ServerTotalXpRef ref) {
  try {
    return ref.watch(xpLedgerRepositoryProvider).readCachedServerTotalXp();
  } catch (error, stackTrace) {
    logAppError('serverTotalXp', error, stackTrace);
    return null;
  }
}

/// Displayed XP: prefer [serverTotalXp] when synced online, else local ledger sum.
///
/// Local XP is optimistic; server total wins for shared/competitive displays.
@Riverpod(keepAlive: true)
Future<int> displayedXp(DisplayedXpRef ref) async {
  final server = ref.watch(serverTotalXpProvider);
  if (server != null) return server;
  return ref.watch(verifiedTotalXpProvider.future);
}

/// Sync-friendly displayed XP for widgets.
@riverpod
int displayedXpSync(DisplayedXpSyncRef ref) {
  final server = ref.watch(serverTotalXpProvider);
  if (server != null) return server;
  return ref.watch(verifiedTotalXpSyncProvider);
}
