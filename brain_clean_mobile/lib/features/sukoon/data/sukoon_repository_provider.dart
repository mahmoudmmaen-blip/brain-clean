import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/sukoon_repository.dart';
import 'sukoon_repository_impl.dart';

part 'sukoon_repository_provider.g.dart';

@Riverpod(keepAlive: true)
SukoonRepository sukoonRepository(SukoonRepositoryRef ref) {
  return SukoonRepositoryImpl();
}
