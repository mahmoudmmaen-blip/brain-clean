import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'biometric_gate.dart';
import 'root_detector.dart';
import 'secure_key_store.dart';

part 'security_status_provider.g.dart';

/// Whether the user passed biometric gate this session.
@Riverpod(keepAlive: true)
class BiometricSession extends _$BiometricSession {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}

/// Sync mirror of [SecureKeyStore.isBiometricLockEnabled] for GoRouter.
@Riverpod(keepAlive: true)
class BiometricLockSettings extends _$BiometricLockSettings {
  @override
  bool build() => false;

  Future<void> hydrate() async {
    state = await SecureKeyStore.isBiometricLockEnabled();
  }

  Future<bool> setEnabled(bool enabled) async {
    if (enabled && !await BiometricGate.isAvailable()) {
      return false;
    }
    await SecureKeyStore.setBiometricLockEnabled(enabled);
    state = enabled;
    if (!enabled) {
      ref.read(biometricSessionProvider.notifier).unlock();
      BiometricGate.lockSession();
    } else {
      ref.read(biometricSessionProvider.notifier).lock();
      BiometricGate.lockSession();
    }
    return true;
  }
}

/// Exposes [RootDetector.isCompromised] for banners and cloud-sync policy.
@Riverpod(keepAlive: true)
bool deviceCompromised(DeviceCompromisedRef ref) {
  return RootDetector.isCompromised;
}

/// Runs biometric auth and updates [biometricSessionProvider].
@Riverpod(keepAlive: true)
class BiometricAuthController extends _$BiometricAuthController {
  @override
  Future<bool> build() async => false;

  Future<bool> authenticate() async {
    final ok = await BiometricGate.authenticate();
    if (ok) {
      ref.read(biometricSessionProvider.notifier).unlock();
    }
    state = AsyncData(ok);
    return ok;
  }

  void lock() {
    BiometricGate.lockSession();
    ref.read(biometricSessionProvider.notifier).lock();
    state = const AsyncData(false);
  }
}
