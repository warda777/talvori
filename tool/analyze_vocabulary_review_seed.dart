import 'dart:io';

import 'export_vocabulary_review_seed.dart';

const defaultVocabularyReviewSeedInputPath =
    'docs/word-review/vocabulary_review_seed.csv';
const defaultVocabularyReviewSeedReportPath =
    'docs/word-review/vocabulary_review_seed_quality_report.md';
const defaultSeedEmptyTranslationCandidatesPath =
    'docs/word-review/seed_empty_translation_candidates.csv';
const defaultSeedDuplicateCandidatesPath =
    'docs/word-review/seed_duplicate_candidates.csv';
const defaultSeedMeaningVariantCandidatesPath =
    'docs/word-review/seed_meaning_variant_candidates.csv';
const defaultSeedStructureIssueCandidatesPath =
    'docs/word-review/seed_structure_issue_candidates.csv';
const seedCandidateListLimit = 200;

Future<void> main(List<String> args) async {
  final options = VocabularyReviewSeedAnalysisOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(VocabularyReviewSeedAnalysisOptions.usage);
    return;
  }

  try {
    final result = analyzeVocabularyReviewSeed(options);
    stdout
      ..writeln('Analyzed ${result.analysis.totalRows} seed rows.')
      ..writeln('Wrote report to ${options.reportPath}.')
      ..writeln(
        'Wrote candidate lists: '
        '${result.emptyTranslationCandidatesWritten} empty translations, '
        '${result.duplicateCandidatesWritten} duplicates, '
        '${result.meaningVariantCandidatesWritten} meaning variants, '
        '${result.structureIssueCandidatesWritten} structure issues.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Vocabulary review seed analysis failed: $error');
    exitCode = 1;
  }
}

class VocabularyReviewSeedAnalysisOptions {
  const VocabularyReviewSeedAnalysisOptions({
    required this.inputPath,
    required this.reportPath,
    required this.emptyTranslationCandidatesPath,
    required this.duplicateCandidatesPath,
    required this.meaningVariantCandidatesPath,
    required this.structureIssueCandidatesPath,
    this.help = false,
  });

  factory VocabularyReviewSeedAnalysisOptions.defaults() {
    return const VocabularyReviewSeedAnalysisOptions(
      inputPath: defaultVocabularyReviewSeedInputPath,
      reportPath: defaultVocabularyReviewSeedReportPath,
      emptyTranslationCandidatesPath: defaultSeedEmptyTranslationCandidatesPath,
      duplicateCandidatesPath: defaultSeedDuplicateCandidatesPath,
      meaningVariantCandidatesPath: defaultSeedMeaningVariantCandidatesPath,
      structureIssueCandidatesPath: defaultSeedStructureIssueCandidatesPath,
    );
  }

  factory VocabularyReviewSeedAnalysisOptions.fromArgs(List<String> args) {
    var options = VocabularyReviewSeedAnalysisOptions.defaults();
    var help = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--input') {
        _requireValue(args, index, '--input');
        options = options.copyWith(inputPath: args[++index]);
      } else if (arg == '--report') {
        _requireValue(args, index, '--report');
        options = options.copyWith(reportPath: args[++index]);
      } else if (arg == '--empty-translations') {
        _requireValue(args, index, '--empty-translations');
        options = options.copyWith(
          emptyTranslationCandidatesPath: args[++index],
        );
      } else if (arg == '--duplicates') {
        _requireValue(args, index, '--duplicates');
        options = options.copyWith(duplicateCandidatesPath: args[++index]);
      } else if (arg == '--meaning-variants') {
        _requireValue(args, index, '--meaning-variants');
        options = options.copyWith(meaningVariantCandidatesPath: args[++index]);
      } else if (arg == '--structure-issues') {
        _requireValue(args, index, '--structure-issues');
        options = options.copyWith(structureIssueCandidatesPath: args[++index]);
      } else if (arg == '--help' || arg == '-h') {
        help = true;
      } else {
        throw FormatException('Unknown argument: $arg');
      }
    }

    return options.copyWith(help: help);
  }

  static const usage = '''
Usage:
  dart tool/analyze_vocabulary_review_seed.dart [--input <path>] [--report <path>]

Defaults:
  --input  docs/word-review/vocabulary_review_seed.csv
  --report docs/word-review/vocabulary_review_seed_quality_report.md

This tool only reads the local review seed CSV and writes markdown/CSV analysis
artifacts. It does not connect to Supabase, SQLite, import data, correct words,
call AI, or approve review rows.
''';

  final String inputPath;
  final String reportPath;
  final String emptyTranslationCandidatesPath;
  final String duplicateCandidatesPath;
  final String meaningVariantCandidatesPath;
  final String structureIssueCandidatesPath;
  final bool help;

  VocabularyReviewSeedAnalysisOptions copyWith({
    String? inputPath,
    String? reportPath,
    String? emptyTranslationCandidatesPath,
    String? duplicateCandidatesPath,
    String? meaningVariantCandidatesPath,
    String? structureIssueCandidatesPath,
    bool? help,
  }) {
    return VocabularyReviewSeedAnalysisOptions(
      inputPath: inputPath ?? this.inputPath,
      reportPath: reportPath ?? this.reportPath,
      emptyTranslationCandidatesPath:
          emptyTranslationCandidatesPath ?? this.emptyTranslationCandidatesPath,
      duplicateCandidatesPath:
          duplicateCandidatesPath ?? this.duplicateCandidatesPath,
      meaningVariantCandidatesPath:
          meaningVariantCandidatesPath ?? this.meaningVariantCandidatesPath,
      structureIssueCandidatesPath:
          structureIssueCandidatesPath ?? this.structureIssueCandidatesPath,
      help: help ?? this.help,
    );
  }
}

