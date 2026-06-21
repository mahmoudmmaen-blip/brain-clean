import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'recovery_protocol_hive_repository.dart';
import 'recovery_protocol_storage.dart';

part 'recovery_protocol_storage_provider.g.dart';

@Riverpod(keepAlive: true)
RecoveryProtocolStorage recoveryProtocolStorage(RecoveryProtocolStorageRef ref) {
  return RecoveryProtocolHiveRepository();
}
