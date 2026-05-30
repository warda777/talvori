import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/sync/content_package_metadata.dart';

void main() {
  ContentPackageMetadata metadata({
    String contentPackageId = 'top-100-en-de-v1',
    String packageFamily = 'Top 500 Words',
    String packageStage = 'Top 1-100',
    String packageType = 'frequency',
    String levelRange = 'A1-B2',
  }) {
    return ContentPackageMetadata(
      contentPackageId: contentPackageId,
      languagePair: 'EN-DE',
      baseLanguage: 'EN',
      learningLanguage: 'EN',
      translationLanguage: 'DE',
      version: '1.0.0',
      status: 'APPROVED',
      checksum: 'abc123',
      source: 'Supabase',
      minAppVersion: '1.0.0',
      packageFamily: packageFamily,
      packageStage: packageStage,
      packageType: packageType,
      levelRange: levelRange,
      displayName: 'Top 100',
      description: 'First top words package.',
      wordCount: 100,
      categoryCount: 4,
    );
  }

  test('normalizes top words package metadata fields', () {
    final package = metadata();

    expect(package.languagePair, 'en-de');
    expect(package.packageFamily, 'top_words');
    expect(package.packageStage, '1-100');
    expect(package.packageType, 'frequency');
    expect(package.levelRange, 'A1-B2');
    expect(package.displayName, 'Top 100');
    expect(package.description, 'First top words package.');
    expect(package.hasRequiredFields, isTrue);
  });

  test('normalizes TOEFL exam metadata fields', () {
    final package = metadata(
      contentPackageId: 'toefl-academic-en-de-v1',
      packageFamily: 'TOEFL',
      packageStage: 'Academic',
      packageType: 'exam',
      levelRange: 'B2 - C1',
    );

    expect(package.packageFamily, 'toefl');
    expect(package.packageStage, 'academic');
    expect(package.packageType, 'exam');
    expect(package.levelRange, 'B2-C1');
  });
}
