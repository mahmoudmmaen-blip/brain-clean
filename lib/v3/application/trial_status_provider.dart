import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/pro/application/subscription_service_provider.dart';
import '../../features/pro/domain/subscription_plan.dart';
import '../domain/trial_status.dart';
import 'v3_state_providers.dart';

/// Injectable clock for trial-ending window checks (tests override).
final trialStatusNowProvider = Provider<DateTime>((ref) => DateTime.now());

/// Trial window + yearly price for the Today "trial ends soon" sheet.
///
/// Override in tests with a fixed [TrialStatus] (fake CustomerInfo).
final trialStatusProvider = FutureProvider<TrialStatus>((ref) async {
  final repo = ref.watch(v3StateRepositoryProvider);
  final app = await repo.load();
  final service = ref.watch(subscriptionServiceProvider);

  var isTrial = false;
  DateTime? expiresAt;
  String? yearlyPrice;

  try {
    await service.ensureInitialized();
    final snap = await service.loadCustomerSnapshot();
    if (snap != null) {
      isTrial = snap.isTrialPeriod;
      expiresAt = snap.expirationDate;
    }
  } catch (_) {}

  try {
    final plans = await service.loadOfferings();
    for (final p in plans) {
      if (p.period == SubscriptionPeriod.annual) {
        yearlyPrice = p.priceString;
        break;
      }
    }
  } catch (_) {}

  return TrialStatus(
    isTrialPeriod: isTrial,
    expiresAt: expiresAt,
    yearlyPriceString: yearlyPrice,
    endingNoticeShownKey: app.trialEndingNoticeKey,
  );
});
