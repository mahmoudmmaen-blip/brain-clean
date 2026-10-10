import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'v3_state_providers.dart';

/// Cached onboarding flag for synchronous router redirects.
final v3OnboardingGateProvider =
    NotifierProvider<V3OnboardingGate, bool?>(V3OnboardingGate.new);

class V3OnboardingGate extends Notifier<bool?> {
  @override
  bool? build() => null;

  Future<void> hydrate() async {
    final repo = ref.read(v3StateRepositoryProvider);
    final state = await repo.load();
    this.state = state.profile?.onboardingDone ?? false;
  }

  void markOnboardingComplete() {
    state = true;
  }

  @visibleForTesting
  void setForTesting(bool value) {
    state = value;
  }
}