class VocabularyReviewSeedAnalysisRunResult {
  const VocabularyReviewSeedAnalysisRunResult({
    required this.analysis,
    required this.emptyTranslationCandidatesWritten,
    required this.duplicateCandidatesWritten,
    required this.meaningVariantCandidatesWritten,
    required this.structureIssueCandidatesWritten,
  });

  final VocabularyReviewSeedAnalysis analysis;
  final int emptyTranslationCandidatesWritten;
  final int duplicateCandidatesWritten;
  final int meaningVariantCandidatesWritten;
  final int structureIssueCandidatesWritten;
}

VocabularyReviewSeedAnalysisRunResult analyzeVocabularyReviewSeed(
  VocabularyReviewSeedAnalysisOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException('Seed CSV not found', options.inputPath);
  }

  final analysis = analyzeVocabularyReviewSeedCsv(inputFile.readAsStringSync());
  _writeTextFile(
    options.reportPath,
    renderVocabularyReviewSeedReport(analysis),
  );
  final emptyCount = _writeCandidateCsv(
    options.emptyTranslationCandidatesPath,
    analysis.emptyTranslationCandidates,
  );
  final duplicateCount = _writeCandidateCsv(
    options.duplicateCandidatesPath,
    analysis.duplicateCandidates,
  );
  final meaningVariantCount = _writeCandidateCsv(
    options.meaningVariantCandidatesPath,
    analysis.meaningVariantCandidates,
  );
  final structureIssueCount = _writeCandidateCsv(
    options.structureIssueCandidatesPath,
    analysis.structureIssueCandidates,
  );

  return VocabularyReviewSeedAnalysisRunResult(
    analysis: analysis,
    emptyTranslationCandidatesWritten: emptyCount,
    duplicateCandidatesWritten: duplicateCount,
    meaningVariantCandidatesWritten: meaningVariantCount,
    structureIssueCandidatesWritten: structureIssueCount,
  );
}

class VocabularyReviewSeedAnalysis {
  const VocabularyReviewSeedAnalysis({
    required this.totalRows,
    required this.uniqueWordKeys,
    required this.uniqueBaseTerms,
    required this.languagePairDistribution,
    required this.levelDistribution,
    required this.categoryDistribution,
    required this.wordWorldDistribution,
    required this.reviewStatusDistribution,
    required this.releaseReadyDistribution,
    required this.baseLanguageDistribution,
    required this.allNeedsReview,
    required this.allReleaseReadyFalse,
    required this.allSpanishEmpty,
    required this.allFrenchEmpty,
    required this.approvedRows,
    required this.releaseReadyTrueRows,
    required this.unexpectedBaseLanguageRows,
    required this.uppercaseBaseLanguageRows,
    required this.emptyTranslationCandidates,
    required this.sameBaseAndTranslationRows,
    required this.longTranslationRows,
    required this.translationVariantRows,
    required this.urlOrHtmlRows,
    required this.duplicateCandidates,
    required this.caseVariantRows,
    required this.meaningVariantCandidates,
    required this.missingLevelRows,
    required this.unusualLevelRows,
    required this.missingCategoryRows,
    required this.missingWordWorldRows,
    required this.levelAsCategoryRows,
    required this.top500AsCategoryRows,
    required this.smallCategories,
    required this.largeCategories,
    required this.structureIssueCandidates,
  });

