import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository.dart';
import 'package:brain_clean_mobile/features/detox/data/detox_protocol_repository_provider.dart';
import 'package:brain_clean_mobile/features/detox/domain/detox_protocol_state.dart';
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_controller.dart';
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
      final state = container.read(detoxProtocolControllerProvider);
      expect(state.boredomBefriended, isFalse);
      expect(state.delayedGratificationCount, 0);
      expect(state.bodyActivated, isFalse);
    });

    test('setBoredomBefriended updates state and persists snake_case payload',
        () async {
      await container
          .read(detoxProtocolControllerProvider.notifier)
          .setBoredomBefriended(true);

      final state = container.read(detoxProtocolControllerProvider);
      expect(state.boredomBefriended, isTrue);
      expect(fakeRepository.stored?.boredomBefriended, isTrue);
    });

    test('recordDelayedGratificationWin increments count up to protocol cap',
        () async {
      final notifier = container.read(detoxProtocolControllerProvider.notifier);

      for (var i = 0; i < 8; i++) {
        await notifier.recordDelayedGratificationWin();
      }

      expect(
        container.read(detoxProtocolControllerProvider).delayedGratificationCount,
        7,
      );
    });

    test('loadFromRemote hydrates controller from repository', () async {
      fakeRepository.stored = const DetoxProtocolState(
        boredomBefriended: true,
        delayedGratificationCount: 3,
        bodyActivated: true,
      );

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .loadFromRemote();

      final state = container.read(detoxProtocolControllerProvider);
      expect(state.boredomBefriended, isTrue);
      expect(state.delayedGratificationCount, 3);
      expect(state.bodyActivated, isTrue);
    });

    test('persist failure surfaces user-friendly syncError', () async {
      fakeRepository.shouldThrowOnUpsert = true;

      await container
          .read(detoxProtocolControllerProvider.notifier)
          .setBodyActivated(true);

      final state = container.read(detoxProtocolControllerProvider);
      expect(state.bodyActivated, isTrue);
      expect(state.syncError, isNotNull);
      expect(state.isSyncing, isFalse);
    });
  });
}
