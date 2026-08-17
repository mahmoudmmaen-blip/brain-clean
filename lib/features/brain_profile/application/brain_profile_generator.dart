import 'package:uuid/uuid.dart';

import '../../brain_check/domain/brain_check_item_bank.dart';
import '../../brain_check/domain/measurement_event.dart';
import '../data/brain_profile_repository.dart';
import '../domain/measurement_explanation.dart';
import '../domain/profile_generation_result.dart';
import '../domain/profile_pack.dart';
import '../domain/profile_source_reference.dart';
import '../domain/profile_version.dart';
import '../domain/recovery_score_engine.dart';
import '../domain/score_calculation_result.dart';

/// Builds an immutable [ProfilePack] from a completed Brain Check.
///
/// Uses deterministic [RecoveryScoreEngine] (`recovery_score_v1`).
class BrainProfileGenerator {
  BrainProfileGenerator({
    required BrainProfileRepository repository,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final BrainProfileRepository _repository;
  final Uuid _uuid;
  final DateTime Function() _clock;

  /// Generate or return existing pack for [event] session.
  Future<ProfileGenerationResult> generateFrom(MeasurementEvent event) async {
    if (event.answers.isEmpty) {
      return const ProfileGenerationFailure(
        code: ProfileGenerationErrorCode.emptyEvent,
        messageEn: 'No Brain Check answers were found.',
        messageAr: 'لم يُعثر على إجابات لفحص الدماغ.',
      );
    }

    final questions = BrainCheckItemBank.questionsFor(event.mode);
    final missingRequired = <String>[];
    for (final q in questions) {
      if (!event.answers.containsKey(q.id)) {
        missingRequired.add(q.id);
      }
    }
    if (missingRequired.isNotEmpty) {
      return ProfileGenerationFailure(
        code: ProfileGenerationErrorCode.incompleteAnswers,
        messageEn:
            'Brain Check is incomplete. Finish all questions before building a profile.',
        messageAr:
            'فحص الدماغ غير مكتمل. أكمِل كل الأسئلة قبل بناء الملف.',
      );
    }

    try {
      final existing = await _repository.findBySourceSessionId(event.id);
      if (existing != null) {
        return ProfileGenerationSuccess(
          profile: existing,
          wasExisting: true,
        );
      }

      final scored = RecoveryScoreEngine.compute(event);
      final now = _clock().toUtc();

      switch (scored) {
        case ScoreCalculationUnavailable(
            :final reason,
            :final flags,
          ):
          final code = switch (reason) {
            ScoreUnavailableReason.missingRequired =>
              ProfileGenerationErrorCode.incompleteAnswers,
            ScoreUnavailableReason.emptyAnswers =>
              ProfileGenerationErrorCode.emptyEvent,
            _ => ProfileGenerationErrorCode.calculationUnavailable,
          };
          return ProfileGenerationFailure(
            code: code,
            messageEn: flags.contains('invalid_range')
                ? 'Some answers are outside the allowed range.'
                : 'Recovery Score could not be calculated for this check.',
            messageAr: flags.contains('invalid_range')
                ? 'بعض الإجابات خارج النطاق المسموح.'
                : 'تعذّر حساب درجة التعافي لهذا الفحص.',
          );
        case ScoreCalculationValid(
            :final recoveryScore,
            :final domains,
            :final contributions,
            :final confidence,
            :final strongerDomainIds,
            :final supportDomainIds,
            :final flags,
          ):
          final stronger = domains
              .where((d) => strongerDomainIds.contains(d.domainId))
              .toList();
          final support = domains
              .where((d) => supportDomainIds.contains(d.domainId))
              .toList();

          final explanation = ProfileExplanationCatalog.build(
            strongerTitlesEn: stronger.map((d) => d.titleEn).toList(),
            strongerTitlesAr: stronger.map((d) => d.titleAr).toList(),
            supportTitlesEn: support.map((d) => d.titleEn).toList(),
            supportTitlesAr: support.map((d) => d.titleAr).toList(),
            confidence: confidence,
            scorePending: !recoveryScore.isValid,
          );

          final pack = ProfilePack(
            id: _uuid.v4(),
            source: ProfileSourceReference(
              sessionId: event.id,
              mode: event.mode,
              brainCheckSchemaVersion: ProfileVersion.brainCheckSchema,
              source: event.source,
            ),
            createdAt: now,
            lastRecalculatedAt: now,
            domains: domains,
            recoveryScore: recoveryScore,
            confidence: confidence,
            explanation: explanation,
            profileSchemaVersion: ProfileVersion.profileSchema,
            domainAggregationModelVersion:
                ProfileVersion.domainAggregationModel,
            strongerDomainIds: strongerDomainIds,
            supportDomainIds: supportDomainIds,
            contributions: contributions,
            explanationFlags: flags,
          );

          await _repository.save(pack);
          return ProfileGenerationSuccess(profile: pack, wasExisting: false);
      }
    } catch (_) {
      return const ProfileGenerationFailure(
        code: ProfileGenerationErrorCode.persistenceFailed,
        messageEn: 'Could not save your Brain Profile. Please try again.',
        messageAr: 'تعذّر حفظ ملف الدماغ. حاول مرة أخرى.',
      );
    }
  }
}
