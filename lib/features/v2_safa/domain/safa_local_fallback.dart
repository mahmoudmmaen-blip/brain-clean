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
          ? 'حسنًا. إليك خطوة هادئة يمكنك فعلها الآن دون اتصال.'
          : 'Okay. Here is a calm step you can take offline right now.',
      boundedSupportText: isAr
          ? 'جرّب تنفسًا بطيئًا (شهيق 4 · حبس 2 · زفير 6)، أو بسّط خطوتك التالية، ثم عُد إلى برنامجك اليومي. صفا ليست رعاية طبية ولا طوارئ.'
          : 'Try slow breathing (in 4 · hold 2 · out 6), or simplify your next step, then return to your daily program. Safa is not medical or emergency care.',
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
