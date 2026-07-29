import 'package:brain_clean_mobile/core/ads/ad_visibility.dart';
import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdVisibility (Safe Footer Banner RC)', () {
    test('shows banner for free users on normal shell routes', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.exercises,
        AppRoutes.journey,
        AppRoutes.more,
        AppRoutes.settings,
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(isPro: false, location: location),
          isTrue,
          reason: location,
        );
      }
    });

    test('hides banner for Pro users everywhere', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.exercises,
        AppRoutes.more,
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(isPro: true, location: location),
          isFalse,
          reason: location,
        );
      }
    });

    test('hides banner on paywall, Safa, and focus flows', () {
      for (final location in [
        AppRoutes.proPaywall,
        AppRoutes.safa,
        '${AppRoutes.safa}/emotion-oasis',
        AppRoutes.singleTask,
        '/home/silence-challenge/3',
        AppRoutes.dailyProgram,
        AppRoutes.dayEnd,
        AppRoutes.sukoon,
        AppRoutes.pomodoro,
        AppRoutes.recovery,
        '${AppRoutes.exercises}/games',
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(isPro: false, location: location),
          isFalse,
          reason: location,
        );
      }
    });
  });
}
