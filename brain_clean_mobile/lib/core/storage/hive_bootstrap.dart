import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Initializes Hive once for the app lifecycle (supports non-ASCII paths on Windows
/// when combined with [android.overridePathCheck] in Gradle).
abstract final class HiveBootstrap {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  /// Test-only: reset guard so each test file can call [initialize] with a temp dir.
  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}