  final int totalRows;
  final int uniqueWordKeys;
  final int uniqueBaseTerms;
  final Map<String, int> languagePairDistribution;
  final Map<String, int> levelDistribution;
  final Map<String, int> categoryDistribution;
  final Map<String, int> wordWorldDistribution;
  final Map<String, int> reviewStatusDistribution;
  final Map<String, int> releaseReadyDistribution;
  final Map<String, int> baseLanguageDistribution;
  final bool allNeedsReview;
  final bool allReleaseReadyFalse;
  final bool allSpanishEmpty;
  final bool allFrenchEmpty;
  final List<VocabularyReviewSeedIssueRow> approvedRows;
  final List<VocabularyReviewSeedIssueRow> releaseReadyTrueRows;
  final List<VocabularyReviewSeedIssueRow> unexpectedBaseLanguageRows;
  final List<VocabularyReviewSeedIssueRow> uppercaseBaseLanguageRows;
  final List<VocabularyReviewSeedIssueRow> emptyTranslationCandidates;
  final List<VocabularyReviewSeedIssueRow> sameBaseAndTranslationRows;
  final List<VocabularyReviewSeedIssueRow> longTranslationRows;
  final List<VocabularyReviewSeedIssueRow> translationVariantRows;
  final List<VocabularyReviewSeedIssueRow> urlOrHtmlRows;
  final List<VocabularyReviewSeedIssueRow> duplicateCandidates;
  final List<VocabularyReviewSeedIssueRow> caseVariantRows;
  final List<VocabularyReviewSeedIssueRow> meaningVariantCandidates;
  final List<VocabularyReviewSeedIssueRow> missingLevelRows;
  final List<VocabularyReviewSeedIssueRow> unusualLevelRows;
  final List<VocabularyReviewSeedIssueRow> missingCategoryRows;
  final List<VocabularyReviewSeedIssueRow> missingWordWorldRows;
  final List<VocabularyReviewSeedIssueRow> levelAsCategoryRows;
  final List<VocabularyReviewSeedIssueRow> top500AsCategoryRows;
  final Map<String, int> smallCategories;
  final Map<String, int> largeCategories;
  final List<VocabularyReviewSeedIssueRow> structureIssueCandidates;
}

class VocabularyReviewSeedIssueRow {
  const VocabularyReviewSeedIssueRow({
    required this.issueType,
    required this.wordKey,
    required this.baseLanguage,
    required this.baseTerm,
    required this.deTranslation,
    required this.level,
    required this.category,
    required this.wordWorld,
    this.detail = '',
  });

  final String issueType;
  final String wordKey;
  final String baseLanguage;
  final String baseTerm;
  final String deTranslation;
  final String level;
  final String category;
  final String wordWorld;
  final String detail;

  List<String> toCsvRow() {
    return [
      issueType,
      wordKey,
      baseLanguage,
      baseTerm,
      deTranslation,
      level,
      category,
      wordWorld,
      detail,
    ];
  }
}

