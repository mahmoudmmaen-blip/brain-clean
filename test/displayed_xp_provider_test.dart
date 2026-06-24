import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/features/gamification/application/displayed_xp_provider.dart';
import 'package:brain_clean_mobile/features/gamification/application/verified_xp_provider.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_repository.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  group('displayedXpSync', () {
    test('prefers server total when cached', () {
      final meta = InMemoryHiveBox({
        HiveMetaKeys.serverTotalXp: 500,
      });
      final ledger = InMemoryHiveBox();
      final repo = XpLedgerRepository(ledgerBox: ledger, metaBox: meta);

      final container = ProviderContainer(
        overrides: [
          xpLedgerRepositoryProvider.overrideWithValue(repo),
          verifiedTotalXpSyncProvider.overrideWith((ref) => 120),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(displayedXpSyncProvider), 500);
    });

    test('falls back to local verified total when server absent', () {
      final meta = InMemoryHiveBox();
      final ledger = InMemoryHiveBox();
      final repo = XpLedgerRepository(ledgerBox: ledger, metaBox: meta);

      final container = ProviderContainer(
        overrides: [
          xpLedgerRepositoryProvider.overrideWithValue(repo),
          verifiedTotalXpSyncProvider.overrideWith((ref) => 120),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(serverTotalXpProvider), isNull);
      expect(container.read(displayedXpSyncProvider), 120);
    });
  });
}
