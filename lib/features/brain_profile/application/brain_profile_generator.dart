import 'package:uuid/uuid.dart';

import '../../brain_check/domain/brain_check_item_bank.dart';
import '../../brain_check/domain/measurement_event.dart';
import '../data/brain_profile_repository.dart';
import '../domain/domain_aggregator.dart';
import '../domain/measurement_explanation.dart';
import '../domain/profile_generation_result.dart';
import '../domain/profile_pack.dart';
import '../domain/profile_source_reference.dart';
import '../domain/profile_version.dart';
import '../domain/recovery_score.dart';

/// Builds an immutable [ProfilePack] from a completed Brain Check.
///
/// Overall Recovery Score stays [RecoveryScore.pending] until mathematics
/// authority is approved (Build Spec silent on weights/bands).
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

  /// Generate or return existing pack for [event.session].
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
      final existing =
          await _repository.findBySourceSessionId(event.id);
      if (existing != null) {
        return ProfileGenerationSuccess(
          profile: existing,
          wasExisting: true,
        );
      }

      final now = _clock().toUtc();
      final domains = DomainAggregator.aggregate(event);
      final confidence = DomainAggregator.confidenceFor(
        mode: event.mode,
        domains: domains,
      );
      final stronger = DomainAggregator.rankedStronger(domains);
      final support = DomainAggregator.rankedSupport(domains);

      // Overall Recovery Score intentionally pending — no invented weights.
      const recoveryScore = RecoveryScore.pending;

      final explanation = ProfileExplanationCatalog.build(
        strongerTitlesEn: stronger.map((d) => d.titleEn).toList(),
        strongerTitlesAr: stronger.map((d) => d.titleAr).toList(),
        supportTitlesEn: support.map((d) => d.titleEn).toList(),
        supportTitlesAr: support.map((d) => d.titleAr).toList(),
        confidence: confidence,
        scorePending: recoveryScore.isPending,
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
        domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
        strongerDomainIds:
            stronger.map((d) => d.domainId).toList(growable: false),
        supportDomainIds:
            support.map((d) => d.domainId).toList(growable: false),
      );

      await _repository.save(pack);
      return ProfileGenerationSuccess(profile: pack, wasExisting: false);
    } catch (_) {
      return const ProfileGenerationFailure(
        code: ProfileGenerationErrorCode.persistenceFailed,
        messageEn: 'Could not save your Brain Profile. Please try again.',
        messageAr: 'تعذّر حفظ ملف الدماغ. حاول مرة أخرى.',
      );
    }
  }
}
