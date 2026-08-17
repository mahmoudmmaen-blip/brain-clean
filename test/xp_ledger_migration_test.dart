import 'dart:typed_data';

import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/security/secure_key_store.dart';
import 'package:brain_clean_mobile/features/dashboard/data/daily_snapshots_repository.dart';
import 'package:brain_clean_mobile/features/dashboard/domain/daily_snapshot.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_constants.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_migration.dart';
import 'package:brain_clean_mobile/features/gamification/data/xp_ledger_repository.dart';
import 'package:brain_clean_mobile/features/gamification/domain/xp_source.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox ledgerBox;
  late InMemoryHiveBox metaBox;
  late InMemoryHiveBox snapshotsBox;
  late XpLedgerRepository ledger;
  late DailySnapshotsRepository snapshots;

  setUp(() {
    SecureKeyStore.resetForTesting();
    SecureKeyStore.useTestXpSigningKey(Uint8List.fromList(List.filled(32, 3)));
    SecureKeyStore.useTestDeviceId('test-device-migration');
    ledgerBox = InMemoryHiveBox();
    metaBox = InMemoryHiveBox();
    snapshotsBox = InMemoryHiveBox();
    ledger = XpLedgerRepository(ledgerBox: ledgerBox, metaBox: metaBox);
    snapshots = DailySnapshotsRepository(snapshotsBox);
  });

  Future<void> seedSnapshots(List<double> bcsValues) async {
    var day = 1;
    for (final value in bcsValues) {
      await snapshots.save(
        DailySnapshot(date: DateTime.utc(2026, 3, day), bcsValue: value),
      );
      day++;
    }
  }

  Future<void> migrate() => XpLedgerMigration.migrateIfNeeded(
        metaBox: metaBox,
        ledger: ledger,
        snapshots: snapshots,
      );

  test('seeds the ledger with the rounded cumulative snapshot total', () async {
    await seedSnapshots([10.4, 20.6, 30]);

    await migrate();

    expect(await ledger.verifiedTotalXp(), 61);
    expect(metaBox.get(HiveMetaKeys.xpLedgerMigratedV1), isTrue);
    final entries = ledgerBox.values.toList();
    expect(entries, hasLength(1));
    expect(entries.single.source, XpSource.other);
    expect(entries.single.refId, XpLedgerConstants.legacyMigrationRefId);
  });

  test('marks migration done without an entry when there is no legacy XP',
      () async {
    await migrate();

    expect(metaBox.get(HiveMetaKeys.xpLedgerMigratedV1), isTrue);
    expect(ledgerBox.values, isEmpty);
  });

  test('is idempotent — a second run appends nothing', () async {
    await seedSnapshots([50]);

    await migrate();
    await migrate();

    expect(ledgerBox.values, hasLength(1));
    expect(await ledger.verifiedTotalXp(), 50);
  });

  test('skips entirely when the migrated flag is already set', () async {
    await seedSnapshots([50]);
    await metaBox.put(HiveMetaKeys.xpLedgerMigratedV1, true);

    await migrate();

    expect(ledgerBox.values, isEmpty);
  });

  test('tolerates a duplicate legacy ref already present in the ledger',
      () async {
    await seedSnapshots([40]);
    await ledger.append(
      XpSource.other,
      40,
      refId: XpLedgerConstants.legacyMigrationRefId,
    );

    await migrate();

    expect(ledgerBox.values, hasLength(1));
    expect(metaBox.get(HiveMetaKeys.xpLedgerMigratedV1), isTrue);
  });
}
