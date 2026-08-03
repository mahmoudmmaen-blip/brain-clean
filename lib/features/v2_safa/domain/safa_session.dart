import 'package:flutter/foundation.dart';

import 'safa_consent_state.dart';
import 'safa_context_category.dart';
import 'safa_failure_reason.dart';
import 'safa_response.dart';
import 'safa_session_id.dart';
import 'safa_session_limit.dart';
import 'safa_session_origin.dart';
import 'safa_session_state.dart';
import 'safa_version.dart';

/// In-memory SAF-01 session — no raw conversation archive (Contract §13).
@immutable
class SafaSession {
  const SafaSession({
    required this.id,
    required this.origin,
    required this.returnPath,
    required this.locale,
    required this.consentState,
    required this.uiState,
    required this.userMessageCount,
    required this.assistantResponseCount,
    required this.draftMessage,
    required this.contextCategory,
    required this.includeApprovedContext,
    this.approvedContextSummary,
    this.approvedStepTitle,
    this.latestResponse,
    this.failureReason = SafaFailureReason.none,
    required this.createdAt,
    required this.updatedAt,
    this.schemaVersion = SafaVersion.schemaVersion,
    this.initialView,
  });

  final SafaSessionId id;
  final SafaSessionOrigin origin;
  final String returnPath;
  final String locale;
  final SafaConsentState consentState;
  final SafaSessionState uiState;
  final int userMessageCount;
  final int assistantResponseCount;
  final String draftMessage;
  final SafaContextCategory contextCategory;
  final bool includeApprovedContext;
  final String? approvedContextSummary;
  final String? approvedStepTitle;
  final SafaResponse? latestResponse;
  final SafaFailureReason failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String schemaVersion;

  /// Route view: privacy | unavailable | urgent | null
  final String? initialView;

  bool get isBoundReached =>
      userMessageCount >= SafaSessionLimit.maxUserMessages ||
      assistantResponseCount >= SafaSessionLimit.maxAssistantResponses;

  bool get canSendNetwork =>
      consentState == SafaConsentState.granted &&
      !isBoundReached &&
      uiState != SafaSessionState.sending;

  SafaSession copyWith({
    SafaConsentState? consentState,
    SafaSessionState? uiState,
    int? userMessageCount,
    int? assistantResponseCount,
    String? draftMessage,
    SafaContextCategory? contextCategory,
    bool? includeApprovedContext,
    String? approvedContextSummary,
    bool clearApprovedContextSummary = false,
    String? approvedStepTitle,
    bool clearApprovedStepTitle = false,
    SafaResponse? latestResponse,
    bool clearLatestResponse = false,
    SafaFailureReason? failureReason,
    DateTime? updatedAt,
    String? initialView,
    bool clearInitialView = false,
  }) {
    return SafaSession(
      id: id,
      origin: origin,
      returnPath: returnPath,
      locale: locale,
      consentState: consentState ?? this.consentState,
      uiState: uiState ?? this.uiState,
      userMessageCount: userMessageCount ?? this.userMessageCount,
      assistantResponseCount:
          assistantResponseCount ?? this.assistantResponseCount,
      draftMessage: draftMessage ?? this.draftMessage,
      contextCategory: contextCategory ?? this.contextCategory,
      includeApprovedContext:
          includeApprovedContext ?? this.includeApprovedContext,
      approvedContextSummary: clearApprovedContextSummary
          ? null
          : (approvedContextSummary ?? this.approvedContextSummary),
      approvedStepTitle: clearApprovedStepTitle
          ? null
          : (approvedStepTitle ?? this.approvedStepTitle),
      latestResponse:
          clearLatestResponse ? null : (latestResponse ?? this.latestResponse),
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schemaVersion: schemaVersion,
      initialView: clearInitialView ? null : (initialView ?? this.initialView),
    );
  }
}
