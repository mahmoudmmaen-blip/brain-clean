import 'dart:typed_data';

import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/security/secure_key_store.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/features/gamification/data/adapters/xp_ledger_entry_adapter.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_repository.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_server_verdict.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_source.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_sync_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox ledgerBox;
  late InMemoryHiveBox metaBox;
  late XpLedgerRepository repo;

  setUpAll(() {
    HiveBootstrap.registerRecoveryAdaptersForTests();
    if (!Hive.isAdapterRegistered(XpLedgerEntryAdapter().typeId)) {
      Hive.registerAdapter(XpLedgerEntryAdapter());
    }
  });

  setUp(() {
    SecureKeyStore.resetForTesting();
    SecureKeyStore.useTestXpSigningKey(Uint8List.fromList(List.filled(32, 7)));
    SecureKeyStore.useTestDeviceId('test-device-sync');
    ledgerBox = InMemoryHiveBox();
    metaBox = InMemoryHiveBox();
    repo = XpLedgerRepository(ledgerBox: ledgerBox, metaBox: metaBox);
  });

  group('applyServerVerdicts', () {
    test('marks entries verified or rejected from server response', () async {
      final a = await repo.append(XpSource.game, 5, refId: 'pattern_match:1');
      final b = await repo.append(XpSource.game, 3, refId: 'pattern_match:2');

      await repo.applyServerVerdicts([
        (id: a.id, accepted: true),
        (id: b.id, accepted: false),
      ]);

      final entries = repo.allEntries();
      final entryA = entries.firstWhere((e) => e.id == a.id);
      final entryB = entries.firstWhere((e) => e.id == b.id);
      expect(entryA.syncState, XpSyncState.verified);
      expect(entryB.syncState, XpSyncState.rejected);
    });

    test('persistServerTotalXp caches authoritative total in meta', () async {
      await repo.persistServerTotalXp(420);
      expect(repo.readCachedServerTotalXp(), 420);
      expect(metaBox.get(HiveMetaKeys.serverTotalXpSyncedAt), isNotNull);
    });
  });

  group('XpServerVerdict', () {
    test('parses accepted and rejected statuses', () {
      final accepted = XpServerVerdict.fromJson({
        'id': 'abc',
        'status': 'accepted',
      });
      final rejected = XpServerVerdict.fromJson({
        'id': 'def',
        'status': 'rejected',
        'reason': 'daily_cap_exceeded',
      });
      expect(accepted.accepted, isTrue);
      expect(rejected.accepted, isFalse);
      expect(rejected.reason, 'daily_cap_exceeded');
    });
  });
}
