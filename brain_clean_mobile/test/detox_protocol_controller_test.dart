import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository_provider.dart';
import 'package:brain_clean_mobile/features/detox/domain/daily_check_in_input.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_habit_scorer.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_firestore.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_state.dart';
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_controller.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDetoxRepository extends DetoxProtocolRepository {
  _FakeDetoxRepository();

  DetoxProtocolState? stored;
  Map<String, dynamic>? lastSnakeCasePayload;
  int upsertCallCount = 0;
  bool shouldThrowOnUpsert = false;

  @override
  Future<void> upsertSnakeCasePayload(Map<String, dynamic> payload) async {
    DetoxFirestorePayload.assertSnakeCaseOnly(payload);
    upsertCallCount++;
    lastSnakeCasePayload = payload;
    if (shouldThrowOnUpsert) {
      throw DetoxProtocolSyncException('Sync failed');
    }
    stored = DetoxProtocolState.fromDailyCheckIn(
      current: const DetoxProtocolState(),
      checkIn: DailyCheckInInput(
        boredomBefriended:
            payload[DetoxFirestorePayload.boredomBefriended] as bool?,
        delayedGratificationCount:
            payload[DetoxFirestorePayload.delayedGratificationCount] as int?,
        bodyActivated: payload[DetoxFirestorePayload.bodyActivated] as bool?,
      ),
    );
  }

  @override
  Future<void> upsert(DetoxProtocolState state) async {
    await upsertSnakeCasePayload(state.toFirestoreHabitPayload());
  }

  @override
  Future<DetoxProtocolState?> fetchLatest() async => stored;
}

DetoxProtocolState readData(ProviderContainer container) =>
    container.read(detoxProtocolDataProvider);

Future<void> waitForControllerReady(ProviderContainer container) async {
  await container.read(detoxProtocolControllerProvider.future);
}

