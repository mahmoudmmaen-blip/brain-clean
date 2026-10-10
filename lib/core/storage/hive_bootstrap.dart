import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_meta_keys.dart';
import '../security/secure_key_store.dart';
import 'hive_boxes.dart';

/// Hive cold-start bootstrap for Brain Clean local-first persistence.
///
/// Durable boxes are opened with [SecureKeyStore.cipher] (AES-256).
/// Legacy unencrypted boxes are migrated once ([HiveMetaKeys.boxesEncryptedV1]).
abstract final class HiveBootstrap {
  static bool _initialized = false;

  /// Boxes opened at cold start (V3 + meta).
  static const List<String> _durableBoxes = [
    HiveBoxes.appMeta,
    HiveBoxes.v3State,
  ];

  /// Legacy V1/V2 box names kept only so migration can detect + delete them.
  static const List<String> legacyBoxNames = [
    HiveBoxes.recoveryProtocol,
    HiveBoxes.diagnosticPersistence,
    HiveBoxes.emotionLog,
    HiveBoxes.dailySnapshots,
    HiveBoxes.journeyData,
    HiveBoxes.journalSpaces,
    HiveBoxes.goldenMemories,
    HiveBoxes.xpLedger,
    HiveBoxes.brainCheck,
    HiveBoxes.brainProfile,
    HiveBoxes.recoveryPlan,
    HiveBoxes.v2Onboarding,
    HiveBoxes.dailySession,
    HiveBoxes.progress,
    HiveBoxes.weeklyReview,
    HiveBoxes.structuredDailyProgram,
  ];

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await SecureKeyStore.getOrCreateHiveKey();
    _initialized = true;
  }

  /// Clears every opened durable box. Used for confirmed account deletion.
  static Future<void> clearAllDurableBoxes() async {
    for (final name in _durableBoxes) {
      try {
        if (Hive.isBoxOpen(name)) {
          await Hive.box<dynamic>(name).clear();
        }
      } catch (error, stackTrace) {
        debugPrint('HiveBootstrap: failed to clear $name: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  /// True when any pre-V3 Hive box still exists on disk.
  static Future<bool> hasLegacyBoxes() async {
    for (final name in legacyBoxNames) {
      if (await Hive.boxExists(name)) return true;
    }
    return false;
  }

  /// Deletes legacy V1/V2 boxes after the one-time migration screen.
  static Future<void> deleteLegacyBoxes() async {
    for (final name in legacyBoxNames) {
      try {
        if (Hive.isBoxOpen(name)) {
          await Hive.box<dynamic>(name).close();
        }
        if (await Hive.boxExists(name)) {
          await Hive.deleteBoxFromDisk(name);
        }
      } catch (error, stackTrace) {
        debugPrint('HiveBootstrap: failed to delete legacy $name: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  /// Opens all durable boxes before UI hydration (cold-start safety).
  static Future<void> warmUpPersistentBoxes() async {
    await initialize();
    await _migrateUnencryptedBoxesIfNeeded();
    await Future.wait(_durableBoxes.map(_openEncryptedBox));
  }

  static Future<Box<dynamic>> _openEncryptedBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<dynamic>(name);
    return Hive.openBox<dynamic>(
      name,
      encryptionCipher: SecureKeyStore.cipher,
    );
  }

  /// One-time migration: read plaintext boxes → delete → reopen encrypted.
  static Future<void> _migrateUnencryptedBoxesIfNeeded() async {
    final cipher = SecureKeyStore.cipher;

    if (await _isEncryptionMigrationComplete(cipher)) {
      return;
    }

    debugPrint('HiveBootstrap: migrating durable boxes to AES encryption…');

    for (final name in _durableBoxes) {
      await _migrateSingleBox(name, cipher);
    }

    final meta = await _openEncryptedBox(HiveBoxes.appMeta);
    await meta.put(HiveMetaKeys.boxesEncryptedV1, true);
    debugPrint('HiveBootstrap: encryption migration complete.');
  }

  static Future<bool> _isEncryptionMigrationComplete(HiveAesCipher cipher) async {
    if (!await Hive.boxExists(HiveBoxes.appMeta)) {
      return false;
    }

    try {
      if (Hive.isBoxOpen(HiveBoxes.appMeta)) {
        await Hive.box(HiveBoxes.appMeta).close();
      }
      final encrypted = await Hive.openBox<dynamic>(
        HiveBoxes.appMeta,
        encryptionCipher: cipher,
      );
      final flag = encrypted.get(HiveMetaKeys.boxesEncryptedV1) == true;
      if (flag) return true;
      await encrypted.close();
    } catch (_) {
      // Fall through — likely still plaintext.
    }

    try {
      if (Hive.isBoxOpen(HiveBoxes.appMeta)) {
        await Hive.box(HiveBoxes.appMeta).close();
      }
      final plain = await Hive.openBox<dynamic>(HiveBoxes.appMeta);
      final flag = plain.get(HiveMetaKeys.boxesEncryptedV1) == true;
      await plain.close();
      return flag;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _migrateSingleBox(
    String name,
    HiveAesCipher cipher,
  ) async {
    final inProgressKey = 'hive_migration_v1_in_progress_$name';
    final backupPathKey = 'hive_migration_v1_backup_path_$name';

    final existingBackupPath = await SecureKeyStore.read(backupPathKey);
    if (!await Hive.boxExists(name) &&
        existingBackupPath != null &&
        existingBackupPath.isNotEmpty) {
      await _restoreBackupIfPresent(existingBackupPath);
    }

    if (!await Hive.boxExists(name)) return;

    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }

    try {
      final alreadyEncrypted =
          await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
      await alreadyEncrypted.close();
      await SecureKeyStore.delete(inProgressKey);
      await SecureKeyStore.delete(backupPathKey);
      return;
    } catch (_) {
      // Not yet encrypted — migrate below.
    }

    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }

    Map<dynamic, dynamic> entries;
    String? boxPath;
    try {
      final plain = await Hive.openBox<dynamic>(name);
      entries = Map<dynamic, dynamic>.from(plain.toMap());
      boxPath = plain.path;
      await plain.close();
    } catch (error, stackTrace) {
      debugPrint('HiveBootstrap: skip migrate $name (unreadable): $error');
      debugPrint('$stackTrace');
      return;
    }

    await SecureKeyStore.write(inProgressKey, 'true');

    final backupPath = (boxPath == null || boxPath.isEmpty)
        ? null
        : '$boxPath.plaintext_bak_v1';
    if (backupPath != null) {
      await SecureKeyStore.write(backupPathKey, backupPath);
      await _createBackupIfMissing(boxPath!, backupPath);
    }

    try {
      await Hive.deleteBoxFromDisk(name);
    } catch (error) {
      debugPrint('HiveBootstrap: deleteBoxFromDisk($name) failed: $error');
    }

    try {
      final encrypted = await Hive.openBox<dynamic>(
        name,
        encryptionCipher: cipher,
      );
      for (final entry in entries.entries) {
        await encrypted.put(entry.key, entry.value);
      }
      await encrypted.close();

      if (backupPath != null) {
        await _deleteFileIfExists(backupPath);
      }
      await SecureKeyStore.delete(inProgressKey);
      await SecureKeyStore.delete(backupPathKey);
    } catch (error, stackTrace) {
      debugPrint('HiveBootstrap: encrypted rewrite failed for $name: $error');
      debugPrint('$stackTrace');

      if (backupPath != null && boxPath != null) {
        await _restoreBackupIfPresent(backupPath, restoreTo: boxPath);
      }
      return;
    }
  }

  static Future<void> _createBackupIfMissing(
    String originalPath,
    String backupPath,
  ) async {
    try {
      final original = File(originalPath);
      if (!await original.exists()) return;
      final backup = File(backupPath);
      if (await backup.exists()) return;
      await original.copy(backupPath);
    } catch (error) {
      debugPrint('HiveBootstrap: backup create failed: $error');
    }
  }

  static Future<void> _restoreBackupIfPresent(
    String backupPath, {
    String? restoreTo,
  }) async {
    try {
      final backup = File(backupPath);
      if (!await backup.exists()) return;
      final inferredRestorePath = backupPath.endsWith('.plaintext_bak_v1')
          ? backupPath.substring(
              0,
              backupPath.length - '.plaintext_bak_v1'.length,
            )
          : null;
      final targetPath = (restoreTo != null && restoreTo.isNotEmpty)
          ? restoreTo
          : inferredRestorePath;
      if (targetPath == null) return;
      await backup.copy(targetPath);
    } catch (error) {
      debugPrint('HiveBootstrap: backup restore failed: $error');
    }
  }

  static Future<void> _deleteFileIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignore
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}
