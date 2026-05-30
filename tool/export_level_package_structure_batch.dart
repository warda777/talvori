import 'dart:io';

import 'export_vocabulary_review_seed.dart';

const defaultLevelPackageStructureInputPath =
    'docs/word-review/seed_structure_issue_candidates.csv';
const defaultLevelPackageStructureOutputPath =
    'docs/word-review/level_package_structure_first_batch.csv';

const levelPackageStructureBatchHeader = <String>[
  'structure_case',
  'priority',
  'word_key',
  'base_term',
  'de_translation',
  'level',
  'category',
  'word_world',
  'detected_level',
  'detected_package',
  'detected_topic',
  'suggested_mapping',
  'review_decision',
  'review_note',
];

const _levelTokens = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};
const _top500Package = 'Top 500 Words';
const _defaultMaxRows = 200;
const _maxRowsPerCase = 25;

Future<void> main(List<String> args) async {
  final options = LevelPackageStructureBatchOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(LevelPackageStructureBatchOptions.usage);
    return;
  }

  try {
    final result = exportLevelPackageStructureBatch(options);
    stdout
      ..writeln('Read ${result.rowsRead} structure candidate rows.')
      ..writeln(
        'Wrote ${result.rowsWritten} review batch rows to '
        '${options.outputPath}.',
      )
      ..writeln('Covered structure cases: ${result.structureCases.join(', ')}')
      ..writeln(
        'Batch is a review working list only. No product data changes were '
        'created.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Level/package structure batch export failed: $error');
    exitCode = 1;
  }
}