/// Verifies Firestore payload uses strictly snake_case habit keys.
void expectStrictSnakeCasePayload(Map<String, dynamic>? payload) {
  expect(payload, isNotNull);
  DetoxFirestorePayload.assertSnakeCaseOnly(payload!);
  expect(payload.keys, DetoxFirestorePayload.allowedHabitKeys);

  // Literal snake_case strings required by Firestore.
  expect(payload.containsKey('boredom_befriended'), isTrue);
  expect(payload.containsKey('delayed_gratification_count'), isTrue);
  expect(payload.containsKey('body_activated'), isTrue);

  // No camelCase aliases from DiagnosticModel.
  expect(payload.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel),
      isFalse);
  expect(
      payload.containsKey(DiagnosticModelJsonKeys.delayedGratificationCountCamel),
      isFalse);
  expect(payload.containsKey(DiagnosticModelJsonKeys.bodyActivatedCamel), isFalse);
}

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

    test('starts with default habit values after AsyncNotifier build', () async {
      await waitForControllerReady(container);

      final data = readData(container);
      expect(data.boredomBefriended, isFalse);
      expect(data.delayedGratificationCount, 0);
      expect(data.bodyActivated, isFalse);
      expect(data.detoxHabitScore, 0);
      expect(container.read(detoxProtocolControllerProvider).hasValue, isTrue);
    });

    test('setBoredomBefriended updates state and persists snake_case payload',
        () async {
      await waitForControllerReady(container);

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .setBoredomBefriended(true);

      final data = readData(container);
      expect(data.boredomBefriended, isTrue);
      expectStrictSnakeCasePayload(fakeRepository.lastSnakeCasePayload);
      expect(
        fakeRepository.lastSnakeCasePayload![DetoxFirestorePayload.boredomBefriended],
        isTrue,
      );
    });

    test('recordDelayedGratificationWin increments count up to protocol cap',
        () async {
      await waitForControllerReady(container);
      final notifier = container.read(detoxProtocolControllerProvider.notifier);

      for (var i = 0; i < 8; i++) {
        await notifier.recordDelayedGratificationWin();
      }

      expect(readData(container).delayedGratificationCount, 7);
    });

    test('loadFromRemote hydrates controller from repository', () async {
      await waitForControllerReady(container);

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
      await waitForControllerReady(container);
      fakeRepository.shouldThrowOnUpsert = true;

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .setBodyActivated(true);

      final asyncState = container.read(detoxProtocolControllerProvider);
      expect(readData(container).bodyActivated, isTrue);
      expect(asyncState.hasError, isTrue);
      expect(asyncState.error, isA<DetoxProtocolSyncException>());
      expect(asyncState.error.toString(), 'Sync failed');
    });

    // Logic Verification: snake_case Firestore payload + DetoxHabitScorer local score.
    test(
      'processDailyCheckIn writes strict snake_case payload and updates local habit score',
      () async {
        await waitForControllerReady(container);

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

        // Local habit score recalculated via DetoxHabitScorer.
        expect(
          data.detoxHabitScore,
          DetoxHabitScorer.detoxHabitScore(
            boredomBefriended: true,
            delayedGratificationCount: 7,
            bodyActivated: true,
          ),
        );
        expect(data.detoxHabitScore, 100.0);

        // Firestore payload strictly snake_case — no camelCase keys.
        expect(fakeRepository.upsertCallCount, 1);
        expectStrictSnakeCasePayload(fakeRepository.lastSnakeCasePayload);
        expect(
          fakeRepository.lastSnakeCasePayload![
              DetoxFirestorePayload.boredomBefriended],
          isTrue,
        );
        expect(
          fakeRepository.lastSnakeCasePayload![
              DetoxFirestorePayload.delayedGratificationCount],
          7,
        );
        expect(
          fakeRepository.lastSnakeCasePayload![DetoxFirestorePayload.bodyActivated],
          isTrue,
        );

        // Reconciled with server — final AsyncValue is data.
        final finalState = container.read(detoxProtocolControllerProvider);
        expect(finalState.hasValue, isTrue);

        // BC_score reflects updated habits.
        final live = container.read(bcScoreLiveProvider);
        expect(live.boredomBefriended, isTrue);
        expect(live.delayedGratificationCount, 7);
        expect(live.bodyActivated, isTrue);
        expect(live.healthyHabits, greaterThan(0));
      },
    );

    test('processDailyCheckIn error transition preserves optimistic data',
        () async {
      await waitForControllerReady(container);
      fakeRepository.shouldThrowOnUpsert = true;

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .processDailyCheckIn(
            const DailyCheckInInput(bodyActivated: true),
          );

      final asyncState = container.read(detoxProtocolControllerProvider);
      expect(asyncState.hasError, isTrue);
      expect(readData(container).bodyActivated, isTrue);
    });

    test('processDailyCheckIn clamps delayed count to protocol maximum',
        () async {
      await waitForControllerReady(container);

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

    test('DetoxFirestorePayload rejects camelCase keys', () {
      expect(
        () => DetoxFirestorePayload.assertSnakeCaseOnly({
          DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        }),
        throwsArgumentError,
      );
    });

    test(
      'repository transformation layer converts camelCase metrics to snake_case',
      () {
        const state = DetoxProtocolState(
          boredomBefriended: true,
          delayedGratificationCount: 4,
          bodyActivated: false,
          detoxHabitScore: 50,
        );

        final payload = DetoxFirestorePayload.transformToSnakeCase(
          state: state,
          metrics: {
            DiagnosticModelJsonKeys.boredomBefriendedCamel: false,
            DiagnosticModelJsonKeys.delayedGratificationCountCamel: 9,
            DiagnosticModelJsonKeys.bodyActivatedCamel: true,
          },
        );

        expectStrictSnakeCasePayload(payload);
        expect(payload['boredom_befriended'], isFalse);
        expect(payload['delayed_gratification_count'], 9);
        expect(payload['body_activated'], isTrue);
      },
    );
  });
}
