import 'package:brain_clean_mobile/core/services/social_media_usage_provider.dart';
import 'package:brain_clean_mobile/core/services/social_media_usage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocialMediaUsage provider (Play v1)', () {
    test('does not load usage when Home card is Play-gated off', () async {
      final container = ProviderContainer(
        overrides: [
          socialMediaUsageServiceProvider.overrideWithValue(
            SocialMediaUsageService(platformIsAndroid: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(SocialMediaUsageService.isPlayFeatureEnabled, isFalse);

      final snapshot = await container.read(socialMediaUsageProvider.future);
      expect(snapshot.hasAccess, isFalse);
      expect(snapshot.totalMinutes, 0);
      expect(snapshot.minutesByPackage, isEmpty);
    });

    test('refresh is a no-op when Home card is gated off', () async {
      final container = ProviderContainer(
        overrides: [
          socialMediaUsageServiceProvider.overrideWithValue(
            SocialMediaUsageService(platformIsAndroid: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(socialMediaUsageProvider.future);
      await container.read(socialMediaUsageProvider.notifier).refresh();

      final snapshot = container.read(socialMediaUsageProvider).requireValue;
      expect(snapshot, SocialMediaUsageSnapshot.empty);
    });
  });
}
