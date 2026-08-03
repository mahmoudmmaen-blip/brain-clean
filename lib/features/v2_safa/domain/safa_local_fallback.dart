import 'safa_response.dart';
import 'safa_response_type.dart';
import 'safa_service_metadata.dart';
import 'safa_session_id.dart';
import 'safa_suggested_action.dart';
import 'safa_suggested_destination.dart';

/// Deterministic Free local fallback — offline, non-AI (Contract §10).
abstract final class SafaLocalFallback {
  static SafaResponse build({
    required SafaSessionId sessionId,
    required String locale,
    required DateTime generatedAt,
    SafaResponseType type = SafaResponseType.unavailableFallback,
  }) {
    final isAr = locale == 'ar';
    return SafaResponse(
      responseId: 'fallback_${generatedAt.microsecondsSinceEpoch}',
      sessionId: sessionId,
      responseType: type,
      shortAcknowledgement: isAr
          ? 'حسنًا. يمكن المتابعة بخطوة هادئة دون اتصال.'
          : 'Okay. You can continue with a calm step offline.',
      boundedSupportText: isAr
          ? 'صفا غير متاحة عبر الشبكة الآن. اختر تهدئة قصيرة، أو بسّط خطوتك التالية، ثم عُد إلى اليوم أو خطتك. صفا ليست رعاية طبية ولا طوارئ.'
          : 'Safa is unavailable over the network right now. Choose a short grounding step or simplify your next step, then return to Today or your plan. Safa is not medical or emergency care.',
      suggestedAction: const SafaSuggestedAction(
        labelKey: 'v2SafaSuggestedReturnToday',
      ),
      suggestedDestination: SafaSuggestedDestination.today,
      safetyQualifier: isAr
          ? 'صفا ليست بديلاً عن الطوارئ المحلية.'
          : 'Safa is not a substitute for local emergency services.',
      generatedAt: generatedAt,
      serviceMetadata: const SafaServiceMetadata(
        serviceVersionRef: 'local_fallback_v1',
      ),
      networkUsed: false,
      fallbackUsed: true,
    );
  }

  /// Grounding option copy keys (resolved in UI).
  static const groundingKey = 'v2SafaFallbackGrounding';

  /// Simplify-next-step option copy keys.
  static const simplifyKey = 'v2SafaFallbackSimplify';
}
