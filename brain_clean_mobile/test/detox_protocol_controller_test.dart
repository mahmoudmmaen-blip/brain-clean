import 'dart:async';
import 'dart:convert';

import 'package:brain_clean_mobile/core/constants/bc_score_constants.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_ai_coach_service.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_ai_coach_service_provider.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository_provider.dart';
import 'package:brain_clean_mobile/features/detox/domain/ai_coach/ai_coach_pipeline_response.dart';
import 'package:brain_clean_mobile/features/detox/domain/daily_check_in_input.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_habit_scorer.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_firestore.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_state.dart';
import 'package:brain_clean_mobile/features/detox/presentation/detox_ai_coach_insight_provider.dart';
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
    final payload = transformLocalMetricsToFirestorePayload(state);
    await upsertSnakeCasePayload(payload);
  }

  @override
  Future<DetoxProtocolState?> fetchLatest() async => stored;
}

/// Simulates a slow LLM backend to verify non-blocking AI integration.
class _SlowDetoxAiCoachBackend implements DetoxAiCoachBackend {
  _SlowDetoxAiCoachBackend({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  var completeCallCount = 0;

  @override
  Future<String> complete({
    required String system,
    required String user,
  }) async {
    completeCallCount++;
    await Future<void>.delayed(delay);
    return jsonEncode({
      'status': 'complete',
      'message': 'Background coaching ready.',
      'context': {
        'intent': 'detox_check_in',
        'action': 'continue_detox_protocol',
        'assembledVariables': {'bcScore': 70},
      },
    });
  }
}

/// Backend that always throws — habit sync must still succeed.
class _FailingDetoxAiCoachBackend implements DetoxAiCoachBackend {
  @override
  Future<String> complete({
    required String system,
    required String user,
  }) async {
    throw StateError('AI service unavailable');
  }
}

DetoxProtocolState readData(ProviderContainer container) =>
    container.read(detoxProtocolDataProvider);

Future<void> waitForControllerReady(ProviderContainer container) async {
  await container.read(detoxProtocolControllerProvider.future);
}

/// Verifies Firestore payload uses strictly snake_case keys with exact values.
void expectStrictSnakeCasePayload(
  Map<String, dynamic>? payload, {
  bool? boredom,
  int? delayed,
  bool? body,
}) {
  expect(payload, isNotNull);
  DetoxFirestorePayload.assertSnakeCaseOnly(payload!);
  expect(payload.keys, DetoxFirestorePayload.allowedHabitKeys);

  expect(payload.containsKey('boredom_befriended'), isTrue);
  expect(payload.containsKey('delayed_gratification_count'), isTrue);
  expect(payload.containsKey('body_activated'), isTrue);

  expect(payload.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel),
      isFalse);
  expect(
      payload.containsKey(DiagnosticModelJsonKeys.delayedGratificationCountCamel),
      isFalse);
  expect(payload.containsKey(DiagnosticModelJsonKeys.bodyActivatedCamel), isFalse);

  if (boredom != null) expect(payload['boredom_befriended'], boredom);
  if (delayed != null) expect(payload['delayed_gratification_count'], delayed);
  if (body != null) expect(payload['body_activated'], body);
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
      expectStrictSnakeCasePayload(
        fakeRepository.lastSnakeCasePayload,
        boredom: true,
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
        expectStrictSnakeCasePayload(
          fakeRepository.lastSnakeCasePayload,
          boredom: true,
          delayed: 7,
          body: true,
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

    test(
      'processDailyCheckIn completes immediately while AI coaching runs in background',
      () async {
        final slowBackend = _SlowDetoxAiCoachBackend();
        container.dispose();
        container = ProviderContainer(
          overrides: [
            detoxProtocolRepositoryProvider.overrideWithValue(fakeRepository),
            detoxAiCoachServiceProvider.overrideWithValue(
              DetoxAiCoachService(backend: slowBackend),
            ),
          ],
        );
        await waitForControllerReady(container);
        container.listen(
          detoxAiCoachInsightProvider,
          (_, __) {},
          fireImmediately: true,
        );

        final stopwatch = Stopwatch()..start();
        await container
            .read(detoxProtocolControllerProvider.notifier)
            .processDailyCheckIn(
              const DailyCheckInInput(boredomBefriended: true),
              requestAiCoaching: true,
            );
        stopwatch.stop();

        // Firestore path only — must not wait for the 400ms AI delay.
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 300)));
        expect(readData(container).boredomBefriended, isTrue);
        expect(
          container.read(detoxProtocolControllerProvider).hasValue,
          isTrue,
        );

        // Background AI resolves after the check-in method returned.
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(slowBackend.completeCallCount, 1);

        AiCoachPipelineResponse? insight;
        for (var i = 0; i < 20; i++) {
          final async = container.read(detoxAiCoachInsightProvider);
          if (async.hasValue && async.value is AiCoachCompleteResponse) {
            insight = async.value;
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        expect(insight, isA<AiCoachCompleteResponse>());
      },
    );

    test(
      'processDailyCheckIn succeeds when AI coaching fails in background',
      () async {
        container.dispose();
        container = ProviderContainer(
          overrides: [
            detoxProtocolRepositoryProvider.overrideWithValue(fakeRepository),
            detoxAiCoachServiceProvider.overrideWithValue(
              DetoxAiCoachService(backend: _FailingDetoxAiCoachBackend()),
            ),
          ],
        );
        await waitForControllerReady(container);

        await container
            .read(detoxProtocolControllerProvider.notifier)
            .processDailyCheckIn(
              const DailyCheckInInput(bodyActivated: true),
              requestAiCoaching: true,
            );

        expect(readData(container).bodyActivated, isTrue);
        expect(
          container.read(detoxProtocolControllerProvider).hasError,
          isFalse,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final insight = container.read(detoxAiCoachInsightProvider);
        expect(insight.hasError, isFalse);
        expect(insight.value, isNull);
      },
    );

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
