/// Internal domain history point — never show [domainId] to users.
class DomainHistoryPoint {
  const DomainHistoryPoint({
    required this.profilePackId,
    required this.measurementDayKey,
    required this.domainId,
    required this.titleEn,
    required this.titleAr,
    required this.displayedEstimate,
    required this.scoreModelVersion,
    required this.profileSchemaVersion,
    required this.confidenceWire,
  });

  final String profilePackId;
  final String measurementDayKey;
  final String domainId;
  final String titleEn;
  final String titleAr;
  final int? displayedEstimate;
  final String scoreModelVersion;
  final String profileSchemaVersion;
  final String confidenceWire;

  String titleForLocale(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;
}