VocabularyReviewSeedAnalysis analyzeVocabularyReviewSeedCsv(String input) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Seed CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateMasterHeaders(headers);
  final rows = <Map<String, String>>[
    for (var index = 1; index < records.length; index++)
      _rowValues(headers, records[index]),
  ];

  final wordKeys = <String>{};
  final baseTerms = <String>{};
  final languagePairs = <String, int>{};
  final levels = <String, int>{};
  final categories = <String, int>{};
  final wordWorlds = <String, int>{};
  final reviewStatuses = <String, int>{};
  final releaseReadyValues = <String, int>{};
  final baseLanguages = <String, int>{};
  final rowsByExactDuplicateKey =
      <String, List<VocabularyReviewSeedIssueRow>>{};
  final rowsByNormalizedTerm = <String, List<VocabularyReviewSeedIssueRow>>{};
  final translationsByNormalizedTerm = <String, Set<String>>{};
  final rowsByNormalizedBaseAndTranslation =
      <String, List<VocabularyReviewSeedIssueRow>>{};

  final approvedRows = <VocabularyReviewSeedIssueRow>[];
  final releaseReadyTrueRows = <VocabularyReviewSeedIssueRow>[];
  final unexpectedBaseLanguageRows = <VocabularyReviewSeedIssueRow>[];
  final uppercaseBaseLanguageRows = <VocabularyReviewSeedIssueRow>[];
  final emptyTranslations = <VocabularyReviewSeedIssueRow>[];
  final sameBaseAndTranslation = <VocabularyReviewSeedIssueRow>[];
  final longTranslations = <VocabularyReviewSeedIssueRow>[];
  final translationVariants = <VocabularyReviewSeedIssueRow>[];
  final urlOrHtmlRows = <VocabularyReviewSeedIssueRow>[];
  final missingLevels = <VocabularyReviewSeedIssueRow>[];
  final unusualLevels = <VocabularyReviewSeedIssueRow>[];
  final missingCategories = <VocabularyReviewSeedIssueRow>[];
  final missingWordWorlds = <VocabularyReviewSeedIssueRow>[];
  final levelAsCategories = <VocabularyReviewSeedIssueRow>[];
  final top500AsCategories = <VocabularyReviewSeedIssueRow>[];
  final structureIssues = <VocabularyReviewSeedIssueRow>[];

  for (final row in rows) {
    final issueRow = _issueRow(row, 'row');
    final wordKey = row['word_key']?.trim() ?? '';
    final baseLanguage = row['base_language']?.trim() ?? '';
    final baseTerm = row['base_term']?.trim() ?? '';
    final normalizedBaseTerm =
        row['normalized_base_term']?.trim().toLowerCase() ??
        normalizeReviewBaseTerm(baseTerm);
    final deTranslation = row['de_translation']?.trim() ?? '';
    final normalizedTranslation = normalizeReviewBaseTerm(deTranslation);
    final level = row['level']?.trim() ?? '';
    final category = row['category']?.trim() ?? '';
    final wordWorld = row['word_world']?.trim() ?? '';
    final reviewStatus = row['review_status']?.trim() ?? '';
    final releaseReady = row['release_ready']?.trim() ?? '';
    final spanish = row['es_translation']?.trim() ?? '';
    final french = row['fr_translation']?.trim() ?? '';

    if (wordKey.isNotEmpty) wordKeys.add(wordKey);
    if (baseTerm.isNotEmpty) baseTerms.add(baseTerm);
    _increment(baseLanguages, baseLanguage.isEmpty ? '(leer)' : baseLanguage);
    _increment(levels, level.isEmpty ? '(leer)' : level);
    _increment(categories, category.isEmpty ? '(leer)' : category);
    _increment(wordWorlds, wordWorld.isEmpty ? '(leer)' : wordWorld);
    _increment(reviewStatuses, reviewStatus.isEmpty ? '(leer)' : reviewStatus);
    _increment(
      releaseReadyValues,
      releaseReady.isEmpty ? '(leer)' : releaseReady,
    );
    _increment(
      languagePairs,
      '$baseLanguage->${deTranslation.isEmpty ? '(keine de_translation)' : 'de'}',
    );

    if (reviewStatus == 'approved') {
      approvedRows.add(_issueRow(row, 'approved_status'));
    }
    if (releaseReady == 'true') {
      releaseReadyTrueRows.add(_issueRow(row, 'release_ready_true'));
    }
    if (!_expectedBaseLanguages.contains(baseLanguage)) {
      unexpectedBaseLanguageRows.add(
        _issueRow(row, 'unexpected_base_language'),
      );
    }
    if (baseLanguage != baseLanguage.toLowerCase()) {
      uppercaseBaseLanguageRows.add(_issueRow(row, 'uppercase_base_language'));
    }
    if (deTranslation.isEmpty) {
      emptyTranslations.add(_issueRow(row, 'empty_de_translation'));
    }
    if (normalizedBaseTerm.isNotEmpty &&
        normalizedBaseTerm == normalizedTranslation) {
      sameBaseAndTranslation.add(_issueRow(row, 'same_base_and_translation'));
    }
    if (deTranslation.length > 80) {
      longTranslations.add(_issueRow(row, 'long_de_translation'));
    }
    if (_hasVariantSeparator(deTranslation)) {
      translationVariants.add(_issueRow(row, 'translation_variant_separator'));
    }
    if (_looksLikeUrlOrHtml(baseTerm) || _looksLikeUrlOrHtml(deTranslation)) {
      urlOrHtmlRows.add(_issueRow(row, 'url_or_html_suspect'));
    }
    if (level.isEmpty) {
      final issue = _issueRow(row, 'missing_level');
      missingLevels.add(issue);
      structureIssues.add(issue);
    } else if (!_expectedLevels.contains(level)) {
      final issue = _issueRow(row, 'unusual_level');
      unusualLevels.add(issue);
      structureIssues.add(issue);
    }
    if (category.isEmpty) {
      final issue = _issueRow(row, 'missing_category');
      missingCategories.add(issue);
      structureIssues.add(issue);
    }
    if (wordWorld.isEmpty) {
      final issue = _issueRow(row, 'missing_word_world');
      missingWordWorlds.add(issue);
      structureIssues.add(issue);
    }
    if (_containsLevelLabel(category) || _containsLevelLabel(wordWorld)) {
      final issue = _issueRow(row, 'level_as_category_or_word_world');
      levelAsCategories.add(issue);
      structureIssues.add(issue);
    }
    if (_containsTop500(category) || _containsTop500(wordWorld)) {
      final issue = _issueRow(row, 'top_500_as_category_or_word_world');
      top500AsCategories.add(issue);
      structureIssues.add(issue);
    }

    final exactDuplicateKey =
        '$baseLanguage|$normalizedBaseTerm|$normalizedTranslation';
    rowsByExactDuplicateKey
        .putIfAbsent(exactDuplicateKey, () => [])
        .add(issueRow);
    rowsByNormalizedTerm
        .putIfAbsent(normalizedBaseTerm, () => [])
        .add(issueRow);
    translationsByNormalizedTerm
        .putIfAbsent(normalizedBaseTerm, () => <String>{})
        .add(normalizedTranslation);
    rowsByNormalizedBaseAndTranslation
        .putIfAbsent('$normalizedBaseTerm|$normalizedTranslation', () => [])
        .add(issueRow);

    if (spanish.isNotEmpty || french.isNotEmpty) {
      structureIssues.add(_issueRow(row, 'unexpected_es_or_fr_translation'));
    }
  }

  final duplicateCandidates = _flattenDuplicateGroups(
    rowsByExactDuplicateKey,
    issueType: 'exact_duplicate',
  );
  final caseVariantRows = <VocabularyReviewSeedIssueRow>[
    for (final entry in rowsByNormalizedTerm.entries)
      if (_hasCaseVariants(entry.value)) ...[
        for (final row in entry.value)
          VocabularyReviewSeedIssueRow(
            issueType: 'case_variant',
            wordKey: row.wordKey,
            baseLanguage: row.baseLanguage,
            baseTerm: row.baseTerm,
            deTranslation: row.deTranslation,
            level: row.level,
            category: row.category,
            wordWorld: row.wordWorld,
            detail: 'normalized_base_term=${entry.key}',
          ),
      ],
  ];
  final meaningVariantCandidates = <VocabularyReviewSeedIssueRow>[
    for (final entry in rowsByNormalizedTerm.entries)
      if ((translationsByNormalizedTerm[entry.key] ?? const {}).length > 1)
        for (final row in entry.value)
          VocabularyReviewSeedIssueRow(
            issueType: 'same_base_different_translation',
            wordKey: row.wordKey,
            baseLanguage: row.baseLanguage,
            baseTerm: row.baseTerm,
            deTranslation: row.deTranslation,
            level: row.level,
            category: row.category,
            wordWorld: row.wordWorld,
            detail: 'needs meaning_note; normalized_base_term=${entry.key}',
          ),
  ];

  final smallCategories = Map<String, int>.fromEntries(
    _sortedEntries(
      categories,
    ).where((entry) => entry.key != '(leer)' && entry.value <= 2),
  );
  final largeCategories = Map<String, int>.fromEntries(
    _sortedEntries(
      categories,
    ).where((entry) => entry.key != '(leer)' && entry.value >= 500),
  );

  return VocabularyReviewSeedAnalysis(
    totalRows: rows.length,
    uniqueWordKeys: wordKeys.length,
    uniqueBaseTerms: baseTerms.length,
    languagePairDistribution: _sortedMap(languagePairs),
    levelDistribution: _sortedMap(levels),
    categoryDistribution: _sortedMap(categories),
    wordWorldDistribution: _sortedMap(wordWorlds),
    reviewStatusDistribution: _sortedMap(reviewStatuses),
    releaseReadyDistribution: _sortedMap(releaseReadyValues),
    baseLanguageDistribution: _sortedMap(baseLanguages),
    allNeedsReview:
        reviewStatuses.length == 1 &&
        reviewStatuses.containsKey('needs_review'),
    allReleaseReadyFalse:
        releaseReadyValues.length == 1 &&
        releaseReadyValues.containsKey('false'),
    allSpanishEmpty: rows.every((row) => (row['es_translation'] ?? '').isEmpty),
    allFrenchEmpty: rows.every((row) => (row['fr_translation'] ?? '').isEmpty),
    approvedRows: approvedRows,
    releaseReadyTrueRows: releaseReadyTrueRows,
    unexpectedBaseLanguageRows: unexpectedBaseLanguageRows,
    uppercaseBaseLanguageRows: uppercaseBaseLanguageRows,
    emptyTranslationCandidates: emptyTranslations,
    sameBaseAndTranslationRows: sameBaseAndTranslation,
    longTranslationRows: longTranslations,
    translationVariantRows: translationVariants,
    urlOrHtmlRows: urlOrHtmlRows,
    duplicateCandidates: duplicateCandidates,
    caseVariantRows: caseVariantRows,
    meaningVariantCandidates: meaningVariantCandidates,
    missingLevelRows: missingLevels,
    unusualLevelRows: unusualLevels,
    missingCategoryRows: missingCategories,
    missingWordWorldRows: missingWordWorlds,
    levelAsCategoryRows: levelAsCategories,
    top500AsCategoryRows: top500AsCategories,
    smallCategories: smallCategories,
    largeCategories: largeCategories,
    structureIssueCandidates: structureIssues,
  );
}

