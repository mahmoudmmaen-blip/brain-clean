import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'detox_protocol_repository.dart';

part 'detox_protocol_repository_provider.g.dart';

@riverpod
DetoxProtocolRepository detoxProtocolRepository(DetoxProtocolRepositoryRef ref) {
  return DetoxProtocolRepository();
}
