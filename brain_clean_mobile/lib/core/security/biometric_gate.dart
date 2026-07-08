import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'secure_key_store.dart';

/// Local biometric / device-PIN gate for app entry.
abstract final class BiometricGate {
  BiometricGate._();

  static const _authReasonAr = 'افتح Brain Clean ببصمتك';

  static final LocalAuthentication _auth = LocalAuthentication();
  static bool _sessionAuthenticated = false;

  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return canCheck || supported;
    } on PlatformException catch (error) {
      debugPrint('BiometricGate.isAvailable failed: $error');
      return false;
    } catch (error) {
      debugPrint('BiometricGate.isAvailable failed: $error');
      return false;
    }
  }

  /// Returns `true` immediately when biometric lock is disabled.
  static Future<bool> authenticate() async {
    try {
      final enabled = await SecureKeyStore.isBiometricLockEnabled();
      if (!enabled) {
        _sessionAuthenticated = true;
        return true;
      }
      if (_sessionAuthenticated) return true;

      if (!await isAvailable()) return false;

      final ok = await _auth.authenticate(
        localizedReason: _authReasonAr,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (ok) _sessionAuthenticated = true;
      return ok;
    } on PlatformException catch (error) {
      debugPrint('BiometricGate.authenticate failed: $error');
      return false;
    } catch (error) {
      debugPrint('BiometricGate.authenticate failed: $error');
      return false;
    }
  }

  /// Clears sticky session — call on background / pause.
  static void lockSession() {
    _sessionAuthenticated = false;
  }

  /// Bypass biometric for the current app session only (e.g. after repeated failures).
  static void bypassForSession() {
    _sessionAuthenticated = true;
  }

  @visibleForTesting
  static void resetSessionForTesting() {
    _sessionAuthenticated = false;
  }
}
