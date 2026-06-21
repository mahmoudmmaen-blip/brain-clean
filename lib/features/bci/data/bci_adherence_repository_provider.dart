import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../recovery/data/recovery_protocol_storage_provider.dart';
import '../domain/repositories/bci_adherence_repository.dart';
import 'bci_adherence_hive_repository.dart';

part 'bci_adherence_repository_provider.g.dart';

@Riverpod(keepAlive: true)
BciAdherenceRepository bciAdherenceRepository(BciAdherenceRepositoryRef ref) {
  final storage = ref.watch(recoveryProtocolStorageProvider);
  return BciAdherenceHiveRepository(storage: storage);
}
