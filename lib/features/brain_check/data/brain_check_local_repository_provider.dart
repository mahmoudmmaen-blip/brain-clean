import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brain_check_local_repository.dart';

final brainCheckLocalRepositoryProvider =
    Provider<BrainCheckLocalRepository>((ref) {
  return BrainCheckLocalRepository();
});
