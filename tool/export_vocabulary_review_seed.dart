import 'dart:io';

const defaultVocabularyReviewSourceCsvPath =
    'docs/word-review/supabase_words_review.csv';
const defaultVocabularyReviewSeedCsvPath =
    'docs/word-review/vocabulary_review_seed.csv';

const vocabularyReviewSeedHeader = <String>[
  'word_key',
  'base_language',
  'base_term',
  'normalized_base_term',
  'meaning_id',
  'meaning_note',
  'part_of_speech',
  'level',
  'category',
  'word_world',
  'de_translation',
  'es_translation',
  'fr_translation',
  'example_base',
  'example_de',
  'translation_note',
  'duplicate_group',
  'conflict_type',
  'review_status',
  'reviewer',
  'last_reviewed_at',
  'release_ready',
];

Future<void> main(List<String> args) async {
  final options = VocabularyReviewSeedOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(VocabularyReviewSeedOptions.usage);
    return;
  }

  try {
    final result = exportVocabularyReviewSeed(options);
    stdout
      ..writeln('Read ${result.rowsRead} rows from ${options.inputPath}.')
      ..writeln('Wrote ${result.rowsWritten} rows to ${options.outputPath}.')
      ..writeln(
        'All rows use review_status=needs_review and release_ready=false.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Vocabulary review seed export failed: $error');
    exitCode = 1;
  }
}

class VocabularyReviewSeedOptions {
  const VocabularyReviewSeedOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    this.help = false,
  });

  factory VocabularyReviewSeedOptions.fromArgs(List<String> args) {
    var inputPath = defaultVocabularyReviewSourceCsvPath;
    var outputPath = defaultVocabularyReviewSeedCsvPath;
    var force = false;
    var help = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--input') {
        if (index + 1 >= args.length) {
          throw const FormatException('Missing value after --input.');
        }
        inputPath = args[++index];
      } else if (arg == '--output') {
        if (index + 1 >= args.length) {
          throw const FormatException('Missing value after --output.');
        }
        outputPath = args[++index];
      } else if (arg == '--force') {
        force = true;
      } else if (arg == '--help' || arg == '-h') {
        help = true;
      } else {
        throw FormatException('Unknown argument: $arg');
      }
    }

    return VocabularyReviewSeedOptions(
      inputPath: inputPath,
      outputPath: outputPath,
      force: force,
      help: help,
    );
  }

  static const usage = '''
Usage:
  dart tool/export_vocabulary_review_seed.dart [--input <path>] [--output <path>] [--force]

Defaults:
  --input  docs/word-review/supabase_words_review.csv
  --output docs/word-review/vocabulary_review_seed.csv

This tool only reads a local review CSV and writes a local seed CSV. It does
not connect to Supabase, SQLite, import data, call AI, approve rows, or create
Spanish/French translations. Existing output files require --force.
''';

  final String inputPath;
  final String outputPath;
  final bool force;
  final bool help;
}

class VocabularyReviewSeedExportResult {
  const VocabularyReviewSeedExportResult({
    required this.rowsRead,
    required this.rowsWritten,
  });

  final int rowsRead;
  final int rowsWritten;
}

VocabularyReviewSeedExportResult exportVocabularyReviewSeed(
  VocabularyReviewSeedOptions options,
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

  final seed = buildVocabularyReviewSeedCsv(inputFile.readAsStringSync());
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(seed.csv);

  return VocabularyReviewSeedExportResult(
    rowsRead: seed.rowsRead,
    rowsWritten: seed.rowsWritten,
  );
}

class VocabularyReviewSeedCsv {
  const VocabularyReviewSeedCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
}

VocabularyReviewSeedCsv buildVocabularyReviewSeedCsv(String input) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Input CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateRequiredHeaders(headers);

  final outputRecords = <List<String>>[vocabularyReviewSeedHeader];
  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final values = _rowValues(headers, records[rowIndex]);
    final baseTerm = _firstNonEmptyValue(values, const [
      'term',
      'text',
      'term/text',
    ]);
    final baseLanguage = normalizeReviewLanguageCode(values['from_lang'] ?? '');
    final targetLanguage = normalizeReviewLanguageCode(values['to_lang'] ?? '');
    final proposedLevel = values['proposed_level']?.trim() ?? '';
    final currentLevel = values['current_level']?.trim() ?? '';
    final currentCategory = values['current_category_names']?.trim() ?? '';
    final proposedWordWorld = values['proposed_word_worlds']?.trim() ?? '';

    outputRecords.add([
      values['word_id']?.trim() ?? '',
      baseLanguage,
      baseTerm,
      normalizeReviewBaseTerm(baseTerm),
      '',
      '',
      values['pos']?.trim() ?? '',
      proposedLevel.isNotEmpty ? proposedLevel : currentLevel,
      currentCategory,
      proposedWordWorld.isNotEmpty ? proposedWordWorld : currentCategory,
      targetLanguage == 'de' ? values['translation']?.trim() ?? '' : '',
      '',
      '',
      '',
      '',
      combineReviewNotes(
        qaNote: values['qa_note'] ?? '',
        notes: values['notes'] ?? '',
      ),
      '',
      '',
      'needs_review',
      '',
      '',
      'false',
    ]);
  }

  return VocabularyReviewSeedCsv(
    csv: writeVocabularyReviewCsv(outputRecords),
    rowsRead: records.length - 1,
    rowsWritten: outputRecords.length - 1,
  );
}

String normalizeReviewLanguageCode(String value) {
  return value.trim().toLowerCase();
}

String normalizeReviewBaseTerm(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String combineReviewNotes({required String qaNote, required String notes}) {
  final normalizedQaNote = qaNote.trim();
  final normalizedNotes = notes.trim();
  if (normalizedQaNote.isEmpty) return normalizedNotes;
  if (normalizedNotes.isEmpty) return normalizedQaNote;
  if (normalizedQaNote == normalizedNotes) return normalizedQaNote;
  return '$normalizedQaNote | $normalizedNotes';
}

String writeVocabularyReviewCsv(List<List<String>> records) {
  return '${records.map((record) => record.map(_escapeCsvField).join(',')).join('\n')}\n';
}

List<List<String>> parseVocabularyReviewCsvRecords(String input) {
  final records = <List<String>>[];
  var record = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  for (var index = 0; index < input.length; index++) {
    final char = input[index];
    if (inQuotes) {
      if (char == '"') {
        final hasEscapedQuote =
            index + 1 < input.length && input[index + 1] == '"';
        if (hasEscapedQuote) {
          field.write('"');
          index++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(char);
      }
      continue;
    }

    if (char == '"') {
      inQuotes = true;
    } else if (char == ',') {
      record.add(field.toString());
      field.clear();
    } else if (char == '\n') {
      record.add(field.toString());
      field.clear();
      records.add(record);
      record = <String>[];
    } else if (char != '\r') {
      field.write(char);
    }
  }

  if (field.isNotEmpty || record.isNotEmpty) {
    record.add(field.toString());
    records.add(record);
  }

  return records;
}

void _validateRequiredHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in const [
      'word_id',
      'from_lang',
      'to_lang',
      'translation',
    ])
      if (!headerSet.contains(header)) header,
  ];

  if (!const ['term', 'text', 'term/text'].any(headerSet.contains)) {
    missing.add('term/text or term or text');
  }

  if (missing.isNotEmpty) {
    throw FormatException(
      'Input CSV is missing required column(s): ${missing.join(', ')}.',
    );
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

String _escapeCsvField(String value) {
  final needsQuoting =
      value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}
