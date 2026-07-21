import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../../pro/application/subscription_service_provider.dart';

part 'safa_trial_provider.g.dart';

const safaTrialDurationDays = 7;

/// Whether Safa chat is allowed without Pro (within the 7-day trial window).
bool isSafaTrialActive({
  required DateTime? firstUsedAt,
  required DateTime now,
}) {
  if (firstUsedAt == null) return true;
  return now.difference(firstUsedAt).inDays < safaTrialDurationDays;
}

/// Pro users always have access; otherwise the 7-day Safa trial applies.
bool computeSafaChatAccessAllowed({
  required bool isPro,
  required DateTime? firstUsedAt,
  required DateTime now,
}) {
  if (isPro) return true;
  return isSafaTrialActive(firstUsedAt: firstUsedAt, now: now);
}

DateTime? readSafaFirstUsedAtFromBox(dynamic box) {
  final raw = box.get(HiveMetaKeys.safaFirstUsedAt);
  if (raw is! String) return null;
  return DateTime.tryParse(raw);
}

@Riverpod(keepAlive: true)
class SafaTrialController extends _$SafaTrialController {
  @override
  void build() {}

  Future<void> recordFirstVisitIfNeeded() async {
    try {
      final box = ref.read(appMetaBoxProvider);
      if (box.get(HiveMetaKeys.safaFirstUsedAt) != null) return;
      await box.put(
        HiveMetaKeys.safaFirstUsedAt,
        DateTime.now().toUtc().toIso8601String(),
      );
      ref.invalidate(safaChatAccessAllowedProvider);
    } catch (_) {
      // Hive may be unavailable in tests; access check falls back safely.
    }
  }
}

@riverpod
bool safaChatAccessAllowed(SafaChatAccessAllowedRef ref) {
  final isPro = ref.watch(isProUserProvider);
  if (isPro) return true;

  try {
    final box = ref.watch(appMetaBoxProvider);
    final firstUsedAt = readSafaFirstUsedAtFromBox(box);
    return isSafaTrialActive(
      firstUsedAt: firstUsedAt,
      now: DateTime.now(),
    );
  } catch (_) {
    return true;
  }
}
