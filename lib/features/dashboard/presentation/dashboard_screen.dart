import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ------------------------------------------------------------------------
// الاستيرادات الأساسية (إذا ظهر خطأ هنا، اضغط Ctrl + . لاختيار المسار)
// ------------------------------------------------------------------------
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';

// ------------------------------------------------------------------------
// تعريفات مؤقتة (Fallbacks) لضمان عمل الشاشة وتجاوز الأخطاء
// ------------------------------------------------------------------------

// 1. بديل لملف AppStrings المفقود
class AppStrings {
  static const String challengeTitle = "تحدي النقاء";
  static String challengeSubtitle(int days) => "متبقي $days يوم";
  static const String emotionOasis = "واحة المشاعر";
}

// 2. بديل للـ Providers المفقودة
final challengeDurationProvider = Provider<int>((ref) => 30);
final bcScoreSessionProvider = Provider<dynamic>((ref) => null);

// ------------------------------------------------------------------------
// بداية الكود الأصلي للشاشة
// ------------------------------------------------------------------------

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // 3. ميثود مؤقتة لمعالجة خطأ showChallengeDurationPicker
  void showChallengeDurationPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل مدة التحدي"),
        content: const Text("هذه الميزة ستكون متاحة قريباً!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب الترجمة بطريقة آمنة
    final loc = AppLocalizations.of(context);
    final title = loc?.dashboardTitle ?? 'الرئيسية';
    
    final session = ref.watch(bcScoreSessionProvider);
    final challengeDays = ref.watch(challengeDurationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- كارت التحدي ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListTile(
                title: const Text(AppStrings.challengeTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(AppStrings.challengeSubtitle(challengeDays)),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () => showChallengeDurationPicker(context, ref),
              ),
            ),
            
            const SizedBox(height: 24),

            // --- كارت واحة المشاعر (الربط مع NVIDIA سيكون هنا) ---
            Card(
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.psychology, color: Colors.white),
                ),
                title: const Text(AppStrings.emotionOasis, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('تحدث مع المرشد السلوكي لدعم رحلتك'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                // الانتقال لشاشة واحة المشاعر
                onTap: () => context.push('/emotion-oasis'), 
              ),
            ),
            
            const SizedBox(height: 12),

            // زر إعادة التشخيص
            OutlinedButton(
              onPressed: () => print("جاري فتح التشخيص..."),
              child: Text(loc?.dashboardRetakeDiagnostic ?? 'إعادة التشخيص'),
            ),
          ],
        ),
      ),
    );
  }
}