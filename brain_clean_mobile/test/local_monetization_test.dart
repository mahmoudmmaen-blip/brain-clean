import 'package:brain_clean_mobile/core/constants/revenue_cat_constants.dart';
import 'package:brain_clean_mobile/features/home/domain/daily_quotes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RevenueCat entitlement ids', () {
    test('canonical entitlement is pro with legacy alias', () {
      expect(RevenueCatConstants.proEntitlement, 'pro');
      expect(RevenueCatConstants.legacyProEntitlement, 'Brain Clean');
    });
  });

  group('Pro quote pool', () {
    test('free pool is smaller than full library', () {
      expect(freeQuotePoolSize, lessThan(dailyQuotes.length));
      final freeQuote = quoteForDate(DateTime(2026, 6, 1), isPro: false);
      final proQuote = quoteForDate(DateTime(2026, 6, 1), isPro: true);
      expect(dailyQuotes.contains(freeQuote), isTrue);
      expect(dailyQuotes.contains(proQuote), isTrue);
    });
  });

  group('Silence Pro durations', () {
    test('free durations stay within 5–20 minutes', () {
      const free = <int>[5, 10, 15, 20];
      const proOnly = <int>[30, 45, 60];
      expect(free.every((m) => m <= 20), isTrue);
      expect(proOnly.every((m) => m >= 30), isTrue);
      expect(
        {...free}.intersection({...proOnly}),
        isEmpty,
      );
    });
  });
}
