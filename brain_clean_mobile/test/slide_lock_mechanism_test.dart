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
    test('isTransitionActive mirrors tick lock semantics', () {
      final controller = AnimationController(
        vsync: const _TestVsync(),
        duration: const Duration(milliseconds: 400),
      );
      controller.value = 0.5;
      expect(SlideLockMechanism.isTransitionActive(controller), isTrue);
      controller.value = 1.0;
      expect(SlideLockMechanism.isTransitionActive(controller), isFalse);
      controller.dispose();
    });

    test('bindToTransition locks on animation ticks between 0 and 1', () {
      final lock = SlideLockMechanism(
        slideDuration: const Duration(milliseconds: 400),
      );
      final controller = AnimationController(
        vsync: const _TestVsync(),
        duration: const Duration(milliseconds: 400),
      );
      var rebuilds = 0;

      lock.bindToTransition(controller, () => rebuilds++);
      expect(lock.isLocked, isFalse);

      controller.value = 0.5;
      expect(lock.isLocked, isTrue);

      controller.value = 1.0;
      expect(lock.isLocked, isFalse);

      controller.dispose();
      lock.dispose();
    });

    test('layoutBuilder shields children while locked', () {
      final lock = SlideLockMechanism(
        slideDuration: const Duration(milliseconds: 400),
      );
      final controller = AnimationController(
        vsync: const _TestVsync(),
        duration: const Duration(milliseconds: 400),
      );
      lock.bindToTransition(controller, () {});
      controller.value = 0.4;

      final stack = lock.layoutBuilder(
        currentChild: const Text('current'),
        previousChildren: const [Text('prev')],
      );

      expect(stack, isA<Stack>());
      expect(lock.isLocked, isTrue);
      controller.dispose();
      lock.dispose();
    });

    test('release detaches listeners immediately', () {
      fakeAsync((async) {
        final lock = SlideLockMechanism(
          slideDuration: const Duration(milliseconds: 400),
        );
        var rebuilds = 0;

        lock.bindToTransition(
          AlwaysStoppedAnimation<double>(0.5),
          () => rebuilds++,
        );
        expect(lock.isLocked, isTrue);

        lock.release(() => rebuilds++);
        expect(lock.isLocked, isFalse);

        async.elapse(const Duration(seconds: 1));
        expect(rebuilds, 2);

        lock.dispose();
      });
    });
  });
}
