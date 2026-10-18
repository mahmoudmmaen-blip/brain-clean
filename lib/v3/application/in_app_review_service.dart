import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../data/v3_state_repository.dart';
import '../domain/in_app_review_gate.dart';
import 'v3_state_providers.dart';

/// Abstraction so tests can fake Play In-App Review.
abstract class InAppReviewService {
  Future<bool> isAvailable();
  Future<void> requestReview();
}

class PlayInAppReviewService implements InAppReviewService {
  PlayInAppReviewService({InAppReview? review})
      : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();
}

/// Test double that records calls.
class FakeInAppReviewService implements InAppReviewService {
  FakeInAppReviewService({this.available = true});

  bool available;
  int requestCount = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requestCount++;
  }
}

final inAppReviewServiceProvider = Provider<InAppReviewService>(
  (ref) => PlayInAppReviewService(),
);

/// Request review once when [triggerMet], never mid-flow / paywall day.
Future<bool> maybeRequestInAppReview({
  required V3StateRepository repo,
  required InAppReviewService review,
  required bool triggerMet,
  DateTime? now,
}) async {
  final local = now ?? DateTime.now();
  final state = await repo.load();
  final paywallToday = InAppReviewGate.isSameLocalDay(
    state.lastPaywallShownDate,
    local,
  );
  if (!InAppReviewGate.shouldRequest(
    alreadyRequested: state.inAppReviewRequested,
    paywallShownToday: paywallToday,
    triggerMet: triggerMet,
  )) {
    return false;
  }
  if (!await review.isAvailable()) return false;
  await review.requestReview();
  await repo.setInAppReviewRequested(true);
  return true;
}
