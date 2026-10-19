import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/v3_backup_codec.dart';
import '../data/v3_backup_crypto.dart';
import '../data/v3_state_repository.dart';

/// Export / import encrypted `.bcb` backups of the v3 box.
class V3BackupService {
  V3BackupService(this._repo);

  final V3StateRepository _repo;

  /// Encrypts the box and opens the system share sheet for the `.bcb` file.
  Future<File> exportToShareFile({required String passphrase}) async {
    final dump = await _repo.dumpBox();
    final plaintext = V3BackupCodec.encodePayload(dump);
    final envelope = await V3BackupCrypto.encrypt(
      plaintextJson: plaintext,
      passphrase: passphrase,
    );
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
    final file = File('${dir.path}/brainclean-backup-$stamp.bcb');
    await file.writeAsString(envelope, flush: true);
    try {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/octet-stream')],
        subject: 'Brain Clean backup',
      );
    } catch (e, st) {
      debugPrint('V3BackupService.share failed: $e\n$st');
    }
    return file;
  }

  /// Decrypts [fileBytes] and replaces the v3 box. Does not mutate on error.
  Future<void> importFromBytes({
    required List<int> fileBytes,
    required String passphrase,
  }) async {
    final envelope = utf8.decode(fileBytes);
    final plaintext = await V3BackupCrypto.decrypt(
      envelopeJson: envelope,
      passphrase: passphrase,
    );
    final box = V3BackupCodec.decodePayload(plaintext);
    await _repo.replaceAll(box);
  }
}
