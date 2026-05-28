import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/domain/diagnostic_model.dart'; // Import الموديل المركزي للـ Brain Rot النتائج
import 'bc_score_provider.dart';
import 'diagnostic_controller.dart';
import 'widgets/bc_score_breakdown.dart';
import 'widgets/bc_score_hero_card.dart';
import 'widgets/diagnostic_metric_slider.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    
    // مراقبة الـ Controller لمعالجة حالات التحميل والأخطاء بشكل متكامل
    final asyncMetrics = ref.watch(diagnosticControllerProvider);
    final bhiLive = ref.watch(bcScoreLiveProvider);
    final controller = ref.read(diagnosticControllerProvider.notifier);

    // استدعاء نتيجة تفسير تعفن الدماغ الفورية والمحددة من الموديل المركزي بدون هاردكود
    final finalLabel = DiagnosticModel.brainRotInterpretationForScore(bhiLive.bcScoreRounded);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(loc.diagnosticTitle, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        actions: [
          // عرض مؤشر تحميل صغير في الـ AppBar إذا كان هناك رفع سحابي نشط في الخلفية
          if (asyncMetrics.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: asyncMetrics.when(
          // 1. واجهة معالجة التحميل الأولي (في حال جلب بيانات مبدئية)
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.orangeAccent),
          ),
          
          // 2. واجهة معالجة أخطاء المزامنة والرفع مع إمكانية التحديث الفوري
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '⚠️ فشل حفظ التشخيص: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => controller.submitDiagnostic(),
                    icon: const Icon(Icons.sync_problem),
                    label: const Text('إعادة محاولة المزامنة', style: TextStyle(fontFamily: 'Cairo')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. واجهة عرض البيانات الفعالة والـ Sliders المستقرة
          data: (metrics) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // كارت الـ Hero الرئيسي لعرض السكور الحالي
              BcScoreHeroCard(
                score: bhiLive.bcScore,
                subtitle: loc.diagnosticLiveSubtitle,
              ),
              
              // كارت تفصيلي يعرض نتائج الـ Brain Rot الفورية المأخوذة من الموديل المركزي مباشرة
              Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.orangeAccent, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'التقييم الفوري لسلامة الدماغ:',
                        style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finalLabel, // الناتج المركزي المأخوذ من الموديل بدون هاردكود للباندز
                        style: const TextStyle(color: Colors.whiteee, fontFamily: 'Cairo', fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),

              BcScoreBreakdown(model: bhiLive),
              const SizedBox(height: 8),
              
              Text(
                loc.diagnosticInstructions,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 20),
              
              // مجموعة الـ Sliders المسؤولة عن تحديث المؤشرات
              DiagnosticMetricSlider(
                code: 'S1',
                label: loc.diagnosticSleepQuality,
                value: metrics.sleepQuality,
                onChanged: controller.updateSleepQuality,
              ),
              DiagnosticMetricSlider(
                code: 'A2',
                label: loc.diagnosticSustainedAttention,
                value: metrics.sustainedAttention,
                onChanged: controller.updateSustainedAttention,
              ),
              DiagnosticMetricSlider(
                code: 'F3',
                label: loc.diagnosticFragmentation,
                value: metrics.fragmentation,
                onChanged: controller.updateFragmentation,
              ),
              DiagnosticMetricSlider(
                code: 'D4',
                label: loc.diagnosticDopamineSeeking,
                value: metrics.dopamineSeeking,
                onChanged: controller.updateDopamineSeeking,
              ),
              DiagnosticMetricSlider(
                code: 'T5',
                label: loc.diagnosticTaskSwitching,
                value: metrics.taskSwitching,
                onChanged: controller.updateTaskSwitching,
              ),
              DiagnosticMetricSlider(
                code: 'B6',
                label: loc.diagnosticBurnout,
                value: metrics.burnout,
                onChanged: controller.updateBurnout,
              ),
              
              const SizedBox(height: 24),
              
              // زر بدء المزامنة والرفع النهائي الحامي من الـ Double-tap أثناء الـ Loading
              FilledButton(
                onPressed: asyncMetrics.isLoading ? null : () => controller.submitDiagnostic(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: asyncMetrics.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(loc.diagnosticStart, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}