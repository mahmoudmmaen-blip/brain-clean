import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_meta_keys.dart';
import '../security/secure_key_store.dart';
import 'hive_boxes.dart';
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
  ];

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await SecureKeyStore.getOrCreateHiveKey();
    _registerRecoveryAdapters();
    _registerDashboardAdapters();
    _registerProModulesAdapters();
    _initialized = true;
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
    if (!await Hive.boxExists(name)) return;

    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }

    try {
      await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
      return;
    } catch (_) {
      // Not yet encrypted — migrate below.
    }

    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }

    Map<dynamic, dynamic> entries;
    try {
      final plain = await Hive.openBox<dynamic>(name);
      entries = Map<dynamic, dynamic>.from(plain.toMap());
      await plain.close();
    } catch (error, stackTrace) {
      debugPrint('HiveBootstrap: skip migrate $name (unreadable): $error');
      debugPrint('$stackTrace');
      return;
    }

    try {
      await Hive.deleteBoxFromDisk(name);
    } catch (error) {
      debugPrint('HiveBootstrap: deleteBoxFromDisk($name) failed: $error');
    }

    final encrypted = await Hive.openBox<dynamic>(
      name,
      encryptionCipher: cipher,
    );
    for (final entry in entries.entries) {
      await encrypted.put(entry.key, entry.value);
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

  static void _registerProModulesAdapters() {
    // Pro module adapters register here when models land.
  }

  @visibleForTesting
  static void registerRecoveryAdaptersForTests() {
    _registerRecoveryAdapters();
    _registerDashboardAdapters();
    _registerProModulesAdapters();
  }

  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}
