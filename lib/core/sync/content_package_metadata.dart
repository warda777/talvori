import 'package:talvori/core/language/language_code.dart';

import 'content_package_taxonomy.dart';

class ContentPackageMetadata {
  ContentPackageMetadata({
    required String contentPackageId,
    required String languagePair,
    required String baseLanguage,
    required String learningLanguage,
    required String translationLanguage,
    required String version,
    required String status,
    String? checksum,
    required String source,
    String? minAppVersion,
    String? packageFamily,
    String? packageStage,
    String? packageType,
    String? levelRange,
    String? displayName,
    String? description,
    required this.wordCount,
    required this.categoryCount,
    this.publishedAt,
  }) : contentPackageId = contentPackageId.trim(),
       languagePair = TalvoriLanguages.normalizeLanguagePair(languagePair),
       baseLanguage = TalvoriLanguages.normalizeCode(baseLanguage),
       learningLanguage = TalvoriLanguages.normalizeCode(learningLanguage),
       translationLanguage = TalvoriLanguages.normalizeCode(
         translationLanguage,
       ),
       version = version.trim(),
       status = normalizeLanguageToken(status),
       checksum = _normalizeOptional(checksum),
       source = normalizeLanguageToken(source),
       minAppVersion = _normalizeOptional(minAppVersion),
       packageFamily = _normalizePackageFamily(packageFamily),
       packageStage = _normalizePackageStage(packageStage),
       packageType = _normalizePackageType(packageType),
       levelRange = _normalizeLevelRange(levelRange),
       displayName = _normalizeOptional(displayName),
       description = _normalizeOptional(description);

  final String contentPackageId;
  final String languagePair;
  final String baseLanguage;
  final String learningLanguage;
  final String translationLanguage;
  final String version;
  final String status;
  final String? checksum;
  final String source;
  final String? minAppVersion;
  final String? packageFamily;
  final String? packageStage;
  final String? packageType;
  final String? levelRange;
  final String? displayName;
  final String? description;
  final int wordCount;
  final int categoryCount;
  final DateTime? publishedAt;

  bool get isApproved => status == 'approved';

  bool get hasRequiredFields {
    return contentPackageId.isNotEmpty &&
        languagePair.isNotEmpty &&
        baseLanguage.isNotEmpty &&
        learningLanguage.isNotEmpty &&
        translationLanguage.isNotEmpty &&
        version.isNotEmpty &&
        status.isNotEmpty &&
        source.isNotEmpty &&
        wordCount >= 0 &&
        categoryCount >= 0;
  }
}

String? _normalizeOptional(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

String? _normalizePackageFamily(String? value) {
  final normalized = ContentPackageTaxonomy.normalizePackageFamily(value ?? '');
  if (normalized.isEmpty) return null;
  return normalized;
}

String? _normalizePackageStage(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return ContentPackageTaxonomy.detectTopWordsStage(trimmed) ??
      normalizeLanguageToken(trimmed);
}

String? _normalizePackageType(String? value) {
  final normalized = ContentPackageTaxonomy.normalizePackageType(value ?? '');
  if (normalized.isEmpty) return null;
  return normalized;
}

String? _normalizeLevelRange(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed.toUpperCase().replaceAll(' ', '');
}
