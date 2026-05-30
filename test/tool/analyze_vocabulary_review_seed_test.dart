import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/analyze_vocabulary_review_seed.dart';
import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  String seedCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([vocabularyReviewSeedHeader, ...rows]);
  }

  List<String> row({
    required String wordKey,
    required String baseTerm,
    required String deTranslation,
    String baseLanguage = 'en',
    String normalizedBaseTerm = '',
    String level = 'A1',
    String category = 'Basics',
    String wordWorld = 'Basics',
    String reviewStatus = 'needs_review',
    String releaseReady = 'false',
    String esTranslation = '',
    String frTranslation = '',
  }) {
    return [
      wordKey,
      baseLanguage,
      baseTerm,
      normalizedBaseTerm.isEmpty
          ? normalizeReviewBaseTerm(baseTerm)
          : normalizedBaseTerm,
      '',
      '',
      '',
      level,
      category,
      wordWorld,
      deTranslation,
      esTranslation,
      frTranslation,
      '',
      '',
      '',
      '',
      '',
      reviewStatus,
      '',
      '',
      releaseReady,
    ];
  }

  test('counts rows, unique keys, terms and language pairs', () {
    final analysis = analyzeVocabularyReviewSeedCsv(
      seedCsv([
        row(wordKey: 'word-1', baseTerm: 'move', deTranslation: 'bewegen'),
        row(wordKey: 'word-2', baseTerm: 'walk', deTranslation: 'gehen'),
      ]),
    );

    expect(analysis.totalRows, 2);
    expect(analysis.uniqueWordKeys, 2);
    expect(analysis.uniqueBaseTerms, 2);
    expect(analysis.languagePairDistribution['en->de'], 2);
    expect(analysis.levelDistribution['A1'], 2);
  });

  test('flags approved and release ready rows as safety problems', () {
    final analysis = analyzeVocabularyReviewSeedCsv(
      seedCsv([
        row(
          wordKey: 'word-1',
          baseTerm: 'move',
          deTranslation: 'bewegen',
          reviewStatus: 'approved',
          releaseReady: 'true',
        ),
      ]),
    );

    expect(analysis.allNeedsReview, isFalse);
    expect(analysis.allReleaseReadyFalse, isFalse);
    expect(analysis.approvedRows, hasLength(1));
    expect(analysis.releaseReadyTrueRows, hasLength(1));
  });

  test('detects empty translations and url/html suspects', () {
    final analysis = analyzeVocabularyReviewSeedCsv(
      seedCsv([
        row(wordKey: 'word-1', baseTerm: 'move', deTranslation: ''),
        row(
          wordKey: 'word-2',
          baseTerm: 'open https://example.com',
          deTranslation: 'öffnen',
        ),
      ]),
    );

    expect(analysis.emptyTranslationCandidates, hasLength(1));
    expect(analysis.urlOrHtmlRows, hasLength(1));
  });

  test('detects exact duplicates', () {
    final analysis = analyzeVocabularyReviewSeedCsv(
      seedCsv([
        row(wordKey: 'word-1', baseTerm: 'move', deTranslation: 'bewegen'),
        row(wordKey: 'word-2', baseTerm: 'move', deTranslation: 'bewegen'),
      ]),
    );

    expect(analysis.duplicateCandidates, hasLength(2));
    expect(analysis.duplicateCandidates.first.issueType, 'exact_duplicate');
  });

  test('detects same base term with different translations', () {
    final analysis = analyzeVocabularyReviewSeedCsv(
      seedCsv([
        row(wordKey: 'word-1', baseTerm: 'move', deTranslation: 'bewegen'),
        row(wordKey: 'word-2', baseTerm: 'move', deTranslation: 'umziehen'),
      ]),
    );

    expect(analysis.meaningVariantCandidates, hasLength(2));
    expect(
      analysis.meaningVariantCandidates.first.issueType,
      'same_base_different_translation',
    );
  });

  test('detects structure issues', () {
    final analysis = analyzeVocabularyReviewSeedCsv(
      seedCsv([
        row(
          wordKey: 'word-1',
          baseTerm: 'move',
          deTranslation: 'bewegen',
          level: '',
          category: '',
          wordWorld: 'Top 500 Words',
        ),
      ]),
    );

    expect(analysis.missingLevelRows, hasLength(1));
    expect(analysis.missingCategoryRows, hasLength(1));
    expect(analysis.top500AsCategoryRows, hasLength(1));
    expect(analysis.structureIssueCandidates.length, greaterThanOrEqualTo(3));
  });

  test('renders report and writes candidate files', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_seed_analysis_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/seed.csv')
      ..writeAsStringSync(
        seedCsv([
          row(wordKey: 'word-1', baseTerm: 'move', deTranslation: ''),
          row(wordKey: 'word-2', baseTerm: 'move', deTranslation: ''),
        ]),
      );

    final result = analyzeVocabularyReviewSeed(
      VocabularyReviewSeedAnalysisOptions(
        inputPath: input.path,
        reportPath: '${tempDir.path}/report.md',
        emptyTranslationCandidatesPath: '${tempDir.path}/empty.csv',
        duplicateCandidatesPath: '${tempDir.path}/duplicates.csv',
        meaningVariantCandidatesPath: '${tempDir.path}/meaning.csv',
        structureIssueCandidatesPath: '${tempDir.path}/structure.csv',
      ),
    );

    expect(result.analysis.totalRows, 2);
    expect(
      File('${tempDir.path}/report.md').readAsStringSync(),
      contains('Grundzahlen'),
    );
    expect(
      File('${tempDir.path}/empty.csv').readAsStringSync(),
      contains('empty_de_translation'),
    );
    expect(
      File('${tempDir.path}/duplicates.csv').readAsStringSync(),
      contains('exact_duplicate'),
    );
  });
}
