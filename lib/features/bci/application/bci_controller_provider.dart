import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
import '../data/bci_adherence_repository_provider.dart';
import '../domain/bci_score_engine.dart';
import '../domain/bci_score_model.dart';

part 'bci_controller_provider.g.dart';

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
@Riverpod(keepAlive: true)
Future<BciScoreModel> bciController(BciControllerRef ref) async {
  final session = ref.watch(bcScoreSessionProvider);
  ref.watch(recoveryProtocolControllerProvider);

  final adherence = await ref
      .read(bciAdherenceRepositoryProvider)
      .fetchLastSevenDaysAdherence();

  return BciScoreEngine.calculate(
    session: session,
    adherence: adherence,
  );
}

/// Alias مختصر — `ref.watch(bciScoreProvider)`.
final bciScoreProvider = bciControllerProvider;
