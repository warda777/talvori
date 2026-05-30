import 'package:talvori/core/language/language_code.dart';

class ContentPackageImportMarker {
  ContentPackageImportMarker({
    required String contentPackageId,
    required String languagePair,
    required String version,
    String? checksum,
    required String source,
    required this.importedAt,
    required this.wordCount,
    required this.categoryCount,
  }) : contentPackageId = contentPackageId.trim(),
       languagePair = TalvoriLanguages.normalizeLanguagePair(languagePair),
       version = version.trim(),
       checksum = _normalizeOptional(checksum),
       source = normalizeLanguageToken(source);

  final String contentPackageId;
  final String languagePair;
  final String version;
  final String? checksum;
  final String source;
  final DateTime importedAt;
  final int wordCount;
  final int categoryCount;

  bool get hasRequiredFields {
    return contentPackageId.isNotEmpty &&
        languagePair.isNotEmpty &&
        version.isNotEmpty &&
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
