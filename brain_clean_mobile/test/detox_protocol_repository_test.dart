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

void expectExactSnakeCasePayload(
  Map<String, dynamic>? payload, {
  required bool boredom,
  required int delayed,
  required bool body,
}) {
  expect(payload, isNotNull);
  DetoxFirestorePayload.assertSnakeCaseOnly(payload!);
  expect(payload.keys, DetoxFirestorePayload.allowedHabitKeys);
  expect(payload['boredom_befriended'], boredom);
  expect(payload['delayed_gratification_count'], delayed);
  expect(payload['body_activated'], body);
  expect(payload.containsKey('boredomBefriended'), isFalse);
  expect(payload.containsKey('delayedGratificationCount'), isFalse);
  expect(payload.containsKey('bodyActivated'), isFalse);
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

      expectExactSnakeCasePayload(
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

      expectExactSnakeCasePayload(
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

      expectExactSnakeCasePayload(
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

      expectExactSnakeCasePayload(
        repository.lastTransformedPayload,
        boredom: false,
        delayed: 7,
        body: true,
      );
    });
  });
}
