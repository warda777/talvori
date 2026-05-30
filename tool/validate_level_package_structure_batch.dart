import 'dart:io';

import 'export_level_package_structure_batch.dart';
import 'export_vocabulary_review_seed.dart';

const defaultLevelPackageStructureValidationInputPath =
    'docs/word-review/level_package_structure_first_batch.csv';
const defaultLevelPackageStructureValidationReportPath =
    'docs/word-review/level_package_structure_first_batch_report.md';

const allowedLevelPackageStructureDecisions = <String>{
  '',
  'map_level',
  'map_package',
  'map_word_world',
  'needs_context',
  'keep',
  'reject',
};

Future<void> main(List<String> args) async {
  final options = LevelPackageStructureValidationOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(LevelPackageStructureValidationOptions.usage);
    return;
  }

  try {
    final result = validateLevelPackageStructureBatch(options);
    stdout
      ..writeln('Validated ${result.validation.totalRows} structure rows.')
      ..writeln('Wrote report to ${options.reportPath}.')
      ..writeln('Validation issues: ${result.validation.issues.length}.');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Level/package structure validation failed: $error');
    exitCode = 1;
  }
}

class LevelPackageStructureValidationOptions {
  const LevelPackageStructureValidationOptions({
    required this.inputPath,
    required this.reportPath,
    this.help = false,
  });

  factory LevelPackageStructureValidationOptions.defaults() {
    return const LevelPackageStructureValidationOptions(
      inputPath: defaultLevelPackageStructureValidationInputPath,
      reportPath: defaultLevelPackageStructureValidationReportPath,
    );
  }

