import 'dart:io';

import 'export_mvp_content_review_batch.dart';
import 'export_vocabulary_review_seed.dart';

const defaultMvpContentReviewBatchInputPath =
    'docs/word-review/mvp_content_first_review_batch.csv';
const defaultMvpContentReviewBatchReportPath =
    'docs/word-review/mvp_content_first_review_batch_report.md';

const allowedMvpContentReviewDecisions = <String>{
  '',
  'approved_for_mvp',
  'fix_translation_later',
  'needs_context',
  'reject_for_mvp',
  'move_out_of_mvp',
  'add_note',
};

const _noteRequiredDecisions = <String>{
  'fix_translation_later',
  'needs_context',
  'reject_for_mvp',
  'move_out_of_mvp',
  'add_note',
};

Future<void> main(List<String> args) async {
  final options = MvpContentReviewBatchValidationOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(MvpContentReviewBatchValidationOptions.usage);
    return;
  }

  try {
    final result = validateMvpContentReviewBatch(options);
    stdout
      ..writeln('Validated ${result.validation.totalRows} MVP review rows.')
      ..writeln('Wrote report to ${options.reportPath}.')
      ..writeln('Validation issues: ${result.validation.issues.length}.');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('MVP content review batch validation failed: $error');
    exitCode = 1;
  }
}

class MvpContentReviewBatchValidationOptions {
  const MvpContentReviewBatchValidationOptions({
    required this.inputPath,
    required this.reportPath,
    this.help = false,
  });

  factory MvpContentReviewBatchValidationOptions.defaults() {
    return const MvpContentReviewBatchValidationOptions(
      inputPath: defaultMvpContentReviewBatchInputPath,
      reportPath: defaultMvpContentReviewBatchReportPath,
    );
  }