class LevelPackageStructureBatchOptions {
  const LevelPackageStructureBatchOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    required this.maxRows,
    this.help = false,
  });

  factory LevelPackageStructureBatchOptions.defaults() {
    return const LevelPackageStructureBatchOptions(
      inputPath: defaultLevelPackageStructureInputPath,
      outputPath: defaultLevelPackageStructureOutputPath,
      force: false,
      maxRows: _defaultMaxRows,
    );
  }

  factory LevelPackageStructureBatchOptions.fromArgs(List<String> args) {
    var options = LevelPackageStructureBatchOptions.defaults();
    var help = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--input') {
        _requireValue(args, index, '--input');
        options = options.copyWith(inputPath: args[++index]);
      } else if (arg == '--output') {
        _requireValue(args, index, '--output');
        options = options.copyWith(outputPath: args[++index]);
      } else if (arg == '--max-rows') {
        _requireValue(args, index, '--max-rows');
        final value = int.tryParse(args[++index]);
        if (value == null || value <= 0) {
          throw const FormatException('--max-rows must be a positive integer.');
        }
        options = options.copyWith(maxRows: value);
      } else if (arg == '--force') {
        options = options.copyWith(force: true);
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
  dart tool/export_level_package_structure_batch.dart [--input <path>] [--output <path>] [--max-rows <n>] [--force]

Defaults:
  --input    docs/word-review/seed_structure_issue_candidates.csv
  --output   docs/word-review/level_package_structure_first_batch.csv
  --max-rows 200

This tool only reads a local structure-candidate CSV and writes a small
representative review batch. It does not connect to Supabase, SQLite, import
data, correct words, call AI, approve rows, or set release_ready.
''';

  final String inputPath;
  final String outputPath;
  final bool force;
  final int maxRows;
  final bool help;

  LevelPackageStructureBatchOptions copyWith({
    String? inputPath,
    String? outputPath,
    bool? force,
    int? maxRows,
    bool? help,
  }) {
    return LevelPackageStructureBatchOptions(
      inputPath: inputPath ?? this.inputPath,
      outputPath: outputPath ?? this.outputPath,
      force: force ?? this.force,
      maxRows: maxRows ?? this.maxRows,
      help: help ?? this.help,
    );
  }
}

class LevelPackageStructureBatchExportResult {
  const LevelPackageStructureBatchExportResult({
    required this.rowsRead,
    required this.rowsWritten,
    required this.structureCases,
  });

  final int rowsRead;
  final int rowsWritten;
  final List<String> structureCases;
}

LevelPackageStructureBatchExportResult exportLevelPackageStructureBatch(
  LevelPackageStructureBatchOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'Structure candidate CSV not found',
      options.inputPath,
    );
  }

  final outputFile = File(options.outputPath);
  if (outputFile.existsSync() && !options.force) {
    throw FileSystemException(
      'Output CSV already exists. Pass --force to overwrite',
      options.outputPath,
    );
  }

  final batch = buildLevelPackageStructureBatchCsv(
    inputFile.readAsStringSync(),
    maxRows: options.maxRows,
  );

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(batch.csv);

  return LevelPackageStructureBatchExportResult(
    rowsRead: batch.rowsRead,
    rowsWritten: batch.rowsWritten,
    structureCases: batch.structureCases,
  );
}

class LevelPackageStructureBatchCsv {
  const LevelPackageStructureBatchCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
    required this.structureCases,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
  final List<String> structureCases;
}

LevelPackageStructureBatchCsv buildLevelPackageStructureBatchCsv(
  String input, {
  int maxRows = _defaultMaxRows,
}) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Structure candidate CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateHeaders(headers);

  final grouped = <String, _StructureCandidate>{};
  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final row = _rowValues(headers, records[rowIndex]);
    final wordKey = row['word_key']?.trim() ?? '';
    if (wordKey.isEmpty) continue;

    final candidate = grouped.putIfAbsent(
      wordKey,
      () => _StructureCandidate.fromRow(row),
    );
    candidate.addIssueType(row['issue_type']?.trim() ?? '');
  }

  final candidates = grouped.values.toList()
    ..sort((a, b) {
      final caseCompare = a.structureCase.compareTo(b.structureCase);
      if (caseCompare != 0) return caseCompare;
      return a.baseTerm.compareTo(b.baseTerm);
    });

  final selected = _selectRepresentativeCandidates(candidates, maxRows);
  final outputRecords = <List<String>>[levelPackageStructureBatchHeader];
  for (final candidate in selected) {
    outputRecords.add(candidate.toCsvRecord());
  }

  return LevelPackageStructureBatchCsv(
    csv: writeVocabularyReviewCsv(outputRecords),
    rowsRead: records.length - 1,
    rowsWritten: selected.length,
    structureCases:
        selected.map((candidate) => candidate.structureCase).toSet().toList()
          ..sort(),
  );
}

List<_StructureCandidate> _selectRepresentativeCandidates(
  List<_StructureCandidate> candidates,
  int maxRows,
) {
  final byCase = <String, List<_StructureCandidate>>{};
  for (final candidate in candidates) {
    byCase.putIfAbsent(candidate.structureCase, () => []).add(candidate);
  }

  final selected = <_StructureCandidate>[];
  for (final caseName in _casePriority) {
    final bucket = byCase[caseName] ?? const <_StructureCandidate>[];
    selected.addAll(bucket.take(_maxRowsPerCase));
    if (selected.length >= maxRows) return selected.take(maxRows).toList();
  }

  return selected.take(maxRows).toList();
}

const _casePriority = <String>[
  'level_only',
  'top_500_only',
  'level_top_500',
  'level_topic',
  'top_500_topic',
  'level_top_500_topic',
  'multi_topic',
  'unclear_mixed',
];

class _StructureCandidate {
  _StructureCandidate({
    required this.wordKey,
    required this.baseTerm,
    required this.deTranslation,
    required this.level,
    required this.category,
    required this.wordWorld,
    required this.detectedLevels,
    required this.detectedPackages,
    required this.detectedTopics,
    required this.issueTypes,
  });

  factory _StructureCandidate.fromRow(Map<String, String> row) {
    final level = row['level']?.trim() ?? '';
    final category = row['category']?.trim() ?? '';
    final wordWorld = row['word_world']?.trim() ?? '';
    final tokens = <String>[
      if (level.isNotEmpty) level,
      ..._splitStructureTokens(category),
      ..._splitStructureTokens(wordWorld),
    ];

    return _StructureCandidate(
      wordKey: row['word_key']?.trim() ?? '',
      baseTerm: row['base_term']?.trim() ?? '',
      deTranslation: row['de_translation']?.trim() ?? '',
      level: level,
      category: category,
      wordWorld: wordWorld,
      detectedLevels: _unique(tokens.where(_levelTokens.contains)),
      detectedPackages: _unique(
        tokens.where((token) => token == _top500Package),
      ),
      detectedTopics: _unique(
        tokens.where(
          (token) =>
              token.isNotEmpty &&
              !_levelTokens.contains(token) &&
              token != _top500Package,
        ),
      ),
      issueTypes: <String>{},
    );
  }

  final String wordKey;
  final String baseTerm;
  final String deTranslation;
  final String level;
  final String category;
  final String wordWorld;
  final List<String> detectedLevels;
  final List<String> detectedPackages;
  final List<String> detectedTopics;
  final Set<String> issueTypes;

  void addIssueType(String issueType) {
    if (issueType.isNotEmpty) issueTypes.add(issueType);
  }

  String get structureCase {
    final hasLevel = detectedLevels.isNotEmpty;
    final hasPackage = detectedPackages.isNotEmpty;
    final hasTopic = detectedTopics.isNotEmpty;
    final hasMultipleTopics = detectedTopics.length > 1;

    if (hasLevel && !hasPackage && !hasTopic) return 'level_only';
    if (!hasLevel && hasPackage && !hasTopic) return 'top_500_only';
    if (hasLevel && hasPackage && !hasTopic) return 'level_top_500';
    if (hasLevel && !hasPackage && hasMultipleTopics) return 'multi_topic';
    if (hasLevel && !hasPackage && hasTopic) return 'level_topic';
    if (!hasLevel && hasPackage && hasTopic) return 'top_500_topic';
    if (hasLevel && hasPackage && hasMultipleTopics) return 'multi_topic';
    if (hasLevel && hasPackage && hasTopic) return 'level_top_500_topic';
    return 'unclear_mixed';
  }

  int get priority => _casePriority.indexOf(structureCase) + 1;

  String get suggestedMapping {
    final parts = <String>[];
    if (detectedLevels.isNotEmpty) {
      parts.add('level=${detectedLevels.join('; ')}');
    }
    if (detectedPackages.isNotEmpty) {
      parts.add('content_package=${detectedPackages.join('; ')}');
    }
    if (detectedTopics.isNotEmpty) {
      parts.add('word_world=${detectedTopics.join('; ')}');
    } else {
      parts.add('word_world=needs_context');
    }
    return parts.join(' | ');
  }

  List<String> toCsvRecord() {
    return [
      structureCase,
      priority.toString(),
      wordKey,
      baseTerm,
      deTranslation,
      level,
      category,
      wordWorld,
      detectedLevels.join('; '),
      detectedPackages.join('; '),
      detectedTopics.join('; '),
      suggestedMapping,
      '',
      '',
    ];
  }
}

void _requireValue(List<String> args, int index, String option) {
  if (index + 1 >= args.length) {
    throw FormatException('Missing value after $option.');
  }
}

void _validateHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in const [
      'issue_type',
      'word_key',
      'base_term',
      'de_translation',
      'level',
      'category',
      'word_world',
    ])
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'Structure candidate CSV is missing required column(s): '
      '${missing.join(', ')}.',
    );
  }
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  return {
    for (var index = 0; index < headers.length; index++)
      headers[index]: index < record.length ? record[index] : '',
  };
}

List<String> _splitStructureTokens(String value) {
  return value
      .split(';')
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList();
}

List<String> _unique(Iterable<String> values) {
  return values.toSet().toList()..sort();
}
