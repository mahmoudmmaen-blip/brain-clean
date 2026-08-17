import 'safa_response.dart';
import 'safa_response_type.dart';
import 'safa_service_metadata.dart';
import 'safa_session_id.dart';
import 'safa_session_limit.dart';
import 'safa_suggested_action.dart';
import 'safa_suggested_destination.dart';

/// Validates Edge payloads into [SafaResponse] (Contract §9–§10).
abstract final class SafaResponseValidator {
  /// Banned dependency / diagnosis / cure fragments (case-insensitive).
  static const bannedFragments = <String>[
    "i'm always here for you",
    'i am always here for you',
    'you need me',
    'tell me everything',
    'i know exactly how you feel',
    'your brain is damaged',
    'you are relapsing',
    'you have adhd',
    'you have depression',
    'you have anxiety',
    'this will heal you',
    "i'm your therapist",
    'i am your therapist',
    "don't leave",
    'do not leave',
    'premium',
    'subscribe',
    'upgrade',
  ];

  static bool containsBannedCopy(String text) {
    final lower = text.toLowerCase();
    for (final f in bannedFragments) {
      if (lower.contains(f)) return true;
    }
    return false;
  }

  /// Map unstructured Edge `{reply}` (and optional structured fields) → response.
  static SafaResponse? fromEdgePayload({
    required Object? data,
    required SafaSessionId sessionId,
    required DateTime generatedAt,
  }) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);

    // Prefer structured fields when present; else wrap `reply`.
    final reply = _string(map['reply']) ??
        _string(map['boundedSupportText']) ??
        _string(map['message']);
    if (reply == null || reply.isEmpty) return null;
    if (reply.length > SafaSessionLimit.maxResponseCharacters) return null;
    if (containsBannedCopy(reply)) return null;

    final ack = _string(map['shortAcknowledgement']) ??
        (reply.length <= 80 ? reply : reply.substring(0, 80));
    if (ack.length > 200) return null;

    final support = _string(map['boundedSupportText']) ?? reply;
    if (support.length > SafaSessionLimit.maxResponseCharacters) return null;
    if (containsBannedCopy(support) || containsBannedCopy(ack)) return null;

    final type = SafaResponseTypeX.tryParse(_string(map['responseType'])) ??
        SafaResponseType.clarification;

    final dest = SafaSuggestedDestinationX.tryParse(
          _string(map['suggestedDestination']),
        ) ??
        SafaSuggestedDestination.origin;

    // Reject external / mutation destinations disguised as strings.
    final destRaw = _string(map['suggestedDestination']);
    if (destRaw != null &&
        (destRaw.contains('://') ||
            destRaw.contains('premium') ||
            destRaw.contains('purchase') ||
            destRaw.contains('http'))) {
      return null;
    }

    final actionOverride = _string(map['suggestedAction']);
    if (actionOverride != null && actionOverride.length > 120) return null;
    if (actionOverride != null && containsBannedCopy(actionOverride)) {
      return null;
    }

    final safety = _string(map['safetyQualifier']) ??
        'safa_safety_qualifier_default';

    final responseId = _string(map['responseId']) ??
        'resp_${generatedAt.microsecondsSinceEpoch}';

    final serviceRef = _string(map['serviceVersionRef']) ??
        _string(map['model']) ??
        'safa-chat';

    return SafaResponse(
      responseId: responseId,
      sessionId: sessionId,
      responseType: type,
      shortAcknowledgement: ack.trim(),
      boundedSupportText: support.trim(),
      suggestedAction: SafaSuggestedAction(
        labelKey: 'v2SafaSuggestedReturn',
        labelOverride: actionOverride?.trim(),
      ),
      suggestedDestination: dest,
      safetyQualifier: safety.trim(),
      generatedAt: generatedAt,
      serviceMetadata: SafaServiceMetadata(serviceVersionRef: serviceRef),
      networkUsed: true,
      fallbackUsed: false,
    );
  }

  static String? _string(Object? value) {
    if (value is! String) return null;
    final t = value.trim();
    return t.isEmpty ? null : t;
  }
}
