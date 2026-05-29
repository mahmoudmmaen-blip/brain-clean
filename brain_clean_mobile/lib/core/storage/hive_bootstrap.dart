import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';
import '../../features/recovery/data/adapters/recovery_day_record_adapter.dart';
import '../../features/recovery/data/adapters/recovery_protocol_state_adapter.dart';

/// Hive cold-start bootstrap for Brain Clean local-first persistence.
///
/// ## Warm-up sequencing (call from [main] before [runApp])
/// 1. [initialize] — `Hive.initFlutter()` once per process + register type adapters.
/// 2. [warmUpPersistentBoxes] — eagerly open every durable box so splash hydration
///    never races box creation on first read.
///
/// ## Box layout
/// | Box | Keys | Format |
/// |-----|------|--------|
/// | [HiveBoxes.recoveryProtocol] | `protocol_state` | camelCase JSON envelope via [RecoveryHivePayload]; legacy snake_case auto-migrated on read |
/// | [HiveBoxes.diagnosticPersistence] | `committed_session`, `draft_metrics`, `draft_questionnaire` | camelCase JSON maps normalized through [BhiPillarJsonKeys] |
///
/// ## Recovery fallback protocol
/// - **Missing key** → fresh [RecoveryProtocolState] seeded in the controller.
/// - **Legacy snake_case** → [RecoveryHivePayload.normalizeIncoming] + silent re-save as camelCase.
/// - **Corrupt / non-map payload** → key deleted, [RecoveryProtocolLoadResult.corrupt], UI starts fresh (non-fatal).
///
/// ## Diagnostic fallback protocol
/// - Parse failures log and return empty [DiagnosticLocalBundle] (never crash cold start).
/// - [Map<dynamic,dynamic>] from Hive is deep-cast to `Map<String,dynamic>` before JSON parsers run.
///
/// Windows non-ASCII install paths: pair with `android.overridePathCheck=true` in Gradle.
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
    await Future.wait([
      _openBoxIfNeeded(HiveBoxes.recoveryProtocol),
      _openBoxIfNeeded(HiveBoxes.diagnosticPersistence),
      _openBoxIfNeeded(HiveBoxes.emotionLog),
    ]);
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
