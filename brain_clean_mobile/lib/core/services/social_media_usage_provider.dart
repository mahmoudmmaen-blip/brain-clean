import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'social_media_usage_service.dart';

part 'social_media_usage_provider.g.dart';

/// Snapshot of today's tracked social-app foreground time (Android only).
class SocialMediaUsageSnapshot {
  const SocialMediaUsageSnapshot({
    required this.hasAccess,
    required this.totalMinutes,
    required this.minutesByPackage,
  });

  final bool hasAccess;
  final int totalMinutes;
  final Map<String, int> minutesByPackage;

  static const empty = SocialMediaUsageSnapshot(
    hasAccess: false,
    totalMinutes: 0,
    minutesByPackage: {},
  );
}

@Riverpod(keepAlive: true)
SocialMediaUsageService socialMediaUsageService(SocialMediaUsageServiceRef ref) {
  return SocialMediaUsageService();
}

@riverpod
class SocialMediaUsage extends _$SocialMediaUsage {
  @override
  Future<SocialMediaUsageSnapshot> build() async {
    final service = ref.read(socialMediaUsageServiceProvider);
    // Play v1: feature deferred — never query Usage Access from Home.
    if (!service.isHomeCardEnabled) {
      return SocialMediaUsageSnapshot.empty;
    }
    return _load();
  }

  Future<void> refresh() async {
    final service = ref.read(socialMediaUsageServiceProvider);
    if (!service.isHomeCardEnabled) return;
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> openUsageAccessSettings() async {
    final service = ref.read(socialMediaUsageServiceProvider);
    if (!service.isHomeCardEnabled) return;
    await service.openUsageAccessSettings();
  }

  Future<SocialMediaUsageSnapshot> _load() async {
    final service = ref.read(socialMediaUsageServiceProvider);
    final hasAccess = await service.hasUsageAccess();
    if (!hasAccess) {
      return SocialMediaUsageSnapshot.empty;
    }
    final minutesByPackage = await service.getTodaySocialMediaUsage();
    final total = minutesByPackage.values.fold<int>(0, (sum, m) => sum + m);
    return SocialMediaUsageSnapshot(
      hasAccess: true,
      totalMinutes: total,
      minutesByPackage: minutesByPackage,
    );
  }
}
