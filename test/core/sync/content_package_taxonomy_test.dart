import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/sync/content_package_taxonomy.dart';

void main() {
  group('ContentPackageTaxonomy', () {
    test('normalizes known package families', () {
      expect(
        ContentPackageTaxonomy.normalizePackageFamily('Top 500 Words'),
        'top_words',
      );
      expect(ContentPackageTaxonomy.normalizePackageFamily('TOEFL'), 'toefl');
      expect(ContentPackageTaxonomy.normalizePackageFamily('IELTS'), 'ielts');
      expect(
        ContentPackageTaxonomy.normalizePackageFamily('Cambridge English'),
        'cambridge_english',
      );
      expect(
        ContentPackageTaxonomy.normalizePackageFamily('Business English'),
        'business_english',
      );
      expect(
        ContentPackageTaxonomy.normalizePackageFamily('Grammar & Syntax'),
        'grammar_syntax',
      );
      expect(
        ContentPackageTaxonomy.normalizePackageFamily('Phrases & Idioms'),
        'phrases_idioms',
      );
    });

    test('detects top words stages', () {
      expect(ContentPackageTaxonomy.detectTopWordsStage('Top 100'), '100');
      expect(ContentPackageTaxonomy.detectTopWordsStage('Top 200'), '200');
      expect(ContentPackageTaxonomy.detectTopWordsStage('Top 500'), '500');
      expect(ContentPackageTaxonomy.detectTopWordsStage('Top 1-100'), '1-100');
      expect(
        ContentPackageTaxonomy.detectTopWordsStage('Top 101-200'),
        '101-200',
      );
    });

    test('normalizes package types', () {
      expect(
        ContentPackageTaxonomy.normalizePackageType('Top Words'),
        ContentPackageTaxonomy.typeFrequency,
      );
      expect(
        ContentPackageTaxonomy.normalizePackageType('Exam Preparation'),
        ContentPackageTaxonomy.typeExam,
      );
      expect(
        ContentPackageTaxonomy.normalizePackageType('Business English'),
        ContentPackageTaxonomy.typeBusiness,
      );
      expect(
        ContentPackageTaxonomy.normalizePackageType('Phrases & Idioms'),
        ContentPackageTaxonomy.typePhrasePack,
      );
    });
  });
}
