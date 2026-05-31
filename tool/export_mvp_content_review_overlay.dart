import 'dart:io';

import 'export_mvp_content_review_batch.dart';
import 'export_vocabulary_review_seed.dart';
import 'validate_mvp_content_review_batch.dart';

const defaultMvpContentReviewOverlayInputPath =
    'docs/word-review/mvp_content_first_review_batch_working.csv';
const defaultMvpContentReviewOverlayOutputPath =
    'docs/word-review/mvp_content_first_review_overlay.csv';

const mvpContentReviewOverlayHeader = <String>[
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
  'reviewer',
  'reviewed_at',
];

Future<void> main(List<String> args) async {
  final options = MvpContentReviewOverlayExportOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(MvpContentReviewOverlayExportOptions.usage);
    return;
  }

  try {
    final result = exportMvpContentReviewOverlay(options);
    stdout
      ..writeln('Read ${result.rowsRead} MVP content review rows.')
      ..writeln(
        'Wrote ${result.rowsWritten} overlay rows to ${options.outputPath}.',
      )
      ..writeln(
        'Overlay contains review decisions only. No product data changes, '
        'imports, approvals, or release_ready flags were created.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('MVP content review overlay export failed: $error');
    exitCode = 1;
  }
}

class MvpContentReviewOverlayExportOptions {
  const MvpContentReviewOverlayExportOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    required this.allowEmpty,
    this.reviewer = '',
    this.reviewedAt = '',
    this.help = false,
  });

  factory MvpContentReviewOverlayExportOptions.defaults() {
    return const MvpContentReviewOverlayExportOptions(
      inputPath: defaultMvpContentReviewOverlayInputPath,
      outputPath: defaultMvpContentReviewOverlayOutputPath,
      force: false,
      allowEmpty: false,
    );
  }

  factory MvpContentReviewOverlayExportOptions.fromArgs(List<String> args) {
    var options = MvpContentReviewOverlayExportOptions.defaults();
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
  dart tool/export_mvp_content_review_overlay.dart [--input <path>] [--output <path>] [--reviewer <name>] [--reviewed-at <yyyy-mm-dd>] [--force] [--allow-empty]

Defaults:
  --input  docs/word-review/mvp_content_first_review_batch_working.csv
  --output docs/word-review/mvp_content_first_review_overlay.csv

This tool only reads a local MVP content review working-copy CSV and writes a
small overlay CSV containing filled review decisions. It does not connect to
Supabase, SQLite, import data, correct words, call AI, approve product data,
or set release_ready. Existing output files require --force. Empty overlays
require --allow-empty.
''';

  final String inputPath;
  final String outputPath;
  final bool force;
  final bool allowEmpty;
  final String reviewer;
  final String reviewedAt;
  final bool help;

  MvpContentReviewOverlayExportOptions copyWith({
    String? inputPath,
    String? outputPath,
    bool? force,
    bool? allowEmpty,
    String? reviewer,
    String? reviewedAt,
    bool? help,
  }) {
    return MvpContentReviewOverlayExportOptions(
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

class MvpContentReviewOverlayExportResult {
  const MvpContentReviewOverlayExportResult({
    required this.rowsRead,
    required this.rowsWritten,
  });

  final int rowsRead;
  final int rowsWritten;
}

MvpContentReviewOverlayExportResult exportMvpContentReviewOverlay(
  MvpContentReviewOverlayExportOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'MVP content review working-copy CSV not found',
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

  final overlay = buildMvpContentReviewOverlayCsv(
    inputFile.readAsStringSync(),
    reviewer: options.reviewer,
    reviewedAt: options.reviewedAt,
    allowEmpty: options.allowEmpty,
  );

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(overlay.csv);

  return MvpContentReviewOverlayExportResult(
    rowsRead: overlay.rowsRead,
    rowsWritten: overlay.rowsWritten,
  );
}

class MvpContentReviewOverlayCsv {
  const MvpContentReviewOverlayCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
}

MvpContentReviewOverlayCsv buildMvpContentReviewOverlayCsv(
  String input, {
  String reviewer = '',
  String reviewedAt = '',
  bool allowEmpty = false,
}) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException(
      'MVP content review working-copy CSV is empty.',
    );
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateWorkingCopyHeaders(headers);

  final outputRecords = <List<String>>[mvpContentReviewOverlayHeader];
  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    final row = _rowValues(headers, records[rowIndex]);
    final decision = row['review_decision']?.trim() ?? '';
    if (decision.isEmpty) continue;

    _validateExportableRow(row, rowNumber);

    outputRecords.add([
      row['word_key']?.trim() ?? '',
      row['base_term']?.trim() ?? '',
      row['de_translation']?.trim() ?? '',
      row['level']?.trim() ?? '',
      row['category']?.trim() ?? '',
      row['word_world']?.trim() ?? '',
      row['mvp_reason']?.trim() ?? '',
      row['risk_type']?.trim() ?? '',
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

  return MvpContentReviewOverlayCsv(
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
    for (final header in mvpContentReviewBatchHeader)
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'MVP content review working-copy is missing required column(s): '
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
  if (!allowedMvpContentReviewDecisions.contains(decision) ||
      decision.isEmpty) {
    throw FormatException(
      'Row $rowNumber cannot be exported: unknown `review_decision` '
      '`$decision`.',
    );
  }
  if (const {
        'fix_translation_later',
        'needs_context',
        'reject_for_mvp',
        'move_out_of_mvp',
        'add_note',
      }.contains(decision) &&
      note.isEmpty) {
    throw FormatException(
      'Row $rowNumber cannot be exported: `$decision` requires `review_note`.',
    );
  }
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  return {
    for (var index = 0; index < headers.length; index++)
      headers[index]: index < record.length ? record[index] : '',
  };
}
