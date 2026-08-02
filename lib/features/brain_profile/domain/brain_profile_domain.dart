/// Canonical domain id for Brain Profile (maps to Brain Check sections).
class BrainProfileDomain {
  const BrainProfileDomain({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.definitionEn,
    required this.definitionAr,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String definitionEn;
  final String definitionAr;

  String titleForLocale(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;

  String definitionForLocale(String languageCode) =>
      languageCode == 'ar' ? definitionAr : definitionEn;
}
