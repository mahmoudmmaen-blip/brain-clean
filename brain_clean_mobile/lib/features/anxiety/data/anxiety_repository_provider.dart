import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/anxiety_repository.dart';
import 'anxiety_repository_impl.dart';

part 'anxiety_repository_provider.g.dart';

@Riverpod(keepAlive: true)
AnxietyRepository anxietyRepository(AnxietyRepositoryRef ref) {
  return AnxietyRepositoryImpl();
}
