import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';
import '../../features/recovery/data/adapters/recovery_day_record_adapter.dart';
import '../../features/recovery/data/adapters/recovery_protocol_state_adapter.dart';

/// Initializes Hive once for the app lifecycle (supports non-ASCII paths on Windows
/// when combined with [android.overridePathCheck] in Gradle).
abstract final class HiveBootstrap {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerRecoveryAdapters();
    _initialized = true;
  }

  /// Opens all durable boxes before UI hydration (cold-start safety).
  static Future<void> warmUpPersistentBoxes() async {
    await initialize();
    await _openBoxIfNeeded(HiveBoxes.recoveryProtocol);
    await _openBoxIfNeeded(HiveBoxes.diagnosticPersistence);
  }

  static Future<Box<dynamic>> _openBoxIfNeeded(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<dynamic>(name);
    return Hive.openBox<dynamic>(name);
  }

  static void _registerRecoveryAdapters() {
    if (!Hive.isAdapterRegistered(RecoveryDayRecordAdapter().typeId)) {
      Hive.registerAdapter(RecoveryDayRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(RecoveryProtocolStateAdapter().typeId)) {
      Hive.registerAdapter(RecoveryProtocolStateAdapter());
    }
  }

  /// Test-only: register adapters against a custom [Hive.init] path.
  @visibleForTesting
  static void registerRecoveryAdaptersForTests() {
    _registerRecoveryAdapters();
  }

  /// Test-only: reset guard so each test file can call [initialize] with a temp dir.
  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}