String renderVocabularyReviewSeedReport(VocabularyReviewSeedAnalysis analysis) {
  final buffer = StringBuffer()
    ..writeln('# Vocabulary Review Seed Quality Report')
    ..writeln()
    ..writeln('Stand: 2026-05-30')
    ..writeln()
    ..writeln(
      'Dieser Report analysiert den lokal generierten Master-Review-Seed. '
      'Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, '
      'keine SRS-Daten und kein `word_progress`.',
    )
    ..writeln()
    ..writeln('## 1. Grundzahlen')
    ..writeln()
    ..writeln('- Zeilen: ${analysis.totalRows}')
    ..writeln('- Eindeutige `word_key`: ${analysis.uniqueWordKeys}')
    ..writeln('- Eindeutige `base_term`: ${analysis.uniqueBaseTerms}')
    ..writeln(
      '- Sprachpaare: ${analysis.languagePairDistribution.length} '
      '(aus `base_language` und vorhandener `de_translation` abgeleitet)',
    )
    ..writeln('- Level: ${analysis.levelDistribution.length}')
    ..writeln('- Kategorien: ${analysis.categoryDistribution.length}')
    ..writeln('- Wortwelten: ${analysis.wordWorldDistribution.length}')
    ..writeln()
    ..writeln('### Sprachpaare')
    ..writeln(_renderCountTable(analysis.languagePairDistribution))
    ..writeln()
    ..writeln('### Level')
    ..writeln(_renderCountTable(analysis.levelDistribution))
    ..writeln()
    ..writeln('## 2. Sicherheitsprüfung')
    ..writeln()
    ..writeln(
      '- Alle `review_status = needs_review`: ${_yesNo(analysis.allNeedsReview)}',
    )
    ..writeln(
      '- Alle `release_ready = false`: ${_yesNo(analysis.allReleaseReadyFalse)}',
    )
    ..writeln(
      '- `es_translation` überall leer: ${_yesNo(analysis.allSpanishEmpty)}',
    )
    ..writeln(
      '- `fr_translation` überall leer: ${_yesNo(analysis.allFrenchEmpty)}',
    )
    ..writeln('- Zeilen mit `approved`: ${analysis.approvedRows.length}')
    ..writeln(
      '- Zeilen mit `release_ready = true`: ${analysis.releaseReadyTrueRows.length}',
    )
    ..writeln()
    ..writeln('## 3. Sprachcodeprüfung')
    ..writeln()
    ..writeln('### `base_language`')
    ..writeln(_renderCountTable(analysis.baseLanguageDistribution))
    ..writeln()
    ..writeln(
      '- Unerwartete Sprachcodes: ${analysis.unexpectedBaseLanguageRows.length}',
    )
    ..writeln(
      '- Nicht-lowercase Sprachcodes: ${analysis.uppercaseBaseLanguageRows.length}',
    )
    ..writeln()
    ..writeln('## 4. Übersetzungsprüfung')
    ..writeln()
    ..writeln(
      '- Leere deutsche Übersetzungen: ${analysis.emptyTranslationCandidates.length}',
    )
    ..writeln(
      '- Gleicher Wert in `base_term` und `de_translation`: '
      '${analysis.sameBaseAndTranslationRows.length}',
    )
    ..writeln(
      '- Sehr lange Übersetzungen: ${analysis.longTranslationRows.length}',
    )
    ..writeln(
      '- Slash/Semikolon/Mehrfachvarianten-Verdacht: '
      '${analysis.translationVariantRows.length}',
    )
    ..writeln('- URL-/HTML-Verdacht: ${analysis.urlOrHtmlRows.length}')
    ..writeln()
    ..writeln('## 5. Dublettenprüfung')
    ..writeln()
    ..writeln(
      '- Exakte Dubletten nach `base_term + de_translation + base_language`: '
      '${analysis.duplicateCandidates.length}',
    )
    ..writeln('- Case-Varianten: ${analysis.caseVariantRows.length}')
    ..writeln(
      '- Gleiche Basisbegriffe mit unterschiedlichen Übersetzungen: '
      '${analysis.meaningVariantCandidates.length}',
    )
    ..writeln()
    ..writeln('## 6. Strukturprüfung')
    ..writeln()
    ..writeln('- Fehlendes Level: ${analysis.missingLevelRows.length}')
    ..writeln('- Ungewöhnliche Level: ${analysis.unusualLevelRows.length}')
    ..writeln('- Fehlende Kategorie: ${analysis.missingCategoryRows.length}')
    ..writeln('- Fehlende Wortwelt: ${analysis.missingWordWorldRows.length}')
    ..writeln(
      '- A1-C2 als Kategorie/Wortwelt-Verdacht: ${analysis.levelAsCategoryRows.length}',
    )
    ..writeln(
      '- Top-500 als Kategorie/Wortwelt-Verdacht: ${analysis.top500AsCategoryRows.length}',
    )
    ..writeln()
    ..writeln('### Kategorien mit sehr wenigen Wörtern')
    ..writeln(_renderCountTable(analysis.smallCategories, limit: 30))
    ..writeln()
    ..writeln('### Kategorien mit sehr vielen Wörtern')
    ..writeln(_renderCountTable(analysis.largeCategories, limit: 30))
    ..writeln()
    ..writeln('## 7. Priorisierte Review-Listen')
    ..writeln()
    ..writeln('Empfohlene Reihenfolge:')
    ..writeln()
    ..writeln('1. Sprachcode-/Formatprobleme')
    ..writeln('2. URL-/HTML-/Importartefakte')
    ..writeln('3. Exakte Dubletten')
    ..writeln('4. Case-Varianten')
    ..writeln('5. Gleiche Basisbegriffe mit unterschiedlichen Übersetzungen')
    ..writeln('6. Fehlende Kategorien/Level')
    ..writeln('7. Bedeutungsvarianten mit fehlender `meaning_note`')
    ..writeln('8. Normale Wort-für-Wort-Prüfung')
    ..writeln()
    ..writeln('## 8. Kandidatenlisten')
    ..writeln()
    ..writeln(
      '- `seed_empty_translation_candidates.csv`: '
      '${analysis.emptyTranslationCandidates.length} Kandidaten, '
      'maximal $seedCandidateListLimit exportiert',
    )
    ..writeln(
      '- `seed_duplicate_candidates.csv`: '
      '${analysis.duplicateCandidates.length} Kandidaten, '
      'maximal $seedCandidateListLimit exportiert',
    )
    ..writeln(
      '- `seed_meaning_variant_candidates.csv`: '
      '${analysis.meaningVariantCandidates.length} Kandidaten, '
      'maximal $seedCandidateListLimit exportiert',
    )
    ..writeln(
      '- `seed_structure_issue_candidates.csv`: '
      '${analysis.structureIssueCandidates.length} Kandidaten, '
      'maximal $seedCandidateListLimit exportiert',
    )
    ..writeln()
    ..writeln('## 9. Wichtigste nächste Schritte')
    ..writeln()
    ..writeln(
      '- Kandidatenlisten manuell prüfen; nichts automatisch korrigieren.',
    )
    ..writeln('- Exakte Dubletten und Bedeutungsvarianten getrennt behandeln.')
    ..writeln(
      '- `meaning_id` und `meaning_note` erst nach fachlicher Prüfung setzen.',
    )
    ..writeln(
      '- Spanisch/Französisch weiterhin leer lassen, bis sie geprüft sind.',
    )
    ..writeln(
      '- Erst nach menschlicher Freigabe `approved` und `release_ready = true` setzen.',
    );

  return buffer.toString();
}

