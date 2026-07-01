import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

/// Root / jailbreak detection — warn-only policy (never blocks startup).
abstract final class RootDetector {
  RootDetector._();

  static bool isCompromised = false;

  /// Sets [isCompromised]; never throws.
  static Future<void> checkAndFlag() async {
    try {
      final jailbroken = await FlutterJailbreakDetection.jailbroken;
      final developerMode = await FlutterJailbreakDetection.developerMode;
      isCompromised = jailbroken || developerMode;
      if (isCompromised) {
        debugPrint(
          'RootDetector: compromised device '
          '(jailbroken=$jailbroken, developerMode=$developerMode)',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('RootDetector.checkAndFlag failed: $error');
      debugPrint('$stackTrace');
      isCompromised = false;
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    isCompromised = false;
  }
}
