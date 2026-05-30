import 'dart:io';

import 'export_vocabulary_review_seed.dart';

const defaultManualReviewOverlayInputPath =
    'docs/word-review/manual_review_first_batch_working.csv';
const defaultManualReviewOverlayOutputPath =
    'docs/word-review/manual_review_first_batch_overlay.csv';

const manualReviewOverlayHeader = <String>[
  'word_key',
  'review_block',
  'base_term',
  'de_translation',
  'conflict_type',
  'review_decision',
  'review_note',
  'reviewer',
  'reviewed_at',
];

const allowedOverlayReviewDecisions = <String>{
  'keep',
  'merge_later',
  'split_meaning',
  'canonical_case',
  'set_level',
  'set_word_world',
  'reject',
  'needs_context',
  'add_note',
};

Future<void> main(List<String> args) async {
  final options = ManualReviewOverlayExportOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(ManualReviewOverlayExportOptions.usage);
    return;
  }

  try {
    final result = exportManualReviewOverlay(options);
    stdout
      ..writeln('Read ${result.rowsRead} manual review rows.')
      ..writeln(
        'Wrote ${result.rowsWritten} overlay rows to '
        '${options.outputPath}.',
      )
      ..writeln(
        'Overlay contains review decisions only. No approvals or product '
        'data changes were created.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Manual review overlay export failed: $error');
    exitCode = 1;
  }
}

