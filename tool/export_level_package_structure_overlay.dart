import 'dart:io';

import 'export_vocabulary_review_seed.dart';

const defaultLevelPackageStructureOverlayInputPath =
    'docs/word-review/level_package_structure_first_batch_working.csv';
const defaultLevelPackageStructureOverlayOutputPath =
    'docs/word-review/level_package_structure_first_batch_overlay.csv';

const levelPackageStructureOverlayHeader = <String>[
  'word_key',
  'structure_case',
  'base_term',
  'de_translation',
  'detected_level',
  'detected_package',
  'detected_topic',
  'review_decision',
  'review_note',
  'reviewer',
  'reviewed_at',
];

const allowedLevelPackageStructureOverlayDecisions = <String>{
  'map_level',
  'map_package',
  'map_word_world',
  'needs_context',
  'keep',
  'reject',
};

Future<void> main(List<String> args) async {
  final options = LevelPackageStructureOverlayExportOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(LevelPackageStructureOverlayExportOptions.usage);
    return;
  }

  try {
    final result = exportLevelPackageStructureOverlay(options);
    stdout
      ..writeln('Read ${result.rowsRead} structure review rows.')
      ..writeln(
        'Wrote ${result.rowsWritten} overlay rows to '
        '${options.outputPath}.',
      )
      ..writeln(
        'Overlay contains structure review decisions only. No product data '
        'changes were created.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Level/package structure overlay export failed: $error');
    exitCode = 1;
  }
}

class LevelPackageStructureOverlayExportOptions {
  const LevelPackageStructureOverlayExportOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    required this.allowEmpty,
    this.reviewer = '',
    this.reviewedAt = '',
    this.help = false,
  });

  factory LevelPackageStructureOverlayExportOptions.defaults() {
    return const LevelPackageStructureOverlayExportOptions(
      inputPath: defaultLevelPackageStructureOverlayInputPath,
      outputPath: defaultLevelPackageStructureOverlayOutputPath,
      force: false,
      allowEmpty: false,
    );
  }

  factory LevelPackageStructureOverlayExportOptions.fromArgs(
    List<String> args,
  ) {
    var options = LevelPackageStructureOverlayExportOptions.defaults();
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
  dart tool/export_level_package_structure_overlay.dart [--input <path>] [--output <path>] [--reviewer <name>] [--reviewed-at <yyyy-mm-dd>] [--force] [--allow-empty]

Defaults:
  --input  docs/word-review/level_package_structure_first_batch_working.csv
  --output docs/word-review/level_package_structure_first_batch_overlay.csv

This tool only reads a local structure review working-copy CSV and writes a
small overlay CSV containing filled review decisions. It does not connect to
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

  LevelPackageStructureOverlayExportOptions copyWith({
    String? inputPath,
    String? outputPath,
    bool? force,
    bool? allowEmpty,
    String? reviewer,
    String? reviewedAt,
    bool? help,
  }) {
    return LevelPackageStructureOverlayExportOptions(
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

class LevelPackageStructureOverlayExportResult {
  const LevelPackageStructureOverlayExportResult({
    required this.rowsRead,
    required this.rowsWritten,
  });

  final int rowsRead;
  final int rowsWritten;
}

LevelPackageStructureOverlayExportResult exportLevelPackageStructureOverlay(
  LevelPackageStructureOverlayExportOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'Level/package structure working-copy CSV not found',
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

  final overlay = buildLevelPackageStructureOverlayCsv(
    inputFile.readAsStringSync(),
    reviewer: options.reviewer,
    reviewedAt: options.reviewedAt,
    allowEmpty: options.allowEmpty,
  );

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(overlay.csv);

  return LevelPackageStructureOverlayExportResult(
    rowsRead: overlay.rowsRead,
    rowsWritten: overlay.rowsWritten,
  );
}

class LevelPackageStructureOverlayCsv {
  const LevelPackageStructureOverlayCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
}

LevelPackageStructureOverlayCsv buildLevelPackageStructureOverlayCsv(
  String input, {
  String reviewer = '',
  String reviewedAt = '',
  bool allowEmpty = false,
}) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException(
      'Level/package structure working-copy CSV is empty.',
    );
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateWorkingCopyHeaders(headers);

  final outputRecords = <List<String>>[levelPackageStructureOverlayHeader];
  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    final row = _rowValues(headers, records[rowIndex]);
    final decision = row['review_decision']?.trim() ?? '';
    if (decision.isEmpty) continue;

    _validateExportableRow(row, rowNumber);

    outputRecords.add([
      row['word_key']?.trim() ?? '',
      row['structure_case']?.trim() ?? '',
      row['base_term']?.trim() ?? '',
      row['de_translation']?.trim() ?? '',
      row['detected_level']?.trim() ?? '',
      row['detected_package']?.trim() ?? '',
      row['detected_topic']?.trim() ?? '',
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

  return LevelPackageStructureOverlayCsv(
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
      'structure_case',
      'base_term',
      'de_translation',
      'detected_level',
      'detected_package',
      'detected_topic',
      'review_decision',
      'review_note',
    ])
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'Level/package structure working-copy is missing required column(s): '
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
  if (!allowedLevelPackageStructureOverlayDecisions.contains(decision)) {
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
  if (decision.startsWith('map_') && !_containsTargetMapping(note)) {
    throw FormatException(
      'Row $rowNumber cannot be exported: `$decision` requires target '
      'structure in `review_note`.',
    );
  }
}

bool _containsTargetMapping(String note) {
  return note.contains('level=') ||
      note.contains('package=') ||
      note.contains('content_package=') ||
      note.contains('word_world=');
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  return {
    for (var index = 0; index < headers.length; index++)
      headers[index]: index < record.length ? record[index] : '',
  };
}
