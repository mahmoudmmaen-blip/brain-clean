import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Hardware-backed secure storage for Hive AES keys and app secrets.
abstract final class SecureKeyStore {
  SecureKeyStore._();

  static const _hiveKeyName = 'hive_aes_encryption_key_v1';
  static const _biometricLockKey = 'biometric_lock_enabled';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Uint8List? _hiveKeyCache;
  static HiveAesCipher? _cipherCache;

  /// Deterministic 256-bit key for `flutter test` / desktop CI (no keystore).
  static Uint8List? _testHiveKeyOverride;

  @visibleForTesting
  static void useTestHiveKey(Uint8List key) {
    assert(key.length == 32, 'Hive AES key must be 32 bytes');
    _testHiveKeyOverride = key;
    _hiveKeyCache = key;
    _cipherCache = HiveAesCipher(key);
  }

  @visibleForTesting
  static void resetForTesting() {
    _testHiveKeyOverride = null;
    _hiveKeyCache = null;
    _cipherCache = null;
  }

  static bool get _isFlutterTest =>
      const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

  /// Loads or creates the 256-bit Hive AES key (persisted base64url).
  static Future<Uint8List> getOrCreateHiveKey() async {
    if (_hiveKeyCache != null) return _hiveKeyCache!;

    if (_testHiveKeyOverride != null) {
      _hiveKeyCache = _testHiveKeyOverride;
      _cipherCache = HiveAesCipher(_hiveKeyCache!);
      return _hiveKeyCache!;
    }

    if (_isFlutterTest) {
      final generated = Uint8List.fromList(Hive.generateSecureKey());
      _hiveKeyCache = generated;
      _cipherCache = HiveAesCipher(generated);
      return generated;
    }

    try {
      final existing = await _storage.read(key: _hiveKeyName);
      if (existing != null && existing.isNotEmpty) {
        final decoded = base64Url.decode(existing);
        if (decoded.length == 32) {
          _hiveKeyCache = Uint8List.fromList(decoded);
          _cipherCache = HiveAesCipher(_hiveKeyCache!);
          return _hiveKeyCache!;
        }
      }
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore: read hive key failed: $error');
      debugPrint('$stackTrace');
    }

    final generated = Uint8List.fromList(Hive.generateSecureKey());
    _hiveKeyCache = generated;
    _cipherCache = HiveAesCipher(generated);

    try {
      await _storage.write(
        key: _hiveKeyName,
        value: base64Url.encode(generated),
      );
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore: persist hive key failed: $error');
      debugPrint('$stackTrace');
    }

    return generated;
  }

  /// AES cipher for [Hive.openBox] — call [getOrCreateHiveKey] first.
  static HiveAesCipher get cipher {
    final cached = _cipherCache;
    if (cached == null) {
      throw StateError(
        'SecureKeyStore.cipher used before getOrCreateHiveKey()',
      );
    }
    return cached;
  }

  static Future<void> write(String key, String value) async {
    if (_isFlutterTest) return;
    try {
      await _storage.write(key: key, value: value);
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore.write($key) failed: $error');
      debugPrint('$stackTrace');
    }
  }

  static Future<String?> read(String key) async {
    if (_isFlutterTest) return null;
    try {
      return await _storage.read(key: key);
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore.read($key) failed: $error');
      debugPrint('$stackTrace');
      return null;
    }
  }

  static Future<void> delete(String key) async {
    if (_isFlutterTest) return;
    try {
      await _storage.delete(key: key);
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore.delete($key) failed: $error');
      debugPrint('$stackTrace');
    }
  }

  static Future<bool> isBiometricLockEnabled() async {
    if (_isFlutterTest) return false;
    final raw = await read(_biometricLockKey);
    return raw == 'true';
  }

  static Future<void> setBiometricLockEnabled(bool enabled) async {
    if (enabled) {
      await write(_biometricLockKey, 'true');
    } else {
      await delete(_biometricLockKey);
    }
  }
}