const _expectedBaseLanguages = {'en'};
const _expectedLevels = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

void _requireValue(List<String> args, int index, String option) {
  if (index + 1 >= args.length) {
    throw FormatException('Missing value after $option.');
  }
}

void _validateMasterHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in vocabularyReviewSeedHeader)
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'Seed CSV is missing required master column(s): ${missing.join(', ')}.',
    );
  }
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  return {
    for (var index = 0; index < headers.length; index++)
      headers[index]: index < record.length ? record[index] : '',
  };
}

VocabularyReviewSeedIssueRow _issueRow(
  Map<String, String> row,
  String issueType, {
  String detail = '',
}) {
  return VocabularyReviewSeedIssueRow(
    issueType: issueType,
    wordKey: row['word_key']?.trim() ?? '',
    baseLanguage: row['base_language']?.trim() ?? '',
    baseTerm: row['base_term']?.trim() ?? '',
    deTranslation: row['de_translation']?.trim() ?? '',
    level: row['level']?.trim() ?? '',
    category: row['category']?.trim() ?? '',
    wordWorld: row['word_world']?.trim() ?? '',
    detail: detail,
  );
}

void _increment(Map<String, int> counts, String key) {
  counts[key] = (counts[key] ?? 0) + 1;
}

bool _hasVariantSeparator(String value) {
  return value.contains('/') || value.contains(';') || value.contains('|');
}

