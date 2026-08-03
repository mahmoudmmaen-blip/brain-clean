import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'weekly_review_repository.dart';

final weeklyReviewRepositoryProvider = Provider<WeeklyReviewRepository>((ref) {
  return WeeklyReviewLocalRepository();
});
