import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/v3_state_repository.dart';

final v3StateRepositoryProvider = Provider<V3StateRepository>((ref) {
  return V3StateLocalRepository();
});

final v3AppStateProvider = FutureProvider((ref) async {
  return ref.watch(v3StateRepositoryProvider).load();
});
