import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-GCM backup envelope for the v3 Hive box (on-device only).
///
/// File body is UTF-8 JSON:
/// `{v,kdf,iter,salt,nonce,cipher}` with base64 binary fields.
abstract final class V3BackupCrypto {
  V3BackupCrypto._();

  static const formatVersion = 1;
  static const minPassphraseLength = 6;
  static const pbkdf2Iterations = 100000;
  static const saltLength = 16;
  static const nonceLength = 12;

  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: pbkdf2Iterations,
    bits: 256,
  );
  static final _aesGcm = AesGcm.with256bits();
  static final _random = Random.secure();

  static Uint8List _randomBytes(int length) {
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = _random.nextInt(256);
    }
    return out;
  }

  /// Encrypts [plaintextJson] with a key derived from [passphrase].
  static Future<String> encrypt({
    required String plaintextJson,
    required String passphrase,
  }) async {
    if (passphrase.length < minPassphraseLength) {
      throw ArgumentError(
        'Passphrase must be at least $minPassphraseLength characters',
      );
    }
    final salt = _randomBytes(saltLength);
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
    final nonce = _randomBytes(nonceLength);
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintextJson),
      secretKey: secretKey,
      nonce: nonce,
    );
    final cipherBytes = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    final envelope = <String, dynamic>{
      'v': formatVersion,
      'kdf': 'pbkdf2-hmac-sha256',
      'iter': pbkdf2Iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'cipher': base64Encode(cipherBytes),
    };
    return jsonEncode(envelope);
  }

  /// Decrypts a `.bcb` envelope. Throws [V3BackupException] on failure.
  static Future<String> decrypt({
    required String envelopeJson,
    required String passphrase,
  }) async {
    Map<String, dynamic> envelope;
    try {
      final decoded = jsonDecode(envelopeJson);
      if (decoded is! Map) {
        throw const V3BackupException('invalid_format');
      }
      envelope = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const V3BackupException('invalid_format');
    }

    final version = envelope['v'];
    if (version != formatVersion) {
      throw const V3BackupException('unsupported_version');
    }
    final iter = envelope['iter'];
    if (iter is! int || iter < 100000) {
      throw const V3BackupException('invalid_format');
    }
    final saltB64 = envelope['salt'];
    final nonceB64 = envelope['nonce'];
    final cipherB64 = envelope['cipher'];
    if (saltB64 is! String || nonceB64 is! String || cipherB64 is! String) {
      throw const V3BackupException('invalid_format');
    }

    late Uint8List salt;
    late Uint8List nonce;
    late Uint8List cipherAndMac;
    try {
      salt = base64Decode(saltB64);
      nonce = base64Decode(nonceB64);
      cipherAndMac = Uint8List.fromList(base64Decode(cipherB64));
    } catch (_) {
      throw const V3BackupException('invalid_format');
    }
    if (cipherAndMac.length <= 16) {
      throw const V3BackupException('invalid_format');
    }

    final pbkdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iter,
      bits: 256,
    );
    final secretKey = await pbkdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );

    final macBytes = cipherAndMac.sublist(cipherAndMac.length - 16);
    final cipherText = cipherAndMac.sublist(0, cipherAndMac.length - 16);
    try {
      final clear = await _aesGcm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes)),
        secretKey: secretKey,
      );
      return utf8.decode(clear);
    } catch (_) {
      throw const V3BackupException('wrong_passphrase');
    }
  }
}

class V3BackupException implements Exception {
  const V3BackupException(this.code);
  final String code;

  @override
  String toString() => 'V3BackupException($code)';
}
