import 'package:brain_clean_mobile/features/safa_tab/application/safa_trial_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Safa trial access', () {
    final firstUsed = DateTime.utc(2026, 1, 1);

    test('Pro users always have access', () {
      expect(
        computeSafaChatAccessAllowed(
          isPro: true,
          firstUsedAt: firstUsed,
          now: DateTime.utc(2026, 2, 1),
        ),
        isTrue,
      );
    });

    test('trial active when firstUsedAt is null', () {
      expect(
        computeSafaChatAccessAllowed(
          isPro: false,
          firstUsedAt: null,
          now: DateTime.utc(2026, 2, 1),
        ),
        isTrue,
      );
    });

    test('trial active within 7 days', () {
      expect(
        computeSafaChatAccessAllowed(
          isPro: false,
          firstUsedAt: firstUsed,
          now: DateTime.utc(2026, 1, 7),
        ),
        isTrue,
      );
    });

    test('trial expired after 7 days', () {
      expect(
        computeSafaChatAccessAllowed(
          isPro: false,
          firstUsedAt: firstUsed,
          now: DateTime.utc(2026, 1, 8),
        ),
        isFalse,
      );
    });
  });
}
