import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../dashboard/data/daily_snapshots_repository.dart';
import '../level_system.dart';
import '../domain/xp_rejected.dart';
import '../domain/xp_source.dart';
import 'xp_ledger_constants.dart';
import 'xp_ledger_repository.dart';

/// One-time migration: seed ledger from cumulative daily-snapshot BCS sum.
abstract final class XpLedgerMigration {
  XpLedgerMigration._();

  static Future<void> migrateIfNeeded({
    required Box<dynamic> metaBox,
    required XpLedgerRepository ledger,
    required DailySnapshotsRepository snapshots,
  }) async {
    if (metaBox.get(HiveMetaKeys.xpLedgerMigratedV1) == true) {
      return;
    }

    try {
      final legacyTotal = cumulativeScoreFromSnapshots(
        snapshots.loadAll().map((s) => s.bcsValue),
      );

      if (legacyTotal > 0) {
        try {
          await ledger.append(
            XpSource.other,
            legacyTotal,
            refId: XpLedgerConstants.legacyMigrationRefId,
          );
        } on XpRejected catch (e) {
          if (e.reason != XpRejectReason.duplicateRef) {
            debugPrint('XpLedgerMigration: legacy append failed: $e');
            return;
          }
        }
      }

      await metaBox.put(HiveMetaKeys.xpLedgerMigratedV1, true);
      debugPrint(
        'XpLedgerMigration: complete (legacyTotal=$legacyTotal)',
      );
    } catch (error, stackTrace) {
      debugPrint('XpLedgerMigration failed: $error');
      debugPrint('$stackTrace');
    }
  }
}
