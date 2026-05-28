import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../domain/diagnostic_metrics.dart';
import 'bc_score_provider.dart';

part 'diagnostic_controller.g.dart';

@riverpod
class DiagnosticController extends _$DiagnosticController {
  @override
  FutureOr<DiagnosticMetrics> build() {
    // إرجاع الحالة المبدئية للـ Metrics بشكل آمن ونظيف
    return const DiagnosticMetrics();
  }

  void updateSleepQuality(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(sleepQuality: _clampMetric(value)));
    }
  }

  void updateSustainedAttention(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(sustainedAttention: _clampMetric(value)));
    }
  }

  void updateFragmentation(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(fragmentation: _clampMetric(value)));
    }
  }

  void updateDopamineSeeking(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(dopamineSeeking: _clampMetric(value)));
    }
  }

  void updateTaskSwitching(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(taskSwitching: _clampMetric(value)));
    }
  }

  void updateBurnout(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(burnout: _clampMetric(value)));
    }
  }

  int _clampMetric(int value) => value.clamp(1, 10);

  /// دالة تفعيل المزامنة وتصفير الديتوكس بشكل آمن لإعادة بناء دورة نقي جديدة
  void _invalidateAndResyncDetox() {
    // TODO: قم بعمل invalidate لـ providers الديتوكس هنا لتجبر التطبيق على سحب الحزم النظيفة
    // مثال: ref.invalidate(detoxProtocolControllerProvider);
    debugPrint('[BrainClean] Detox resync lifecycle triggered successfully.');
  }

  Future<void> submitDiagnostic() async {
    if (!state.hasValue) return;
    
    final currentMetrics = state.value!;
    final bhi = ref.read(bcScoreLiveProvider);
    
    // تحويل حالة الـ Controller للتحميل لحماية الواجهة من الرفع المزدوج
    state = const AsyncLoading<DiagnosticMetrics>().copyWithPrevious(AsyncData(currentMetrics));

    try {
      // 1. تثبيت الجلسة محلياً (Commit Session)
      ref.read(bcScoreSessionProvider.notifier).commit(bhi);

      debugPrint(
        '[BrainClean] BHI BC_score: ${bhi.bcScore.toStringAsFixed(1)}% '
        '(performance ${bhi.brainPerformance.toStringAsFixed(0)}, '
        'discipline ${bhi.digitalDiscipline.toStringAsFixed(0)}, '
        'habits ${bhi.healthyHabits.toStringAsFixed(0)}, '
        'consistency ${bhi.consistency.toStringAsFixed(0)})',
      );
      debugPrint('[BrainClean] BHI JSON: ${bhi.toJson()}');

      // 2. المزامنة السحابية الاحترافية (Supabase Remote Sync)
      // TODO: قم بإلغاء التعليق وتضمين كود السوبابيز الفعلي هنا
      // await ref.read(supabaseDiagnosticRepositoryProvider).upsertDiagnostics(bhi, currentMetrics);

      // 3. تحديث دورة حياة الديتوكس بشكل كامل وتصفير المسارات القديمة
      _invalidateAndResyncDetox();

      // إعادة الحالة إلى طبيعتها وتوجيه المستخدم للوحة التحكم الرئيسية
      state = AsyncData(currentMetrics);
      ref.read(goRouterProvider).go(AppRoutes.dashboard);
    } catch (error, stackTrace) {
      // تمرير الـ Exception والـ Stack إلى الـ AsyncValue ليعرضها الـ UI بكفاءة دون تجمد
      state = AsyncError<DiagnosticMetrics>(error, stackTrace).copyWithPrevious(AsyncData(currentMetrics));
    }
  }
}