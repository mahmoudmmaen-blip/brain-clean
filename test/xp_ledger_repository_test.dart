import 'dart:typed_data';

import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/security/secure_key_store.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/features/gamification/data/adapters/xp_ledger_entry_adapter.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_constants.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_repository.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_signing.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_ledger_entry.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_rejected.dart';
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
    SecureKeyStore.useTestDeviceId('test-device-ledger');
    ledgerBox = InMemoryHiveBox();
    metaBox = InMemoryHiveBox();
    repo = XpLedgerRepository(ledgerBox: ledgerBox, metaBox: metaBox);
  });

  group('XpLedgerSigning', () {
    test('verify passes for a legitimately signed entry', () async {
      final entry = await repo.append(XpSource.game, 5, refId: 'pattern_match:1');
      expect(await XpLedgerSigning.verify(entry), isTrue);
    });

    test('verify fails when signature is tampered', () async {
      final entry = await repo.append(XpSource.game, 5, refId: 'pattern_match:2');
      final tampered = entry.copyWith(amount: 999, signature: entry.signature);
      expect(await XpLedgerSigning.verify(tampered), isFalse);
    });
  });

  group('verifiedTotalXp', () {
    test('excludes tampered entries from total', () async {
      await repo.append(XpSource.focusSession, 10, refId: 'a');
      final good = await repo.append(XpSource.focusSession, 5, refId: 'b');
      await ledgerBox.put(
        good.id,
        good.copyWith(amount: 500, signature: good.signature),
      );
      expect(await repo.verifiedTotalXp(), 10);
    });
  });

  group('append guards', () {
    test('rejects duplicate source+refId (idempotency)', () async {
      await repo.append(
        XpSource.diagnostic,
        5,
        refId: 'visual_cognitive_2026-06-24',
      );
      await expectLater(
        repo.append(
          XpSource.diagnostic,
          5,
          refId: 'visual_cognitive_2026-06-24',
        ),
        throwsA(
          isA<XpRejected>().having(
            (e) => e.reason,
            'reason',
            XpRejectReason.duplicateRef,
          ),
        ),
      );
    });

    test('rejects clock rollback vs high-water mark', () async {
      await repo.append(XpSource.other, 1, refId: 'seed');
      final mark = metaBox.get(HiveMetaKeys.xpLedgerHighWaterMarkUtc) as String;
      final rolledBack = DateTime.parse(mark).subtract(const Duration(hours: 1));
      await expectLater(
        repo.append(
          XpSource.other,
          1,
          refId: 'rollback',
          createdAtUtc: rolledBack,
        ),
        throwsA(
          isA<XpRejected>().having(
            (e) => e.reason,
            'reason',
            XpRejectReason.clockRollback,
          ),
        ),
      );
    });

    test('rejects per-source daily cap', () async {
      final day = DateTime.utc(2026, 6, 24, 12);
      await repo.append(
        XpSource.focusSession,
        30,
        refId: 'focus_cap_1',
        createdAtUtc: day,
      );
      await repo.append(
        XpSource.focusSession,
        30,
        refId: 'focus_cap_2',
        createdAtUtc: day,
      );
      await repo.append(
        XpSource.focusSession,
        30,
        refId: 'focus_cap_3',
        createdAtUtc: day,
      );
      await repo.append(
        XpSource.focusSession,
        30,
        refId: 'focus_cap_4',
        createdAtUtc: day,
      );
      await expectLater(
        repo.append(
          XpSource.focusSession,
          1,
          refId: 'focus_cap_5',
          createdAtUtc: day.add(const Duration(minutes: 1)),
        ),
        throwsA(
          isA<XpRejected>().having(
            (e) => e.reason,
            'reason',
            XpRejectReason.dailyCapExceeded,
          ),
        ),
      );
    });

    test('rejects implausible game XP', () async {
      await expectLater(
        repo.append(
          XpSource.game,
          500,
          refId: 'pattern_match:implausible',
        ),
        throwsA(
          isA<XpRejected>().having(
            (e) => e.reason,
            'reason',
            XpRejectReason.implausibleAmount,
          ),
        ),
      );
    });
  });

  group('legacy migration ref', () {
    test('legacy_migration entry is signed and counted', () async {
      final entry = await repo.append(
        XpSource.other,
        250,
        refId: XpLedgerConstants.legacyMigrationRefId,
      );
      expect(entry.syncState, XpSyncState.pendingVerify);
      expect(await repo.verifiedTotalXp(), 250);
    });
  });
}
