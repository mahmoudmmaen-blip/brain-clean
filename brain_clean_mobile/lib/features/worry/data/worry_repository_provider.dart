import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/worry_repository.dart';
import 'worry_repository_impl.dart';

part 'worry_repository_provider.g.dart';

@Riverpod(keepAlive: true)
WorryRepository worryRepository(WorryRepositoryRef ref) {
  return WorryRepositoryImpl();
}
