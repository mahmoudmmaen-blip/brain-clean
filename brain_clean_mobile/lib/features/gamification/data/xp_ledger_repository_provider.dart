import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/data/app_meta_box_provider.dart';
import '../../../core/storage/hive_boxes.dart';
import '../data/xp_ledger_repository.dart';

final xpLedgerBoxProvider = Provider<Box<dynamic>>((ref) {
  if (!Hive.isBoxOpen(HiveBoxes.xpLedger)) {
    throw StateError('Hive box ${HiveBoxes.xpLedger} is not open');
  }
  return Hive.box<dynamic>(HiveBoxes.xpLedger);
});

final xpLedgerRepositoryProvider = Provider<XpLedgerRepository>((ref) {
  return XpLedgerRepository(
    ledgerBox: ref.watch(xpLedgerBoxProvider),
    metaBox: ref.watch(appMetaBoxProvider),
  );
});
