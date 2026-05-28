import 'package:brain_clean_mobile/features/diagnostic/presentation/widgets/slide_lock_mechanism.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestVsync implements TickerProvider {
  const _TestVsync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SlideLockMechanism', () {
    test('acquire blocks until slide duration elapses', () {
      fakeAsync((async) {
        final lock = SlideLockMechanism(
          slideDuration: const Duration(milliseconds: 400),
        );
        var rebuilds = 0;

        lock.acquire(() => rebuilds++);

        expect(lock.isLocked, isTrue);
        expect(rebuilds, 1);

        async.elapse(const Duration(milliseconds: 399));
        expect(lock.isLocked, isTrue);

        async.elapse(const Duration(milliseconds: 1));
        expect(lock.isLocked, isFalse);
        expect(rebuilds, 2);

        lock.dispose();
      });
    });

    test('layoutBuilder shields children while locked', () {
      final lock = SlideLockMechanism(
        slideDuration: const Duration(milliseconds: 400),
      );
      lock.acquire(() {});

      final stack = lock.layoutBuilder(
        currentChild: const Text('current'),
        previousChildren: const [Text('prev')],
      );

      expect(stack, isA<Stack>());
      expect(lock.isLocked, isTrue);
      lock.dispose();
    });

    test('acquireForAnimation releases when controller completes', () {
      fakeAsync((async) {
        final lock = SlideLockMechanism(
          slideDuration: const Duration(milliseconds: 400),
        );
        final controller = AnimationController(
          vsync: const _TestVsync(),
          duration: const Duration(milliseconds: 400),
        );
        var rebuilds = 0;

        lock.acquireForAnimation(controller, () => rebuilds++);
        expect(lock.isLocked, isTrue);

        controller.forward();
        async.elapse(const Duration(milliseconds: 450));
        expect(lock.isLocked, isFalse);
        expect(rebuilds, greaterThanOrEqualTo(2));

        controller.dispose();
        lock.dispose();
      });
    });

    test('release cancels pending timer immediately', () {
      fakeAsync((async) {
        final lock = SlideLockMechanism(
          slideDuration: const Duration(milliseconds: 400),
        );
        var rebuilds = 0;

        lock.acquire(() => rebuilds++);
        lock.release(() => rebuilds++);

        expect(lock.isLocked, isFalse);
        expect(rebuilds, 2);

        async.elapse(const Duration(seconds: 1));
        expect(lock.isLocked, isFalse);
        expect(rebuilds, 2);

        lock.dispose();
      });
    });
  });
}
