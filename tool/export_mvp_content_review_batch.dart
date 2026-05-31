import 'dart:io';

import 'export_vocabulary_review_seed.dart';

const defaultMvpContentReviewInputPath =
    'docs/word-review/supabase_words_review.csv';
const defaultMvpContentReviewOutputPath =
    'docs/word-review/mvp_content_first_review_batch.csv';

const mvpContentReviewBatchHeader = <String>[
  'priority',
  'word_key',
  'base_term',
  'de_translation',
  'level',
  'category',
  'word_world',
  'mvp_reason',
  'risk_type',
  'review_decision',
  'review_note',
];

const mvpContentReviewTargetWordWorlds = <String>[
  'Travel',
  'Food & Cooking',
  'Home & Living',
];

const _defaultMaxRows = 150;
const _defaultMaxRowsPerWordWorld = 50;
const _levelOrder = <String, int>{
  'A1': 0,
  'A2': 1,
  'B1': 2,
  'B2': 3,
  'C1': 4,
  'C2': 5,
};
const _levelTokens = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

Future<void> main(List<String> args) async {
  final options = MvpContentReviewBatchOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(MvpContentReviewBatchOptions.usage);
    return;
  }

  try {
    final result = exportMvpContentReviewBatch(options);
    stdout
      ..writeln(
        'Read ${result.rowsRead} source rows from ${options.inputPath}.',
      )
      ..writeln('Matched EN->DE rows by target word world:')
      ..writeln(_formatCounts(result.availableByWordWorld))
      ..writeln(
        'Wrote ${result.rowsWritten} review rows to ${options.outputPath}.',
      )
      ..writeln('Exported rows by word world:')
      ..writeln(_formatCounts(result.exportedByWordWorld))
      ..writeln(
        'Batch is a review working list only. Review fields are empty; no '
        'approvals or product data changes were created.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('MVP content review batch export failed: $error');
    exitCode = 1;
  }
}

