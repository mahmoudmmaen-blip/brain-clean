import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Hardware-backed secure storage for Hive AES keys and app secrets.
abstract final class SecureKeyStore {
  SecureKeyStore._();

  static const _hiveKeyName = 'hive_aes_encryption_key_v1';
  static const _xpSigningKeyName = 'xp_signing_key_v1';
  static const _deviceIdKey = 'device_id_v1';
  static const _biometricLockKey = 'biometric_lock_enabled';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Uint8List? _hiveKeyCache;
  static Uint8List? _xpSigningKeyCache;
  static String? _deviceIdCache;
  static HiveAesCipher? _cipherCache;

  /// Deterministic 256-bit key for `flutter test` / desktop CI (no keystore).
  static Uint8List? _testHiveKeyOverride;
  static Uint8List? _testXpSigningKeyOverride;
  static String? _testDeviceIdOverride;

  @visibleForTesting
  static void useTestHiveKey(Uint8List key) {
    assert(key.length == 32, 'Hive AES key must be 32 bytes');
    _testHiveKeyOverride = key;
    _hiveKeyCache = key;
    _cipherCache = HiveAesCipher(key);
  }

  @visibleForTesting
  static void useTestXpSigningKey(Uint8List key) {
    assert(key.length == 32, 'XP signing key must be 32 bytes');
    _testXpSigningKeyOverride = key;
    _xpSigningKeyCache = key;
  }

  @visibleForTesting
  static void useTestDeviceId(String id) {
    assert(id.isNotEmpty, 'device id must not be empty');
    _testDeviceIdOverride = id;
    _deviceIdCache = id;
  }

  @visibleForTesting
  static void resetForTesting() {
    _testHiveKeyOverride = null;
    _testXpSigningKeyOverride = null;
    _testDeviceIdOverride = null;
    _hiveKeyCache = null;
    _xpSigningKeyCache = null;
    _deviceIdCache = null;
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

  /// Loads or creates the 256-bit HMAC key for XP ledger signing.
  ///
  /// Client-side HMAC is tamper-evident, not tamper-proof — see [XpLedgerSigning].
  static Future<Uint8List> getOrCreateXpSigningKey() async {
    if (_xpSigningKeyCache != null) return _xpSigningKeyCache!;

    if (_testXpSigningKeyOverride != null) {
      _xpSigningKeyCache = _testXpSigningKeyOverride;
      return _xpSigningKeyCache!;
    }

    if (_isFlutterTest) {
      final generated = Uint8List.fromList(Hive.generateSecureKey());
      _xpSigningKeyCache = generated;
      return generated;
    }

    try {
      final existing = await _storage.read(key: _xpSigningKeyName);
      if (existing != null && existing.isNotEmpty) {
        final decoded = base64Url.decode(existing);
        if (decoded.length == 32) {
          _xpSigningKeyCache = Uint8List.fromList(decoded);
          return _xpSigningKeyCache!;
        }
      }
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore: read XP signing key failed: $error');
      debugPrint('$stackTrace');
    }

    final generated = Uint8List.fromList(Hive.generateSecureKey());
    _xpSigningKeyCache = generated;

    try {
      await _storage.write(
        key: _xpSigningKeyName,
        value: base64Url.encode(generated),
      );
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore: persist XP signing key failed: $error');
      debugPrint('$stackTrace');
    }

    return generated;
  }

  /// Random app-scoped device id (not a hardware identifier — privacy-safe).
  static Future<String> getOrCreateDeviceId() async {
    if (_deviceIdCache != null) return _deviceIdCache!;

    if (_testDeviceIdOverride != null) {
      _deviceIdCache = _testDeviceIdOverride;
      return _deviceIdCache!;
    }

    if (_isFlutterTest) {
      _deviceIdCache = 'test-device-id';
      return _deviceIdCache!;
    }

    try {
      final existing = await _storage.read(key: _deviceIdKey);
      if (existing != null && existing.isNotEmpty) {
        _deviceIdCache = existing;
        return existing;
      }
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore: read device id failed: $error');
      debugPrint('$stackTrace');
    }

    final generated = const Uuid().v4();
    _deviceIdCache = generated;

    try {
      await _storage.write(key: _deviceIdKey, value: generated);
    } catch (error, stackTrace) {
      debugPrint('SecureKeyStore: persist device id failed: $error');
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
