import 'package:hive/hive.dart';

import '../constants/hive_meta_keys.dart';
import 'hive_boxes.dart';

/// Clears all durable Hive user data while preserving encryption infra.
///
/// Does **not** delete [SecureKeyStore] keys (Hive AES / XP signing / device id).
/// After clearing [HiveBoxes.appMeta], re-writes [HiveMetaKeys.boxesEncryptedV1]
/// so the next warm-up does not re-run plaintext→AES migration on empty boxes.
abstract final class AppDataReset {
  /// Box names cleared by "Reset all data". Matches [HiveBoxes.allDurable].
  static List<String> get targetBoxNames => List.unmodifiable(HiveBoxes.allDurable);

  /// Clears every open durable box. Skips boxes that are not open.
  ///
  /// Returns the list of box names that were cleared.
  static Future<List<String>> clearAllOpenDurableBoxes() async {
    final cleared = <String>[];
    for (final name in HiveBoxes.allDurable) {
      if (!Hive.isBoxOpen(name)) continue;
      await Hive.box<dynamic>(name).clear();
      cleared.add(name);
    }

    if (Hive.isBoxOpen(HiveBoxes.appMeta)) {
      await Hive.box<dynamic>(HiveBoxes.appMeta).put(
            HiveMetaKeys.boxesEncryptedV1,
            true,
          );
    }

    return cleared;
  }
}