class MvpContentReviewBatchOptions {
  const MvpContentReviewBatchOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    required this.maxRows,
    required this.maxRowsPerWordWorld,
    this.help = false,
  });

  factory MvpContentReviewBatchOptions.defaults() {
    return const MvpContentReviewBatchOptions(
      inputPath: defaultMvpContentReviewInputPath,
      outputPath: defaultMvpContentReviewOutputPath,
      force: false,
      maxRows: _defaultMaxRows,
      maxRowsPerWordWorld: _defaultMaxRowsPerWordWorld,
    );
  }

  factory MvpContentReviewBatchOptions.fromArgs(List<String> args) {
    var options = MvpContentReviewBatchOptions.defaults();
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
        options = options.copyWith(
          maxRows: _parsePositiveInt(args[++index], '--max-rows'),
        );
      } else if (arg == '--per-world') {
        _requireValue(args, index, '--per-world');
        options = options.copyWith(
          maxRowsPerWordWorld: _parsePositiveInt(args[++index], '--per-world'),
        );
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
  dart tool/export_mvp_content_review_batch.dart [--input <path>] [--output <path>] [--max-rows <n>] [--per-world <n>] [--force]

Defaults:
  --input     docs/word-review/supabase_words_review.csv
  --output    docs/word-review/mvp_content_first_review_batch.csv
  --max-rows  150
  --per-world 50

This tool only reads a local review CSV and writes a small MVP review working
list for Travel, Food & Cooking, and Home & Living. It does not connect to
Supabase or SQLite, import data, correct words, call AI, approve rows, or set
release_ready.
''';

  final String inputPath;
  final String outputPath;
  final bool force;
  final int maxRows;
  final int maxRowsPerWordWorld;
  final bool help;

  MvpContentReviewBatchOptions copyWith({
    String? inputPath,
    String? outputPath,
    bool? force,
    int? maxRows,
    int? maxRowsPerWordWorld,
    bool? help,
  }) {
    return MvpContentReviewBatchOptions(
      inputPath: inputPath ?? this.inputPath,
      outputPath: outputPath ?? this.outputPath,
      force: force ?? this.force,
      maxRows: maxRows ?? this.maxRows,
      maxRowsPerWordWorld: maxRowsPerWordWorld ?? this.maxRowsPerWordWorld,
      help: help ?? this.help,
    );
  }
}

class MvpContentReviewBatchExportResult {
  const MvpContentReviewBatchExportResult({
    required this.rowsRead,
    required this.rowsWritten,
    required this.availableByWordWorld,
    required this.exportedByWordWorld,
  });

  final int rowsRead;
  final int rowsWritten;
  final Map<String, int> availableByWordWorld;
  final Map<String, int> exportedByWordWorld;
}

MvpContentReviewBatchExportResult exportMvpContentReviewBatch(
  MvpContentReviewBatchOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException('Input CSV not found', options.inputPath);
  }

  final outputFile = File(options.outputPath);
  if (outputFile.existsSync() && !options.force) {
    throw FileSystemException(
      'Output CSV already exists. Pass --force to overwrite',
      options.outputPath,
    );
  }

  final batch = buildMvpContentReviewBatchCsv(
    inputFile.readAsStringSync(),
    maxRows: options.maxRows,
    maxRowsPerWordWorld: options.maxRowsPerWordWorld,
  );

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(batch.csv);

  return MvpContentReviewBatchExportResult(
    rowsRead: batch.rowsRead,
    rowsWritten: batch.rowsWritten,
    availableByWordWorld: batch.availableByWordWorld,
    exportedByWordWorld: batch.exportedByWordWorld,
  );
}

class MvpContentReviewBatchCsv {
  const MvpContentReviewBatchCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
    required this.availableByWordWorld,
    required this.exportedByWordWorld,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
  final Map<String, int> availableByWordWorld;
  final Map<String, int> exportedByWordWorld;
}

MvpContentReviewBatchCsv buildMvpContentReviewBatchCsv(
  String input, {
  int maxRows = _defaultMaxRows,
  int maxRowsPerWordWorld = _defaultMaxRowsPerWordWorld,
}) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Input CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateRequiredHeaders(headers);

  final availableByWorld = {
    for (final world in mvpContentReviewTargetWordWorlds) world: 0,
  };
  final candidatesByWorld = {
    for (final world in mvpContentReviewTargetWordWorlds)
      world: <_MvpContentCandidate>[],
  };

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final values = _rowValues(headers, records[rowIndex]);
    final fromLanguage = normalizeReviewLanguageCode(values['from_lang'] ?? '');
    final toLanguage = normalizeReviewLanguageCode(values['to_lang'] ?? '');
    if (fromLanguage != 'en' || toLanguage != 'de') {
      continue;
    }

    final wordWorld = _firstNonEmptyValue(values, const [
      'proposed_word_worlds',
      'word_world',
      'current_category_names',
    ]);
    final category = values['current_category_names']?.trim() ?? '';
    final matchedWorlds = _matchedTargetWorlds('$wordWorld; $category');
    if (matchedWorlds.isEmpty) {
      continue;
    }

    final wordKey = values['word_id']?.trim() ?? '';
    final baseTerm = _firstNonEmptyValue(values, const [
      'term',
      'text',
      'term/text',
    ]);
    final level = _firstNonEmptyValue(values, const [
      'proposed_level',
      'level',
      'current_level',
    ]);
    final translation = values['translation']?.trim() ?? '';
    if (wordKey.isEmpty || baseTerm.isEmpty) {
      continue;
    }

    final candidate = _MvpContentCandidate(
      wordKey: wordKey,
      baseTerm: baseTerm,
      deTranslation: translation,
      level: level,
      category: category,
      wordWorld: wordWorld.isNotEmpty ? wordWorld : category,
      riskType: _detectRiskType(
        baseTerm: baseTerm,
        deTranslation: translation,
        level: level,
        category: category,
        wordWorld: wordWorld,
      ),
    );

    for (final world in matchedWorlds) {
      availableByWorld[world] = (availableByWorld[world] ?? 0) + 1;
      candidatesByWorld[world]!.add(candidate);
    }
  }

  final selected = <_SelectedMvpContentCandidate>[];
  final usedWordKeys = <String>{};
  final exportedByWorld = {
    for (final world in mvpContentReviewTargetWordWorlds) world: 0,
  };

  for (final world in mvpContentReviewTargetWordWorlds) {
    final candidates = candidatesByWorld[world]!..sort(_compareCandidates);
    for (final candidate in candidates) {
      if (selected.length >= maxRows) break;
      if ((exportedByWorld[world] ?? 0) >= maxRowsPerWordWorld) break;
      if (!usedWordKeys.add(candidate.wordKey)) continue;

      selected.add(
        _SelectedMvpContentCandidate(
          priority:
              '${worldPriorityPrefix(world)}-${exportedByWorld[world]! + 1}',
          assignedWordWorld: world,
          candidate: candidate,
        ),
      );
      exportedByWorld[world] = exportedByWorld[world]! + 1;
    }
  }

  final outputRecords = <List<String>>[mvpContentReviewBatchHeader];
  for (final item in selected) {
    final candidate = item.candidate;
    outputRecords.add([
      item.priority,
      candidate.wordKey,
      candidate.baseTerm,
      candidate.deTranslation,
      candidate.level,
      candidate.category,
      candidate.wordWorld,
      'mvp_start_word_world:${item.assignedWordWorld}',
      candidate.riskType,
      '',
      '',
    ]);
  }

  return MvpContentReviewBatchCsv(
    csv: writeVocabularyReviewCsv(outputRecords),
    rowsRead: records.length - 1,
    rowsWritten: selected.length,
    availableByWordWorld: availableByWorld,
    exportedByWordWorld: exportedByWorld,
  );
}

String worldPriorityPrefix(String world) {
  switch (world) {
    case 'Travel':
      return 'travel';
    case 'Food & Cooking':
      return 'food';
    case 'Home & Living':
      return 'home';
  }
  return normalizeReviewBaseTerm(world).replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

class _MvpContentCandidate {
  const _MvpContentCandidate({
    required this.wordKey,
    required this.baseTerm,
    required this.deTranslation,
    required this.level,
    required this.category,
    required this.wordWorld,
    required this.riskType,
  });

  final String wordKey;
  final String baseTerm;
  final String deTranslation;
  final String level;
  final String category;
  final String wordWorld;
  final String riskType;
}

class _SelectedMvpContentCandidate {
  const _SelectedMvpContentCandidate({
    required this.priority,
    required this.assignedWordWorld,
    required this.candidate,
  });

  final String priority;
  final String assignedWordWorld;
  final _MvpContentCandidate candidate;
}

int _compareCandidates(_MvpContentCandidate a, _MvpContentCandidate b) {
  final levelCompare = (_levelOrder[a.level] ?? 99).compareTo(
    _levelOrder[b.level] ?? 99,
  );
  if (levelCompare != 0) return levelCompare;

  final termCompare = normalizeReviewBaseTerm(
    a.baseTerm,
  ).compareTo(normalizeReviewBaseTerm(b.baseTerm));
  if (termCompare != 0) return termCompare;

  return a.wordKey.compareTo(b.wordKey);
}

List<String> _matchedTargetWorlds(String value) {
  final tokens = _splitListValue(value).toSet();
  return [
    for (final world in mvpContentReviewTargetWordWorlds)
      if (tokens.contains(world)) world,
  ];
}

String _detectRiskType({
  required String baseTerm,
  required String deTranslation,
  required String level,
  required String category,
  required String wordWorld,
}) {
  if (normalizeReviewBaseTerm(baseTerm) ==
      normalizeReviewBaseTerm(deTranslation)) {
    return 'same_base_and_translation';
  }
  if (level.trim().isEmpty) return 'missing_level';
  if (category.trim().isEmpty || wordWorld.trim().isEmpty) {
    return 'missing_category';
  }

  final categoryTokens = _splitListValue('$category; $wordWorld').toSet();
  final hasLevelToken = categoryTokens.any(_levelTokens.contains);
  final hasTop500Token = categoryTokens.contains('Top 500 Words');
  if (hasLevelToken || hasTop500Token) return 'structure_issue';

  return 'standard_review';
}

List<String> _splitListValue(String value) {
  return value
      .split(';')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

void _validateRequiredHeaders(List<String> headers) {
  const requiredHeaders = [
    'word_id',
    'from_lang',
    'to_lang',
    'translation',
    'current_category_names',
    'current_level',
  ];
  final hasBaseTermHeader = headers.any(
    const {'term', 'text', 'term/text'}.contains,
  );
  if (!hasBaseTermHeader) {
    throw const FormatException(
      'Input CSV is missing one of the required base term columns: term, text, term/text.',
    );
  }

  for (final header in requiredHeaders) {
    if (!headers.contains(header)) {
      throw FormatException('Input CSV is missing required column: $header.');
    }
  }
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  final values = <String, String>{};
  for (var index = 0; index < headers.length; index++) {
    values[headers[index]] = index < record.length ? record[index] : '';
  }
  return values;
}

String _firstNonEmptyValue(Map<String, String> values, List<String> keys) {
  for (final key in keys) {
    final value = values[key]?.trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

void _requireValue(List<String> args, int index, String option) {
  if (index + 1 >= args.length) {
    throw FormatException('Missing value after $option.');
  }
}

int _parsePositiveInt(String value, String option) {
  final parsed = int.tryParse(value);
  if (parsed == null || parsed <= 0) {
    throw FormatException('$option must be a positive integer.');
  }
  return parsed;
}

String _formatCounts(Map<String, int> counts) {
  return counts.entries
      .map((entry) => '  ${entry.key}: ${entry.value}')
      .join('\n');
}
