import 'package:flutter/foundation.dart';

import 'safa_context_category.dart';
import 'safa_session_id.dart';
import 'safa_session_origin.dart';

/// Allowlisted network request body material (Contract §7.3).
@immutable
class SafaRequest {
  const SafaRequest({
    required this.sessionId,
    required this.message,
    required this.locale,
    required this.origin,
    this.contextCategory = SafaContextCategory.none,
    this.approvedContextSummary,
    this.approvedStepTitle,
  });

  final SafaSessionId sessionId;
  final String message;
  final String locale;
  final SafaSessionOrigin origin;
  final SafaContextCategory contextCategory;
  final String? approvedContextSummary;
  final String? approvedStepTitle;
}
