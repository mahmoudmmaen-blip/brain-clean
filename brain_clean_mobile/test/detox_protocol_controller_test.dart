import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository_provider.dart';
import 'package:brain_clean_mobile/features/detox/domain/daily_check_in_input.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_habit_scorer.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_state.dart';
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_controller.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDetoxRepository extends DetoxProtocolRepository {
  _FakeDetoxRepository();

  DetoxProtocolState? stored;
  bool shouldThrowOnUpsert = false;

  @override
  Future<void> upsert(DetoxProtocolState state) async {
    if (shouldThrowOnUpsert) {
      throw DetoxProtocolSyncException('Sync failed');
    }
    stored = state;
  }

  @override
  Future<DetoxProtocolState?> fetchLatest() async => stored;
}

DetoxProtocolState readData(ProviderContainer container) =>
    container.read(detoxProtocolDataProvider);

void main() {
  group('DetoxProtocolController', () {
    late _FakeDetoxRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = _FakeDetoxRepository();
      container = ProviderContainer(
        overrides: [
          detoxProtocolRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('starts with default habit values', () {
      final data = readData(container);
      expect(data.boredomBefriended, isFalse);
      expect(data.delayedGratificationCount, 0);
      expect(data.bodyActivated, isFalse);
      expect(data.detoxHabitScore, 0);
    });

    test('setBoredomBefriended updates state and persists snake_case payload',
        () async {
      await container
          .read(detoxProtocolControllerProvider.notifier)
          .setBoredomBefriended(true);

      final data = readData(container);
      expect(data.boredomBefriended, isTrue);
      expect(fakeRepository.stored?.boredomBefriended, isTrue);
    });

    test('recordDelayedGratificationWin increments count up to protocol cap',
        () async {
      final notifier = container.read(detoxProtocolControllerProvider.notifier);

      for (var i = 0; i < 8; i++) {
        await notifier.recordDelayedGratificationWin();
      }

      expect(readData(container).delayedGratificationCount, 7);
    });

    test('loadFromRemote hydrates controller from repository', () async {
      fakeRepository.stored = DetoxProtocolState.fromDailyCheckIn(
        current: const DetoxProtocolState(),
        checkIn: const DailyCheckInInput(
          boredomBefriended: true,
          delayedGratificationCount: 3,
          bodyActivated: true,
        ),
      );

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .loadFromRemote();

      final data = readData(container);
      expect(data.boredomBefriended, isTrue);
      expect(data.delayedGratificationCount, 3);
      expect(data.bodyActivated, isTrue);
      expect(container.read(detoxProtocolControllerProvider).hasValue, isTrue);
    });

    test('persist failure surfaces user-friendly sync error via AsyncValue',
        () async {
      fakeRepository.shouldThrowOnUpsert = true;

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .setBodyActivated(true);

      final asyncState = container.read(detoxProtocolControllerProvider);
      expect(readData(container).bodyActivated, isTrue);
      expect(asyncState.hasError, isTrue);
      expect(asyncState.error, 'Sync failed');
    });

    // Logic Verification: DetoxHabitScorer runs before state commit and bcScoreLive refreshes.
    test(
      'processDailyCheckIn recalculates detoxHabitScore and refreshes bcScoreLive',
      () async {
        await container
            .read(detoxProtocolControllerProvider.notifier)
            .processDailyCheckIn(
              const DailyCheckInInput(
                boredomBefriended: true,
                delayedGratificationCount: 7,
                bodyActivated: true,
              ),
            );

        final data = readData(container);
        expect(
          data.detoxHabitScore,
          DetoxHabitScorer.detoxHabitScore(
            boredomBefriended: true,
            delayedGratificationCount: 7,
            bodyActivated: true,
          ),
        );
        expect(data.detoxHabitScore, 100.0);

        final live = container.read(bcScoreLiveProvider);
        expect(live.boredomBefriended, isTrue);
        expect(live.delayedGratificationCount, 7);
        expect(live.bodyActivated, isTrue);
        expect(live.healthyHabits, greaterThan(0));

        expect(
          container.read(detoxProtocolControllerProvider).requireValue,
          data,
        );
      },
    );

    test('processDailyCheckIn clamps delayed count to protocol maximum', () async {
      await container
          .read(detoxProtocolControllerProvider.notifier)
          .processDailyCheckIn(
            const DailyCheckInInput(delayedGratificationCount: 99),
          );

      expect(
        readData(container).delayedGratificationCount,
        BcScoreConstants.maxDelayedGratificationCount,
      );
    });
  });
}