class ManualReviewOverlayExportOptions {
  const ManualReviewOverlayExportOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    required this.allowEmpty,
    this.reviewer = '',
    this.reviewedAt = '',
    this.help = false,
  });

  factory ManualReviewOverlayExportOptions.defaults() {
    return const ManualReviewOverlayExportOptions(
      inputPath: defaultManualReviewOverlayInputPath,
      outputPath: defaultManualReviewOverlayOutputPath,
      force: false,
      allowEmpty: false,
    );
  }

  factory ManualReviewOverlayExportOptions.fromArgs(List<String> args) {
    var options = ManualReviewOverlayExportOptions.defaults();
    var help = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--input') {
        _requireValue(args, index, '--input');
        options = options.copyWith(inputPath: args[++index]);
      } else if (arg == '--output') {
        _requireValue(args, index, '--output');
        options = options.copyWith(outputPath: args[++index]);
      } else if (arg == '--reviewer') {
        _requireValue(args, index, '--reviewer');
        options = options.copyWith(reviewer: args[++index]);
      } else if (arg == '--reviewed-at') {
        _requireValue(args, index, '--reviewed-at');
        options = options.copyWith(reviewedAt: args[++index]);
      } else if (arg == '--force') {
        options = options.copyWith(force: true);
      } else if (arg == '--allow-empty') {
        options = options.copyWith(allowEmpty: true);
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
  dart tool/export_manual_review_overlay.dart [--input <path>] [--output <path>] [--reviewer <name>] [--reviewed-at <yyyy-mm-dd>] [--force] [--allow-empty]

Defaults:
  --input  docs/word-review/manual_review_first_batch_working.csv
  --output docs/word-review/manual_review_first_batch_overlay.csv

This tool only reads a local manual review working-copy CSV and writes a small
overlay CSV containing filled review decisions. It does not connect to
Supabase, SQLite, import data, correct words, call AI, approve rows, or set
release_ready. Existing output files require --force. Empty overlays require
--allow-empty.
''';

  final String inputPath;
  final String outputPath;
  final bool force;
  final bool allowEmpty;
  final String reviewer;
  final String reviewedAt;
  final bool help;

  ManualReviewOverlayExportOptions copyWith({
    String? inputPath,
    String? outputPath,
    bool? force,
    bool? allowEmpty,
    String? reviewer,
    String? reviewedAt,
    bool? help,
  }) {
    return ManualReviewOverlayExportOptions(
      inputPath: inputPath ?? this.inputPath,
      outputPath: outputPath ?? this.outputPath,
      force: force ?? this.force,
      allowEmpty: allowEmpty ?? this.allowEmpty,
      reviewer: reviewer ?? this.reviewer,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      help: help ?? this.help,
    );
  }
}

class ManualReviewOverlayExportResult {
  const ManualReviewOverlayExportResult({
    required this.rowsRead,
    required this.rowsWritten,
  });

  final int rowsRead;
  final int rowsWritten;
}

ManualReviewOverlayExportResult exportManualReviewOverlay(
  ManualReviewOverlayExportOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'Manual review working-copy CSV not found',
      options.inputPath,
    );
  }

  final outputFile = File(options.outputPath);
  if (outputFile.existsSync() && !options.force) {
    throw FileSystemException(
      'Output overlay CSV already exists. Pass --force to overwrite',
      options.outputPath,
    );
  }

  final overlay = buildManualReviewOverlayCsv(
    inputFile.readAsStringSync(),
    reviewer: options.reviewer,
    reviewedAt: options.reviewedAt,
    allowEmpty: options.allowEmpty,
  );

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(overlay.csv);

  return ManualReviewOverlayExportResult(
    rowsRead: overlay.rowsRead,
    rowsWritten: overlay.rowsWritten,
  );
}

class ManualReviewOverlayCsv {
  const ManualReviewOverlayCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
}

ManualReviewOverlayCsv buildManualReviewOverlayCsv(
  String input, {
  String reviewer = '',
  String reviewedAt = '',
  bool allowEmpty = false,
}) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Manual review working-copy CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateWorkingCopyHeaders(headers);

  final outputRecords = <List<String>>[manualReviewOverlayHeader];
  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    final row = _rowValues(headers, records[rowIndex]);
    final decision = row['review_decision']?.trim() ?? '';
    if (decision.isEmpty) continue;

    _validateExportableRow(row, rowNumber);

    outputRecords.add([
      row['word_key']?.trim() ?? '',
      row['review_block']?.trim() ?? '',
      row['base_term']?.trim() ?? '',
      row['de_translation']?.trim() ?? '',
      row['conflict_type']?.trim() ?? '',
      decision,
      row['review_note']?.trim() ?? '',
      reviewer.trim(),
      reviewedAt.trim(),
    ]);
  }

  final rowsWritten = outputRecords.length - 1;
  if (rowsWritten == 0 && !allowEmpty) {
    throw const FormatException(
      'No filled review_decision values found. Pass --allow-empty to write an '
      'empty overlay header intentionally.',
    );
  }

  return ManualReviewOverlayCsv(
    csv: writeVocabularyReviewCsv(outputRecords),
    rowsRead: records.length - 1,
    rowsWritten: rowsWritten,
  );
}

void _requireValue(List<String> args, int index, String option) {
  if (index + 1 >= args.length) {
    throw FormatException('Missing value after $option.');
  }
}

void _validateWorkingCopyHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in const [
      'word_key',
      'review_block',
      'base_term',
      'de_translation',
      'conflict_type',
      'review_decision',
      'review_note',
    ])
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'Manual review working-copy is missing required column(s): '
      '${missing.join(', ')}.',
    );
  }
}

void _validateExportableRow(Map<String, String> row, int rowNumber) {
  final wordKey = row['word_key']?.trim() ?? '';
  final decision = row['review_decision']?.trim() ?? '';
  final note = row['review_note']?.trim() ?? '';

  if (wordKey.isEmpty) {
    throw FormatException(
      'Row $rowNumber cannot be exported: `word_key` is empty.',
    );
  }
  if (!allowedOverlayReviewDecisions.contains(decision)) {
    throw FormatException(
      'Row $rowNumber cannot be exported: unknown `review_decision` '
      '`$decision`.',
    );
  }
  if (decision == 'needs_context' && note.isEmpty) {
    throw FormatException(
      'Row $rowNumber cannot be exported: `needs_context` requires '
      '`review_note`.',
    );
  }
  if (decision == 'reject' && note.isEmpty) {
    throw FormatException(
      'Row $rowNumber cannot be exported: `reject` requires `review_note`.',
    );
  }
  if (decision == 'split_meaning' && note.isEmpty) {
    throw FormatException(
      'Row $rowNumber cannot be exported: `split_meaning` requires '
      '`review_note`.',
    );
  }
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  return {
    for (var index = 0; index < headers.length; index++)
      headers[index]: index < record.length ? record[index] : '',
  };
}
