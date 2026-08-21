import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'structured_daily_program_repository.dart';

final structuredDailyProgramRepositoryProvider =
    Provider<StructuredDailyProgramRepository>((ref) {
  return StructuredDailyProgramLocalRepository();
});
