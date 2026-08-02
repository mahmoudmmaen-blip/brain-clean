import '../../brain_check/domain/brain_check_mode.dart';

/// Link from a ProfilePack back to its source Brain Check session.
class ProfileSourceReference {
  const ProfileSourceReference({
    required this.sessionId,
    required this.mode,
    required this.brainCheckSchemaVersion,
    this.source,
  });

  final String sessionId;
  final BrainCheckMode mode;
  final String brainCheckSchemaVersion;
  final String? source;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sessionId': sessionId,
        'mode': mode.wireName,
        'brainCheckSchemaVersion': brainCheckSchemaVersion,
        if (source != null) 'source': source,
      };

  factory ProfileSourceReference.fromJson(Map<String, dynamic> json) {
    return ProfileSourceReference(
      sessionId: json['sessionId'] as String,
      mode: BrainCheckModeX.fromWire(json['mode'] as String?),
      brainCheckSchemaVersion: json['brainCheckSchemaVersion'] as String? ??
          'brain_check_measurement_v1',
      source: json['source'] as String?,
    );
  }
}