bool _looksLikeUrlOrHtml(String value) {
  final lower = value.toLowerCase();
  return lower.contains('http://') ||
      lower.contains('https://') ||
      lower.contains('www.') ||
      lower.contains('<br') ||
      lower.contains('<span') ||
      lower.contains('</') ||
      lower.contains('&nbsp;');
}

bool _containsLevelLabel(String value) {
  return RegExp(r'\b[ABC][12]\b').hasMatch(value);
}

bool _containsTop500(String value) {
  final lower = value.toLowerCase();
  return lower.contains('top 500') || lower.contains('top-500');
}

List<VocabularyReviewSeedIssueRow> _flattenDuplicateGroups(
  Map<String, List<VocabularyReviewSeedIssueRow>> groups, {
  required String issueType,
}) {
  return [
    for (final entry in groups.entries)
      if (entry.value.length > 1)
        for (final row in entry.value)
          VocabularyReviewSeedIssueRow(
            issueType: issueType,
            wordKey: row.wordKey,
            baseLanguage: row.baseLanguage,
            baseTerm: row.baseTerm,
            deTranslation: row.deTranslation,
            level: row.level,
            category: row.category,
            wordWorld: row.wordWorld,
            detail:
                'duplicate_key=${entry.key}; group_size=${entry.value.length}',
          ),
  ];
}

