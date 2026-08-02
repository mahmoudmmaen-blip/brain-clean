import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_meta_keys.dart';
import '../security/secure_key_store.dart';
import 'hive_boxes.dart';
import '../../features/gamification/data/adapters/xp_ledger_entry_adapter.dart';
import '../../features/gamification/data/xp_ledger_repository.dart';
import '../../features/gamification/data/xp_ledger_migration.dart';
import '../../features/dashboard/data/daily_snapshots_repository.dart';
import '../../features/dashboard/domain/daily_snapshot.dart';
import '../../features/recovery/data/adapters/recovery_day_record_adapter.dart';
import '../../features/recovery/data/adapters/recovery_protocol_state_adapter.dart';

/// Hive cold-start bootstrap for Brain Clean local-first persistence.
///
/// All durable boxes are opened with [SecureKeyStore.cipher] (AES-256).
/// Legacy unencrypted boxes are migrated once ([HiveMetaKeys.boxesEncryptedV1]).
abstract final class HiveBootstrap {
  static bool _initialized = false;

  static const List<String> _durableBoxes = [
    HiveBoxes.recoveryProtocol,
    HiveBoxes.diagnosticPersistence,
    HiveBoxes.emotionLog,
    HiveBoxes.dailySnapshots,
    HiveBoxes.appMeta,
    HiveBoxes.journeyData,
    HiveBoxes.journalSpaces,
    HiveBoxes.goldenMemories,
    HiveBoxes.xpLedger,
    HiveBoxes.brainCheck,
  ];

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await SecureKeyStore.getOrCreateHiveKey();
    _registerRecoveryAdapters();
    _registerDashboardAdapters();
    _registerGamificationAdapters();
    _registerProModulesAdapters();
    _initialized = true;
  }

  /// Opens all durable boxes before UI hydration (cold-start safety).
  static Future<void> warmUpPersistentBoxes() async {
    await initialize();
    await _migrateUnencryptedBoxesIfNeeded();
    await Future.wait(_durableBoxes.map(_openEncryptedBox));
    await _migrateXpLedgerIfNeeded();
  }

  static Future<void> _migrateXpLedgerIfNeeded() async {
    try {
      final meta = Hive.box<dynamic>(HiveBoxes.appMeta);
      final ledgerBox = Hive.box<dynamic>(HiveBoxes.xpLedger);
      final snapshotsBox = Hive.box<dynamic>(HiveBoxes.dailySnapshots);
      await XpLedgerMigration.migrateIfNeeded(
        metaBox: meta,
        ledger: XpLedgerRepository(
          ledgerBox: ledgerBox,
          metaBox: meta,
        ),
        snapshots: DailySnapshotsRepository(snapshotsBox),
      );
    } catch (error, stackTrace) {
      debugPrint('HiveBootstrap: XP ledger migration skipped: $error');
      debugPrint('$stackTrace');
    }
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

    // If a previous run crashed after making a backup, restore it first.
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

    // Mark migration started before touching disk.
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

      // Best-effort restore to plaintext so we don't strand user data.
      if (backupPath != null && boxPath != null) {
        await _restoreBackupIfPresent(backupPath, restoreTo: boxPath);
      }
      // Do not crash startup — leave box plaintext; next run can retry.
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

  static void _registerDashboardAdapters() {
    if (!Hive.isAdapterRegistered(DailySnapshotAdapter().typeId)) {
      Hive.registerAdapter(DailySnapshotAdapter());
    }
  }

  static void _registerRecoveryAdapters() {
    if (!Hive.isAdapterRegistered(RecoveryDayRecordAdapter().typeId)) {
      Hive.registerAdapter(RecoveryDayRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(RecoveryProtocolStateAdapter().typeId)) {
      Hive.registerAdapter(RecoveryProtocolStateAdapter());
    }
  }

  static void _registerGamificationAdapters() {
    if (!Hive.isAdapterRegistered(XpLedgerEntryAdapter().typeId)) {
      Hive.registerAdapter(XpLedgerEntryAdapter());
    }
  }

  static void _registerProModulesAdapters() {
    // Pro module adapters register here when models land.
  }

  @visibleForTesting
  static void registerRecoveryAdaptersForTests() {
    _registerRecoveryAdapters();
    _registerDashboardAdapters();
    _registerGamificationAdapters();
    _registerProModulesAdapters();
  }

  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}