  factory MvpContentReviewBatchValidationOptions.fromArgs(List<String> args) {
    var options = MvpContentReviewBatchValidationOptions.defaults();
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
  dart tool/validate_mvp_content_review_batch.dart [--input <path>] [--report <path>]

Defaults:
  --input  docs/word-review/mvp_content_first_review_batch.csv
  --report docs/word-review/mvp_content_first_review_batch_report.md

This tool only reads a local MVP content review batch CSV and writes a markdown
validation report. It does not connect to Supabase, SQLite, import data,
correct words, call AI, approve product data, or set release_ready.
''';

  final String inputPath;
  final String reportPath;
  final bool help;

  MvpContentReviewBatchValidationOptions copyWith({
    String? inputPath,
    String? reportPath,
    bool? help,
  }) {
    return MvpContentReviewBatchValidationOptions(
      inputPath: inputPath ?? this.inputPath,
      reportPath: reportPath ?? this.reportPath,
      help: help ?? this.help,
    );
  }
}

class MvpContentReviewBatchValidationRunResult {
  const MvpContentReviewBatchValidationRunResult({required this.validation});

  final MvpContentReviewBatchValidation validation;
}

MvpContentReviewBatchValidationRunResult validateMvpContentReviewBatch(
  MvpContentReviewBatchValidationOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'MVP content review batch not found',
      options.inputPath,
    );
  }

  final validation = validateMvpContentReviewBatchCsv(
    inputFile.readAsStringSync(),
  );
  final reportFile = File(options.reportPath);
  reportFile.parent.createSync(recursive: true);
  reportFile.writeAsStringSync(renderMvpContentReviewBatchReport(validation));

  return MvpContentReviewBatchValidationRunResult(validation: validation);
}

class MvpContentReviewBatchValidation {
  const MvpContentReviewBatchValidation({
    required this.totalRows,
    required this.rowsByWordWorld,
    required this.rowsByRiskType,
    required this.decisionsByType,
    required this.emptyDecisionCount,
    required this.filledDecisionCount,
    required this.issues,
  });

  final int totalRows;
  final Map<String, int> rowsByWordWorld;
  final Map<String, int> rowsByRiskType;
  final Map<String, int> decisionsByType;
  final int emptyDecisionCount;
  final int filledDecisionCount;
  final List<MvpContentReviewBatchIssue> issues;
}

class MvpContentReviewBatchIssue {
  const MvpContentReviewBatchIssue({
    required this.rowNumber,
    required this.issueType,
    required this.priority,
    required this.wordKey,
    required this.wordWorld,
    required this.reviewDecision,
    required this.message,
  });

  final int rowNumber;
  final String issueType;
  final String priority;
  final String wordKey;
  final String wordWorld;
  final String reviewDecision;
  final String message;
}

MvpContentReviewBatchValidation validateMvpContentReviewBatchCsv(String input) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('MVP content review batch CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateHeaders(headers);

  final rowsByWordWorld = <String, int>{};
  final rowsByRiskType = <String, int>{};
  final decisionsByType = <String, int>{};
  final issues = <MvpContentReviewBatchIssue>[];
  var emptyDecisionCount = 0;
  var filledDecisionCount = 0;

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    final row = _rowValues(headers, records[rowIndex]);
    final priority = row['priority']?.trim() ?? '';
    final wordKey = row['word_key']?.trim() ?? '';
    final baseTerm = row['base_term']?.trim() ?? '';
    final wordWorld = row['word_world']?.trim() ?? '';
    final riskType = row['risk_type']?.trim() ?? '';
    final reviewDecision = row['review_decision']?.trim() ?? '';
    final reviewNote = row['review_note']?.trim() ?? '';

    if (wordWorld.isNotEmpty) {
      rowsByWordWorld[wordWorld] = (rowsByWordWorld[wordWorld] ?? 0) + 1;
    }
    if (riskType.isNotEmpty) {
      rowsByRiskType[riskType] = (rowsByRiskType[riskType] ?? 0) + 1;
    }

    if (reviewDecision.isEmpty) {
      emptyDecisionCount++;
    } else {
      filledDecisionCount++;
      decisionsByType[reviewDecision] =
          (decisionsByType[reviewDecision] ?? 0) + 1;
    }

    void addIssue(String type, String message) {
      issues.add(
        MvpContentReviewBatchIssue(
          rowNumber: rowNumber,
          issueType: type,
          priority: priority,
          wordKey: wordKey,
          wordWorld: wordWorld,
          reviewDecision: reviewDecision,
          message: message,
        ),
      );
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
    if (wordWorld.isEmpty) {
      addIssue('missing_required_field', '`word_world` ist leer.');
    }
    if (riskType.isEmpty) {
      addIssue('missing_required_field', '`risk_type` ist leer.');
    }
    if (!allowedMvpContentReviewDecisions.contains(reviewDecision)) {
      addIssue(
        'unknown_review_decision',
        '`review_decision` ist nicht erlaubt: `$reviewDecision`.',
      );
    }
    if (_noteRequiredDecisions.contains(reviewDecision) && reviewNote.isEmpty) {
      addIssue(
        'missing_review_note',
        '`$reviewDecision` braucht eine kurze `review_note`.',
      );
    }
  }

  return MvpContentReviewBatchValidation(
    totalRows: records.length - 1,
    rowsByWordWorld: _sortedMap(rowsByWordWorld),
    rowsByRiskType: _sortedMap(rowsByRiskType),
    decisionsByType: _sortedMap(decisionsByType),
    emptyDecisionCount: emptyDecisionCount,
    filledDecisionCount: filledDecisionCount,
    issues: issues,
  );
}

String renderMvpContentReviewBatchReport(
  MvpContentReviewBatchValidation validation,
) {
  final buffer = StringBuffer()
    ..writeln('# MVP Content First Review Batch Report')
    ..writeln()
    ..writeln('Stand: 2026-05-31')
    ..writeln()
    ..writeln(
      'Dieser Report validiert eine lokale MVP-Content-Review-Arbeitsdatei. '
      'Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, '
      'keine SRS-Daten, kein `word_progress` und keine Produktivvokabeln.',
    )
    ..writeln()
    ..writeln('## Zusammenfassung')
    ..writeln()
    ..writeln('- Gesamtzeilen: ${validation.totalRows}')
    ..writeln('- Leere Entscheidungen: ${validation.emptyDecisionCount}')
    ..writeln('- Gefüllte Entscheidungen: ${validation.filledDecisionCount}')
    ..writeln('- Validierungsprobleme: ${validation.issues.length}')
    ..writeln()
    ..writeln('## Entscheidungen je Typ')
    ..writeln()
    ..write(_renderCountTable(validation.decisionsByType))
    ..writeln()
    ..writeln('## Zeilen je Wortwelt')
    ..writeln()
    ..write(_renderCountTable(validation.rowsByWordWorld))
    ..writeln()
    ..writeln('## Risikotypen')
    ..writeln()
    ..write(_renderCountTable(validation.rowsByRiskType))
    ..writeln()
    ..writeln('## Erlaubte `review_decision` Werte')
    ..writeln()
    ..writeln(
      allowedMvpContentReviewDecisions
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
      ..writeln(
        '| Zeile | Typ | Priority | Word Key | Wortwelt | Entscheidung | Hinweis |',
      )
      ..writeln('|---:|---|---|---|---|---|---|');
    for (final issue in validation.issues) {
      buffer.writeln(
        '| ${issue.rowNumber} | ${_escapeMarkdown(issue.issueType)} | '
        '${_escapeMarkdown(issue.priority)} | '
        '${_escapeMarkdown(issue.wordKey)} | '
        '${_escapeMarkdown(issue.wordWorld)} | '
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
      'Die Vorlage `mvp_content_first_review_batch.csv` bleibt die kleine '
      'Review-Arbeitsliste. Für manuelle Bearbeitung wird eine lokale, '
      'ignorierte Kopie wie `mvp_content_first_review_batch_working.csv` '
      'genutzt. Erst nach vollständigem Review aller 150 Zeilen soll ein '
      'separates Overlay erzeugt werden.',
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
    for (final header in mvpContentReviewBatchHeader)
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'MVP content review batch is missing required column(s): ${missing.join(', ')}.',
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
