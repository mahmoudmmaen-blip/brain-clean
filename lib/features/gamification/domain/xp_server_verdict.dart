/// Server verdict for a single XP ledger entry after [verify-xp] validation.
class XpServerVerdict {
  const XpServerVerdict({
    required this.id,
    required this.accepted,
    this.reason,
  });

  final String id;
  final bool accepted;
  final String? reason;

  factory XpServerVerdict.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? '';
    return XpServerVerdict(
      id: json['id'] as String? ?? '',
      accepted: status == 'accepted',
      reason: json['reason'] as String?,
    );
  }
}

/// Response payload from the [verify-xp] Edge Function.
class XpVerifyResponse {
  const XpVerifyResponse({
    required this.verdicts,
    required this.serverTotalXp,
  });

  final List<XpServerVerdict> verdicts;
  final int serverTotalXp;

  factory XpVerifyResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['verdicts'];
    final verdicts = <XpServerVerdict>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          verdicts.add(
            XpServerVerdict.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return XpVerifyResponse(
      verdicts: verdicts,
      serverTotalXp: (json['serverTotalXp'] as num?)?.toInt() ?? 0,
    );
  }
}
