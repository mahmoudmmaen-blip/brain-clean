import 'package:flutter/foundation.dart';

import 'safa_response_type.dart';
import 'safa_service_metadata.dart';
import 'safa_session_id.dart';
import 'safa_suggested_action.dart';
import 'safa_suggested_destination.dart';

/// Validated SAF-01 response (Contract §9).
@immutable
class SafaResponse {
  const SafaResponse({
    required this.responseId,
    required this.sessionId,
    required this.responseType,
    required this.shortAcknowledgement,
    required this.boundedSupportText,
    required this.suggestedAction,
    required this.suggestedDestination,
    required this.safetyQualifier,
    required this.generatedAt,
    required this.serviceMetadata,
    required this.networkUsed,
    required this.fallbackUsed,
  });

  final String responseId;
  final SafaSessionId sessionId;
  final SafaResponseType responseType;
  final String shortAcknowledgement;
  final String boundedSupportText;
  final SafaSuggestedAction suggestedAction;
  final SafaSuggestedDestination suggestedDestination;
  final String safetyQualifier;
  final DateTime generatedAt;
  final SafaServiceMetadata serviceMetadata;
  final bool networkUsed;
  final bool fallbackUsed;
}
