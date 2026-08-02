import 'profile_pack.dart';

/// Outcome of attempting to build a ProfilePack from a Brain Check.
sealed class ProfileGenerationResult {
  const ProfileGenerationResult();
}

class ProfileGenerationSuccess extends ProfileGenerationResult {
  const ProfileGenerationSuccess({
    required this.profile,
    required this.wasExisting,
  });

  final ProfilePack profile;
  final bool wasExisting;
}

class ProfileGenerationFailure extends ProfileGenerationResult {
  const ProfileGenerationFailure({
    required this.code,
    required this.messageEn,
    required this.messageAr,
  });

  final ProfileGenerationErrorCode code;
  final String messageEn;
  final String messageAr;
}

enum ProfileGenerationErrorCode {
  incompleteAnswers,
  emptyEvent,
  calculationUnavailable,
  persistenceFailed,
}
