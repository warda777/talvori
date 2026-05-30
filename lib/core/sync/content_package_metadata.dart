import 'package:talvori/core/language/language_code.dart';

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
       minAppVersion = _normalizeOptional(minAppVersion);

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
