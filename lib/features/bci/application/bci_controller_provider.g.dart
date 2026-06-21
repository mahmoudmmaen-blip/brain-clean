// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bci_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bciControllerHash() => r'fe945ad9f8b99bd0f758769ddc1d8cf6addecf55';

/// يُعيد حساب BCI ديناميكياً (0–100) عند:
/// - تغيير سجلات بروتوكول التعافي في Hive ([recoveryProtocolControllerProvider]).
/// - إجراء تشخيص أسبوعي جديد ([bcScoreSessionProvider]).
///
/// ---------------------------------------------------------------------------
/// الاستدعاء في واجهة المستخدم:
/// ```dart
/// final bciAsync = ref.watch(bciControllerProvider);
///
/// bciAsync.when(
///   data: (bci) {
///     // النتيجة النهائية (0–100):
///     Text('${bci.totalScoreRounded}');
///
///     // شريط دائري:
///     CircularProgressIndicator(value: bci.progressRatio);
///
///     // التقييم الأسبوعي (60%) | الالتزام اليومي (40%):
///     Text('${bci.assessmentScoreRounded}');
///     Text('${bci.adherenceScoreRounded}');
///
///     if (!bci.hasCommittedAssessment) {
///       // اعرض زر "ابدأ التقييم الأسبوعي"
///     }
///   },
///   loading: () => const CircularProgressIndicator(),
///   error: (_, __) => const SizedBox.shrink(),
/// );
/// ```
/// ---------------------------------------------------------------------------
///
/// Copied from [bciController].
@ProviderFor(bciController)
final bciControllerProvider = FutureProvider<BciScoreModel>.internal(
  bciController,
  name: r'bciControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bciControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BciControllerRef = FutureProviderRef<BciScoreModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
