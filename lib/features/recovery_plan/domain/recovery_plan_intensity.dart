/// Plan intensity — contract §8 (never severe/clinical).
enum RecoveryPlanIntensity {
  light,
  standard,
  supported,
}

extension RecoveryPlanIntensityX on RecoveryPlanIntensity {
  String get wireName => name;

  String get labelEn => switch (this) {
        RecoveryPlanIntensity.light => 'Light',
        RecoveryPlanIntensity.standard => 'Standard',
        RecoveryPlanIntensity.supported => 'Supported',
      };

  String get labelAr => switch (this) {
        RecoveryPlanIntensity.light => 'خفيف',
        RecoveryPlanIntensity.standard => 'قياسي',
        RecoveryPlanIntensity.supported => 'مدعوم',
      };

  String labelForLocale(String languageCode) =>
      languageCode == 'ar' ? labelAr : labelEn;

  int get requiredStepCount => switch (this) {
        RecoveryPlanIntensity.light => 1,
        RecoveryPlanIntensity.standard => 2,
        RecoveryPlanIntensity.supported => 2,
      };

  int get maxOptionalSteps => switch (this) {
        RecoveryPlanIntensity.light => 1,
        RecoveryPlanIntensity.standard => 1,
        RecoveryPlanIntensity.supported => 2,
      };

  int get maxTotalSteps => switch (this) {
        RecoveryPlanIntensity.light => 2,
        RecoveryPlanIntensity.standard => 3,
        RecoveryPlanIntensity.supported => 3,
      };

  int get minPathMinutesMin => switch (this) {
        RecoveryPlanIntensity.light => 3,
        RecoveryPlanIntensity.standard => 5,
        RecoveryPlanIntensity.supported => 5,
      };

  int get minPathMinutesMax => switch (this) {
        RecoveryPlanIntensity.light => 5,
        RecoveryPlanIntensity.standard => 5,
        RecoveryPlanIntensity.supported => 7,
      };

  int get standardPathMinutesMin => switch (this) {
        RecoveryPlanIntensity.light => 8,
        RecoveryPlanIntensity.standard => 12,
        RecoveryPlanIntensity.supported => 15,
      };

  int get standardPathMinutesMax => switch (this) {
        RecoveryPlanIntensity.light => 12,
        RecoveryPlanIntensity.standard => 18,
        RecoveryPlanIntensity.supported => 20,
      };

  static RecoveryPlanIntensity fromWire(String? raw) {
    switch (raw) {
      case 'supported':
        return RecoveryPlanIntensity.supported;
      case 'standard':
        return RecoveryPlanIntensity.standard;
      case 'light':
      default:
        return RecoveryPlanIntensity.light;
    }
  }
}