  factory LevelPackageStructureValidationOptions.fromArgs(List<String> args) {
    var options = LevelPackageStructureValidationOptions.defaults();
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
  dart tool/validate_level_package_structure_batch.dart [--input <path>] [--report <path>]

Defaults:
  --input  docs/word-review/level_package_structure_first_batch.csv
  --report docs/word-review/level_package_structure_first_batch_report.md

This tool only reads a local level/package/word-world structure review CSV and
writes a markdown validation report. It does not connect to Supabase, SQLite,
import data, correct words, call AI, approve rows, or set release_ready.
''';

  final String inputPath;
  final String reportPath;
  final bool help;

  LevelPackageStructureValidationOptions copyWith({
    String? inputPath,
    String? reportPath,
    bool? help,
  }) {
    return LevelPackageStructureValidationOptions(
      inputPath: inputPath ?? this.inputPath,
      reportPath: reportPath ?? this.reportPath,
      help: help ?? this.help,
    );
  }
}

class LevelPackageStructureValidationRunResult {
  const LevelPackageStructureValidationRunResult({required this.validation});

  final LevelPackageStructureValidation validation;
}

LevelPackageStructureValidationRunResult validateLevelPackageStructureBatch(
  LevelPackageStructureValidationOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'Level/package structure batch not found',
      options.inputPath,
    );
  }

  final validation = validateLevelPackageStructureBatchCsv(
    inputFile.readAsStringSync(),
  );
  final reportFile = File(options.reportPath);
  reportFile.parent.createSync(recursive: true);
  reportFile.writeAsStringSync(renderLevelPackageStructureReport(validation));

  return LevelPackageStructureValidationRunResult(validation: validation);
}

class LevelPackageStructureValidation {
  const LevelPackageStructureValidation({
    required this.totalRows,
    required this.rowsByCase,
    required this.decisionsByType,
    required this.emptyDecisionCount,
    required this.filledDecisionCount,
    required this.issues,
  });

  final int totalRows;
  final Map<String, int> rowsByCase;
  final Map<String, int> decisionsByType;
  final int emptyDecisionCount;
  final int filledDecisionCount;
  final List<LevelPackageStructureIssue> issues;
}

class LevelPackageStructureIssue {
  const LevelPackageStructureIssue({
    required this.rowNumber,
    required this.issueType,
    required this.wordKey,
    required this.structureCase,
    required this.reviewDecision,
    required this.message,
  });

  final int rowNumber;
  final String issueType;
  final String wordKey;
  final String structureCase;
  final String reviewDecision;
  final String message;
}

LevelPackageStructureValidation validateLevelPackageStructureBatchCsv(
  String input,
) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('Level/package structure CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateHeaders(headers);

  final rowsByCase = <String, int>{};
  final decisionsByType = <String, int>{};
  final issues = <LevelPackageStructureIssue>[];
  var emptyDecisionCount = 0;
  var filledDecisionCount = 0;

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    final row = _rowValues(headers, records[rowIndex]);
    final structureCase = row['structure_case']?.trim() ?? '';
    final priority = row['priority']?.trim() ?? '';
    final wordKey = row['word_key']?.trim() ?? '';
    final baseTerm = row['base_term']?.trim() ?? '';
    final decision = row['review_decision']?.trim() ?? '';
    final note = row['review_note']?.trim() ?? '';

    if (structureCase.isNotEmpty) {
      rowsByCase[structureCase] = (rowsByCase[structureCase] ?? 0) + 1;
    }
    if (decision.isEmpty) {
      emptyDecisionCount++;
    } else {
      filledDecisionCount++;
      decisionsByType[decision] = (decisionsByType[decision] ?? 0) + 1;
    }

    void addIssue(String type, String message) {
      issues.add(
        LevelPackageStructureIssue(
          rowNumber: rowNumber,
          issueType: type,
          wordKey: wordKey,
          structureCase: structureCase,
          reviewDecision: decision,
          message: message,
        ),
      );
    }

    if (structureCase.isEmpty) {
      addIssue('missing_required_field', '`structure_case` ist leer.');
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
    if (!allowedLevelPackageStructureDecisions.contains(decision)) {
      addIssue(
        'unknown_review_decision',
        '`review_decision` ist nicht erlaubt: `$decision`.',
      );
    }
    if (decision == 'needs_context' && note.isEmpty) {
      addIssue(
        'missing_review_note',
        '`needs_context` braucht eine kurze `review_note`.',
      );
    }
    if (decision == 'reject' && note.isEmpty) {
      addIssue('missing_review_note', '`reject` braucht eine Begründung.');
    }
    if (decision.startsWith('map_') && !_containsTargetMapping(note)) {
      addIssue(
        'missing_target_mapping',
        '`$decision` braucht eine Zielstruktur in `review_note`.',
      );
    }
  }

  return LevelPackageStructureValidation(
    totalRows: records.length - 1,
    rowsByCase: _sortedMap(rowsByCase),
    decisionsByType: _sortedMap(decisionsByType),
    emptyDecisionCount: emptyDecisionCount,
    filledDecisionCount: filledDecisionCount,
    issues: issues,
  );
}

String renderLevelPackageStructureReport(
  LevelPackageStructureValidation validation,
) {
  final buffer = StringBuffer()
    ..writeln('# Level-/Paket-/Wortwelt-Struktur-Batch Report')
    ..writeln()
    ..writeln('Stand: 2026-05-30')
    ..writeln()
    ..writeln(
      'Dieser Report validiert eine lokale Struktur-Review-Arbeitsdatei. '
      'Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, '
      'keine SRS-Daten, kein `word_progress` und keine produktiven '
      'Vokabeldaten.',
    )
    ..writeln()
    ..writeln('## Zusammenfassung')
    ..writeln()
    ..writeln('- Gesamtzeilen: ${validation.totalRows}')
    ..writeln('- Leere Entscheidungen: ${validation.emptyDecisionCount}')
    ..writeln('- Gefüllte Entscheidungen: ${validation.filledDecisionCount}')
    ..writeln('- Validierungsprobleme: ${validation.issues.length}')
    ..writeln()
    ..writeln('## Zeilen pro Strukturfall')
    ..writeln()
    ..write(_renderCountTable(validation.rowsByCase))
    ..writeln()
    ..writeln('## Entscheidungen nach `review_decision`')
    ..writeln()
    ..write(_renderCountTable(validation.decisionsByType))
    ..writeln()
    ..writeln('## Erlaubte `review_decision` Werte')
    ..writeln()
    ..writeln(
      allowedLevelPackageStructureDecisions
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
        '| Zeile | Typ | Strukturfall | Word Key | Entscheidung | Hinweis |',
      )
      ..writeln('|---:|---|---|---|---|---|');
    for (final issue in validation.issues) {
      buffer.writeln(
        '| ${issue.rowNumber} | ${_escapeMarkdown(issue.issueType)} | '
        '${_escapeMarkdown(issue.structureCase)} | '
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
      'Die Entscheidungen sind Review-Overlay-Vorbereitung. Sie setzen keine '
      'Level, Pakete oder Wortwelten produktiv. Größere Struktur-Batches '
      'sollten erst nach Auswertung dieses repräsentativen Batches folgen.',
    );

  return buffer.toString();
}

bool _containsTargetMapping(String note) {
  return note.contains('level=') ||
      note.contains('package=') ||
      note.contains('content_package=') ||
      note.contains('word_world=');
}

void _requireValue(List<String> args, int index, String option) {
  if (index + 1 >= args.length) {
    throw FormatException('Missing value after $option.');
  }
}

void _validateHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in levelPackageStructureBatchHeader)
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'Level/package structure batch is missing required column(s): '
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
