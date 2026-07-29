import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';
import '../constants/hive_meta_keys.dart';
import '../storage/hive_boxes.dart';

/// Local-only progress export (no cloud upload).
abstract final class LocalDataExport {
  LocalDataExport._();

  /// Builds a redacted JSON summary from open Hive boxes.
  static Map<String, Object?> buildSummaryMap() {
    final meta = Hive.isBoxOpen(HiveBoxes.appMeta)
        ? Hive.box<dynamic>(HiveBoxes.appMeta)
        : null;

    return <String, Object?>{
      'app': 'Brain Clean',
      'version': AppConfig.appVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'localOnly': true,
      'hasSeenOnboarding':
          meta?.get(HiveMetaKeys.hasSeenOnboarding, defaultValue: false),
      'profileDisplayName': meta?.get(HiveMetaKeys.profileDisplayName),
      'silenceWinsCount':
          meta?.get(HiveMetaKeys.silenceWinsCount, defaultValue: 0),
      'singleTasksCompletedCount':
          meta?.get(HiveMetaKeys.singleTasksCompletedCount, defaultValue: 0),
      'boxesPresent': HiveBoxes.allDurable
          .where(Hive.isBoxOpen)
          .toList(growable: false),
    };
  }

  static Future<bool> shareSummary() async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert(buildSummaryMap());
      await Share.share(json, subject: 'Brain Clean local summary');
      return true;
    } catch (error, stackTrace) {
      debugPrint('LocalDataExport.shareSummary failed: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }
}
