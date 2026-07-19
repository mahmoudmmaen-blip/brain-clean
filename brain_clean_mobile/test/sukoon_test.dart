import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/sukoon/application/sukoon_controller.dart';
import 'package:brain_clean_mobile/features/sukoon/data/sukoon_repository_impl.dart';
import 'package:brain_clean_mobile/features/sukoon/data/sukoon_repository_provider.dart';
import 'package:brain_clean_mobile/features/sukoon/domain/sukoon_repository.dart';
import 'package:brain_clean_mobile/features/sukoon/domain/sukoon_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _RecordingSukoonRepository implements SukoonRepository {
  final List<SukoonSession> sessions = [];

  @override
  Future<void> saveSession(SukoonSession session) async {
    sessions.add(session);
  }

  @override
  Future<List<SukoonSession>> getTodaySessions() async => sessions;

  @override
  Future<List<SukoonSession>> getAllSessions() async => sessions;

  @override
  Future<int> getTotalMinutes() async =>
      sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

void main() {
  group('SukoonController', () {
    late ProviderContainer container;
    late _RecordingSukoonRepository repo;

    setUp(() {
      repo = _RecordingSukoonRepository();
      container = ProviderContainer(
        overrides: [
          sukoonRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('selectDuration updates remaining seconds', () {
      final notifier = container.read(sukoonControllerProvider.notifier);
      notifier.selectDuration(10);

      final state = container.read(sukoonControllerProvider);
      expect(state.selectedDuration, 10);
      expect(state.remainingSeconds, 600);
    });

    test('tick decrements remaining seconds while running', () {
      final notifier = container.read(sukoonControllerProvider.notifier);
      notifier.selectDuration(3);
      notifier.start();
      notifier.tick();
      notifier.tick();

      final state = container.read(sukoonControllerProvider);
      expect(state.remainingSeconds, 178);
      expect(state.isRunning, isTrue);
    });

    test('complete saves session via saveWithNote', () async {
      final notifier = container.read(sukoonControllerProvider.notifier);
      notifier.selectDuration(5);
      notifier.start();
      notifier.complete();

      await notifier.saveWithNote('سرحت في الذكريات');

      expect(repo.sessions, hasLength(1));
      expect(repo.sessions.first.durationMinutes, 5);
      expect(repo.sessions.first.wanderNote, 'سرحت في الذكريات');
      expect(repo.sessions.first.wasInterrupted, isFalse);
      expect(container.read(sukoonControllerProvider).isComplete, isFalse);
    });

    test('markInterrupted pauses and sets wasInterrupted', () {
      final notifier = container.read(sukoonControllerProvider.notifier);
      notifier.selectDuration(3);
      notifier.start();
      notifier.markInterrupted();

      final state = container.read(sukoonControllerProvider);
      expect(state.isRunning, isFalse);
      expect(state.isPaused, isTrue);
      expect(state.wasInterrupted, isTrue);
      expect(state.showInterruptPrompt, isTrue);
    });
  });

  group('SukoonRepositoryImpl', () {
    late Directory tempDir;
    late SukoonRepositoryImpl repository;

    setUp(() async {
      HiveBootstrap.resetForTesting();
      tempDir = await Directory.systemTemp.createTemp('bc_sukoon_hive_');
      Hive.init(tempDir.path);
      HiveBootstrap.registerRecoveryAdaptersForTests();
      if (Hive.isBoxOpen(HiveBoxes.sukoon)) {
        await Hive.box(HiveBoxes.sukoon).close();
      }
      final box = await Hive.openBox<dynamic>(HiveBoxes.sukoon);
      repository = SukoonRepositoryImpl(box: box);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
      HiveBootstrap.resetForTesting();
    });

    test('getTotalMinutes sums durationMinutes across sessions', () async {
      await repository.saveSession(
        SukoonSession(
          id: 'a',
          durationMinutes: 3,
          completedAt: DateTime.now(),
        ),
      );
      await repository.saveSession(
        SukoonSession(
          id: 'b',
          durationMinutes: 10,
          completedAt: DateTime.now(),
          wasInterrupted: true,
        ),
      );
      await repository.saveSession(
        SukoonSession(
          id: 'c',
          durationMinutes: 5,
          completedAt: DateTime.now(),
        ),
      );

      expect(await repository.getTotalMinutes(), 18);
      expect(await repository.getAllSessions(), hasLength(3));
    });
  });
}
