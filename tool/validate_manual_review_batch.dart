import 'dart:io';

import 'export_vocabulary_review_seed.dart';

const defaultManualReviewBatchInputPath =
    'docs/word-review/manual_review_first_batch.csv';
const defaultManualReviewBatchReportPath =
    'docs/word-review/manual_review_first_batch_report.md';

const manualReviewBatchHeader = <String>[
  'review_block',
  'priority',
  'word_key',
  'base_term',
  'de_translation',
  'level',
  'category',
  'word_world',
  'conflict_type',
  'suggested_action',
  'review_decision',
  'review_note',
];

const allowedReviewDecisions = <String>{
  '',
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
  final options = ManualReviewBatchValidationOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(ManualReviewBatchValidationOptions.usage);
    return;
  }

  try {
    final result = validateManualReviewBatch(options);
    stdout
      ..writeln('Validated ${result.validation.totalRows} review rows.')
      ..writeln('Wrote report to ${options.reportPath}.')
      ..writeln('Validation issues: ${result.validation.issues.length}.');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Manual review batch validation failed: $error');
    exitCode = 1;
  }
}

class ManualReviewBatchValidationOptions {
  const ManualReviewBatchValidationOptions({
    required this.inputPath,
    required this.reportPath,
    this.help = false,
  });

  factory ManualReviewBatchValidationOptions.defaults() {
    return const ManualReviewBatchValidationOptions(
      inputPath: defaultManualReviewBatchInputPath,
      reportPath: defaultManualReviewBatchReportPath,
    );
  }

