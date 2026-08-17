import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_session_repository.dart';

final dailySessionRepositoryProvider = Provider<DailySessionRepository>((ref) {
  return DailySessionLocalRepository();
});
