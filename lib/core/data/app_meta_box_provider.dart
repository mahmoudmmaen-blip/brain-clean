import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';

final appMetaBoxProvider = Provider<Box<dynamic>>((ref) {
  if (!Hive.isBoxOpen(HiveBoxes.appMeta)) {
    throw StateError('Hive box ${HiveBoxes.appMeta} is not open');
  }
  return Hive.box<dynamic>(HiveBoxes.appMeta);
});