  factory ManualReviewBatchValidationOptions.fromArgs(List<String> args) {
    var options = ManualReviewBatchValidationOptions.defaults();
    var help = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--input') {
        _requireValue(args, index, '--input');
        options = options.copyWith(inputPath: args[++index]);
      } else if (arg == '--report') {
        _requireValue(args, index, '--report');
        options = options.copyWith(reportPath: args[++index]);
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
  dart tool/validate_manual_review_batch.dart [--input <path>] [--report <path>]

Defaults:
  --input  docs/word-review/manual_review_first_batch.csv
  --report docs/word-review/manual_review_first_batch_report.md

This tool only reads a local manual review batch CSV and writes a markdown
validation report. It does not connect to Supabase, SQLite, import data,
correct words, call AI, or approve review rows.
''';

  final String inputPath;
  final String reportPath;
  final bool help;

  ManualReviewBatchValidationOptions copyWith({
    String? inputPath,
    String? reportPath,
    bool? help,
  }) {
    return ManualReviewBatchValidationOptions(
      inputPath: inputPath ?? this.inputPath,
      reportPath: reportPath ?? this.reportPath,
      help: help ?? this.help,
    );
  }
}

class ManualReviewBatchValidationRunResult {
  const ManualReviewBatchValidationRunResult({required this.validation});

  final ManualReviewBatchValidation validation;
}

ManualReviewBatchValidationRunResult validateManualReviewBatch(
  ManualReviewBatchValidationOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'Manual review batch not found',
      options.inputPath,
    );
  }

  final validation = validateManualReviewBatchCsv(inputFile.readAsStringSync());
  final reportFile = File(options.reportPath);
  reportFile.parent.createSync(recursive: true);
  reportFile.writeAsStringSync(renderManualReviewBatchReport(validation));

  return ManualReviewBatchValidationRunResult(validation: validation);
}

class ManualReviewBatchValidation {
  const ManualReviewBatchValidation({
    required this.totalRows,
    required this.rowsByBlock,
    required this.emptyDecisionCount,
    required this.filledDecisionCount,
    required this.issues,
  });

  final int totalRows;
  final Map<String, int> rowsByBlock;
  final int emptyDecisionCount;
  final int filledDecisionCount;
  final List<ManualReviewBatchIssue> issues;
}

class ManualReviewBatchIssue {
  const ManualReviewBatchIssue({
    required this.rowNumber,
    required this.issueType,
    required this.wordKey,
    required this.reviewBlock,
    required this.reviewDecision,
    required this.message,
  });

  final int rowNumber;
  final String issueType;
  final String wordKey;
  final String reviewBlock;
  final String reviewDecision;
  final String message;
}

ManualReviewBatchValidation validateManualReviewBatchCsv(String input) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Manual review batch CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateHeaders(headers);

  final rowsByBlock = <String, int>{};
  final issues = <ManualReviewBatchIssue>[];
  var emptyDecisionCount = 0;
  var filledDecisionCount = 0;

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    final row = _rowValues(headers, records[rowIndex]);
    final reviewBlock = row['review_block']?.trim() ?? '';
    final priority = row['priority']?.trim() ?? '';
    final wordKey = row['word_key']?.trim() ?? '';
    final baseTerm = row['base_term']?.trim() ?? '';
    final conflictType = row['conflict_type']?.trim() ?? '';
    final reviewDecision = row['review_decision']?.trim() ?? '';
    final reviewNote = row['review_note']?.trim() ?? '';

    if (reviewBlock.isNotEmpty) {
      rowsByBlock[reviewBlock] = (rowsByBlock[reviewBlock] ?? 0) + 1;
    }

    if (reviewDecision.isEmpty) {
      emptyDecisionCount++;
    } else {
      filledDecisionCount++;
    }

    void addIssue(String type, String message) {
      issues.add(
        ManualReviewBatchIssue(
          rowNumber: rowNumber,
          issueType: type,
          wordKey: wordKey,
          reviewBlock: reviewBlock,
          reviewDecision: reviewDecision,
          message: message,
        ),
      );
    }

    if (reviewBlock.isEmpty) {
      addIssue('missing_required_field', '`review_block` ist leer.');
    }
    if (priority.isEmpty) {
      addIssue('missing_required_field', '`priority` ist leer.');
    }
    if (wordKey.isEmpty) {
      addIssue('missing_required_field', '`word_key` ist leer.');
    }
    if (baseTerm.isEmpty) {
      addIssue('missing_required_field', '`base_term` ist leer.');
    }
    if (conflictType.isEmpty) {
      addIssue('missing_required_field', '`conflict_type` ist leer.');
    }
    if (!allowedReviewDecisions.contains(reviewDecision)) {
      addIssue(
        'unknown_review_decision',
        '`review_decision` ist nicht erlaubt: `$reviewDecision`.',
      );
    }
    if (reviewDecision == 'needs_context' && reviewNote.isEmpty) {
      addIssue(
        'missing_review_note',
        '`needs_context` braucht eine kurze `review_note`.',
      );
    }
    if (reviewDecision == 'reject' && reviewNote.isEmpty) {
      addIssue('missing_review_note', '`reject` braucht eine Begründung.');
    }
    if (reviewDecision == 'split_meaning' && reviewNote.isEmpty) {
      addIssue(
        'missing_review_note',
        '`split_meaning` braucht eine Bedeutungsnotiz oder einen Hinweis.',
      );
    }
  }

  return ManualReviewBatchValidation(
    totalRows: records.length - 1,
    rowsByBlock: _sortedMap(rowsByBlock),
    emptyDecisionCount: emptyDecisionCount,
    filledDecisionCount: filledDecisionCount,
    issues: issues,
  );
}

String renderManualReviewBatchReport(ManualReviewBatchValidation validation) {
  final buffer = StringBuffer()
    ..writeln('# Manual Review First Batch Report')
    ..writeln()
    ..writeln('Stand: 2026-05-30')
    ..writeln()
    ..writeln(
      'Dieser Report validiert eine lokale manuelle Review-Arbeitsdatei. '
      'Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, '
      'keine SRS-Daten und kein `word_progress`.',
    )
    ..writeln()
    ..writeln('## Zusammenfassung')
    ..writeln()
    ..writeln('- Gesamtzeilen: ${validation.totalRows}')
    ..writeln('- Leere Entscheidungen: ${validation.emptyDecisionCount}')
    ..writeln('- Gefüllte Entscheidungen: ${validation.filledDecisionCount}')
    ..writeln('- Validierungsprobleme: ${validation.issues.length}')
    ..writeln()
    ..writeln('## Zeilen pro Review-Block')
    ..writeln()
    ..write(_renderCountTable(validation.rowsByBlock))
    ..writeln()
    ..writeln('## Erlaubte `review_decision` Werte')
    ..writeln()
    ..writeln(
      allowedReviewDecisions
          .map((decision) => decision.isEmpty ? '`<leer>`' : '`$decision`')
          .join(', '),
    )
    ..writeln()
    ..writeln('## Validierungsprobleme')
    ..writeln();

  if (validation.issues.isEmpty) {
    buffer.writeln('_Keine Validierungsprobleme gefunden._');
  } else {
    buffer
      ..writeln('| Zeile | Typ | Block | Word Key | Entscheidung | Hinweis |')
      ..writeln('|---:|---|---|---|---|---|');
    for (final issue in validation.issues) {
      buffer.writeln(
        '| ${issue.rowNumber} | ${_escapeMarkdown(issue.issueType)} | '
        '${_escapeMarkdown(issue.reviewBlock)} | '
        '${_escapeMarkdown(issue.wordKey)} | '
        '${_escapeMarkdown(issue.reviewDecision)} | '
        '${_escapeMarkdown(issue.message)} |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Workflow-Hinweis')
    ..writeln()
    ..writeln(
      'Die Vorlage `manual_review_first_batch.csv` sollte nicht direkt als '
      'persönliche Arbeitsdatei genutzt werden. Für echte manuelle Bearbeitung '
      'eine lokale Kopie wie `manual_review_first_batch_working.csv` anlegen, '
      'validieren und erst abgestimmte Ergebnisse später als separates Overlay '
      'versionieren.',
    );

  return buffer.toString();
}

void _requireValue(List<String> args, int index, String option) {
  if (index + 1 >= args.length) {
    throw FormatException('Missing value after $option.');
  }
}

void _validateHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in manualReviewBatchHeader)
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'Manual review batch is missing required column(s): ${missing.join(', ')}.',
    );
  }
}

Map<String, String> _rowValues(List<String> headers, List<String> record) {
  return {
    for (var index = 0; index < headers.length; index++)
      headers[index]: index < record.length ? record[index] : '',
  };
}

Map<String, int> _sortedMap(Map<String, int> counts) {
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });
  return Map<String, int>.fromEntries(entries);
}

String _renderCountTable(Map<String, int> counts) {
  if (counts.isEmpty) return '_Keine Einträge._\n';
  final buffer = StringBuffer()
    ..writeln('| Wert | Anzahl |')
    ..writeln('|---|---:|');
  for (final entry in counts.entries) {
    buffer.writeln('| ${_escapeMarkdown(entry.key)} | ${entry.value} |');
  }
  return buffer.toString();
}

String _escapeMarkdown(String value) {
  return value.replaceAll('|', r'\|').replaceAll('\n', ' ');
}