bool _hasCaseVariants(List<VocabularyReviewSeedIssueRow> rows) {
  final originalTerms = rows.map((row) => row.baseTerm).toSet();
  final lowercaseTerms = rows.map((row) => row.baseTerm.toLowerCase()).toSet();
  return originalTerms.length > 1 && lowercaseTerms.length == 1;
}

Map<String, int> _sortedMap(Map<String, int> counts) {
  return Map<String, int>.fromEntries(_sortedEntries(counts));
}

List<MapEntry<String, int>> _sortedEntries(Map<String, int> counts) {
  final entries = counts.entries.toList();
  entries.sort((a, b) {
    final countCompare = b.value.compareTo(a.value);
    if (countCompare != 0) return countCompare;
    return a.key.compareTo(b.key);
  });
  return entries;
}

String _renderCountTable(Map<String, int> counts, {int limit = 20}) {
  if (counts.isEmpty) return '_Keine Einträge._\n';
  final buffer = StringBuffer()
    ..writeln('| Wert | Anzahl |')
    ..writeln('|---|---:|');
  for (final entry in _sortedEntries(counts).take(limit)) {
    buffer.writeln('| ${_escapeMarkdown(entry.key)} | ${entry.value} |');
  }
  if (counts.length > limit) {
    buffer.writeln('| ... | ${counts.length - limit} weitere Werte |');
  }
  return buffer.toString();
}

String _yesNo(bool value) => value ? 'ja' : 'nein';

String _escapeMarkdown(String value) {
  return value.replaceAll('|', r'\|').replaceAll('\n', ' ');
}

void _writeTextFile(String path, String content) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

int _writeCandidateCsv(String path, List<VocabularyReviewSeedIssueRow> rows) {
  final limitedRows = rows.take(seedCandidateListLimit).toList();
  final records = <List<String>>[
    [
      'issue_type',
      'word_key',
      'base_language',
      'base_term',
      'de_translation',
      'level',
      'category',
      'word_world',
      'detail',
    ],
    for (final row in limitedRows) row.toCsvRow(),
  ];
  _writeTextFile(path, writeVocabularyReviewCsv(records));
  return limitedRows.length;
}
