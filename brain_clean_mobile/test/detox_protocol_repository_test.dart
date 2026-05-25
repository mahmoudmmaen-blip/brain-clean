import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_firestore.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_state.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures transformed payloads without hitting Supabase.
class _CapturingRepository extends DetoxProtocolRepository {
  Map<String, dynamic>? lastTransformedPayload;

  @override
  Future<void> upsert(DetoxProtocolState state) async {
    lastTransformedPayload = transformLocalMetricsToFirestorePayload(state);
  }

  @override
  Future<void> upsertSnakeCasePayload(Map<String, dynamic> payload) async {
    lastTransformedPayload = transformLocalMetricsToFirestorePayload(
      _stateFromPayload(payload),
    );
  }

  DetoxProtocolState _stateFromPayload(Map<String, dynamic> payload) {
    final boredom = payload.containsKey('boredom_befriended')
        ? payload['boredom_befriended'] as bool
        : payload[DiagnosticModelJsonKeys.boredomBefriendedCamel] as bool? ??
            false;
    final delayed = payload.containsKey('delayed_gratification_count')
        ? (payload['delayed_gratification_count'] as num).toInt()
        : (payload[DiagnosticModelJsonKeys.delayedGratificationCountCamel]
                as num?)
            ?.toInt() ??
            0;
    final body = payload.containsKey('body_activated')
        ? payload['body_activated'] as bool
        : payload[DiagnosticModelJsonKeys.bodyActivatedCamel] as bool? ?? false;

    return DetoxProtocolState(
      boredomBefriended: boredom,
      delayedGratificationCount: delayed,
      bodyActivated: body,
    );
  }
}

/// Strict Firestore payload validation — keys must be snake_case, never camelCase.
void expectStrictFirestorePayload(
  Map<String, dynamic>? payload, {
  required bool boredom,
  required int delayed,
  required bool body,
}) {
  const camelBoredom = 'boredomBefriended';
  const camelDelayed = 'delayedGratificationCount';
  const camelBody = 'bodyActivated';
  const snakeBoredom = 'boredom_befriended';
  const snakeDelayed = 'delayed_gratification_count';
  const snakeBody = 'body_activated';

  expect(payload, isNotNull);

  // Keys must NOT be camelCase.
  expect(payload!.containsKey(camelBoredom), isFalse);
  expect(payload.containsKey(camelDelayed), isFalse);
  expect(payload.containsKey(camelBody), isFalse);
  expect(payload.containsKey(DiagnosticModelJsonKeys.boredomBefriendedCamel),
      isFalse);
  expect(
      payload.containsKey(DiagnosticModelJsonKeys.delayedGratificationCountCamel),
      isFalse);
  expect(payload.containsKey(DiagnosticModelJsonKeys.bodyActivatedCamel),
      isFalse);

  // Keys MUST be snake_case.
  expect(payload.containsKey(snakeBoredom), isTrue);
  expect(payload.containsKey(snakeDelayed), isTrue);
  expect(payload.containsKey(snakeBody), isTrue);

  // ONLY the three required snake_case keys.
  expect(payload.length, 3);
  expect(payload.keys, equals(DetoxFirestorePayload.allowedHabitKeys));
  DetoxFirestorePayload.assertSnakeCaseOnly(payload);

  // Exact value mapping.
  expect(payload[snakeBoredom], boredom);
  expect(payload[snakeDelayed], delayed);
  expect(payload[snakeBody], body);
}

void main() {
  group('DetoxProtocolRepository — Data Transformation Layer', () {
    late _CapturingRepository repository;

    setUp(() => repository = _CapturingRepository());

    test('transformLocalMetricsToFirestorePayload maps camelCase to snake_case',
        () {
      const state = DetoxProtocolState(
        boredomBefriended: true,
        delayedGratificationCount: 5,
        bodyActivated: false,
      );

      final payload = repository.transformLocalMetricsToFirestorePayload(state);

      expectStrictFirestorePayload(
        payload,
        boredom: true,
        delayed: 5,
        body: false,
      );
    });

    test('upsert applies transformation before Firestore write', () async {
      await repository.upsert(
        const DetoxProtocolState(
          boredomBefriended: false,
          delayedGratificationCount: 3,
          bodyActivated: true,
        ),
      );

      expectStrictFirestorePayload(
        repository.lastTransformedPayload,
        boredom: false,
        delayed: 3,
        body: true,
      );
    });

    test('upsertSnakeCasePayload transforms camelCase input map', () async {
      await repository.upsertSnakeCasePayload({
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 2,
        DiagnosticModelJsonKeys.bodyActivatedCamel: false,
      });

      expectStrictFirestorePayload(
        repository.lastTransformedPayload,
        boredom: true,
        delayed: 2,
        body: false,
      );
    });

    test('snake_case keys take precedence over camelCase in transformation',
        () async {
      await repository.upsertSnakeCasePayload({
        'boredom_befriended': false,
        DiagnosticModelJsonKeys.boredomBefriendedCamel: true,
        'delayed_gratification_count': 7,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel: 1,
        'body_activated': true,
        DiagnosticModelJsonKeys.bodyActivatedCamel: false,
      });

      expectStrictFirestorePayload(
        repository.lastTransformedPayload,
        boredom: false,
        delayed: 7,
        body: true,
      );
    });
  });

  group('DetoxProtocolRepository — Payload Validation Suite', () {
    late _CapturingRepository repository;

    setUp(() => repository = _CapturingRepository());

    test('output contains ONLY snake_case keys with zero camelCase leakage',
        () async {
      await repository.upsert(
        const DetoxProtocolState(
          boredomBefriended: true,
          delayedGratificationCount: 4,
          bodyActivated: true,
        ),
      );

      expectStrictFirestorePayload(
        repository.lastTransformedPayload,
        boredom: true,
        delayed: 4,
        body: true,
      );
    });

    test('camelCase local fields map to exact snake_case values', () async {
      await repository.upsertSnakeCasePayload({
        'boredomBefriended': false,
        'delayedGratificationCount': 6,
        'bodyActivated': true,
      });

      expectStrictFirestorePayload(
        repository.lastTransformedPayload,
        boredom: false,
        delayed: 6,
        body: true,
      );
    });

    test('default values applied when local metrics are absent', () {
      final payload =
          repository.transformLocalMetricsToFirestorePayload(
        const DetoxProtocolState(),
      );

      expectStrictFirestorePayload(
        payload,
        boredom: false,
        delayed: 0,
        body: false,
      );
    });

    test('full habit metric round-trip preserves values through transformation',
        () async {
      const state = DetoxProtocolState(
        boredomBefriended: true,
        delayedGratificationCount: 7,
        bodyActivated: false,
        detoxHabitScore: 85,
      );

      await repository.upsert(state);

      expectStrictFirestorePayload(
        repository.lastTransformedPayload,
        boredom: state.boredomBefriended,
        delayed: state.delayedGratificationCount,
        body: state.bodyActivated,
      );
    });
  });
}
