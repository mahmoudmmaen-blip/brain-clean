import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/daily_program_repository.dart';
import 'daily_program_repository_impl.dart';

part 'daily_program_repository_provider.g.dart';

@Riverpod(keepAlive: true)
DailyProgramRepository dailyProgramRepository(
  DailyProgramRepositoryRef ref,
) {
  return DailyProgramRepositoryImpl();
}
