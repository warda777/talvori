import 'dart:io';

import 'export_mvp_content_review_overlay.dart';
import 'export_vocabulary_review_seed.dart';

const defaultMvpScreenshotContentInputPath =
    'docs/word-review/mvp_content_first_review_overlay.csv';
const defaultMvpScreenshotContentOutputPath =
    'docs/word-review/mvp_screenshot_content_selection.csv';

const mvpScreenshotContentSelectionHeader = <String>[
  'screenshot_priority',
  'word_key',
  'base_term',
  'de_translation',
  'level',
  'category',
  'word_world',
  'suggested_use',
  'selection_note',
];

const _defaultMaxRows = 60;
const _defaultMaxRowsPerWordWorld = 20;
const _approvedDecision = 'approved_for_mvp';
const _targetWorlds = ['Travel', 'Food & Cooking', 'Home & Living'];
const _levelOrder = <String, int>{
  'A1': 0,
  'A2': 1,
  'B1': 2,
  'B2': 3,
  'C1': 4,
  'C2': 5,
};

Future<void> main(List<String> args) async {
  final options = MvpScreenshotContentSelectionOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(MvpScreenshotContentSelectionOptions.usage);
    return;
  }

  try {
    final result = exportMvpScreenshotContentSelection(options);
    stdout
      ..writeln('Read ${result.rowsRead} review overlay rows.')
      ..writeln('Found approved_for_mvp rows by word world:')
      ..writeln(_formatCounts(result.approvedByWordWorld))
      ..writeln(
        'Wrote ${result.rowsWritten} screenshot content rows to '
        '${options.outputPath}.',
      )
      ..writeln('Exported rows by word world:')
      ..writeln(_formatCounts(result.exportedByWordWorld))
      ..writeln(
        'Selection is documentation only. No product data, approvals, imports, '
        'or release_ready flags were created.',
      );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('MVP screenshot content selection export failed: $error');
    exitCode = 1;
  }
}

class MvpScreenshotContentSelectionOptions {
  const MvpScreenshotContentSelectionOptions({
    required this.inputPath,
    required this.outputPath,
    required this.force,
    required this.maxRows,
    required this.maxRowsPerWordWorld,
    this.help = false,
  });

  factory MvpScreenshotContentSelectionOptions.defaults() {
    return const MvpScreenshotContentSelectionOptions(
      inputPath: defaultMvpScreenshotContentInputPath,
      outputPath: defaultMvpScreenshotContentOutputPath,
      force: false,
      maxRows: _defaultMaxRows,
      maxRowsPerWordWorld: _defaultMaxRowsPerWordWorld,
    );
  }

  factory MvpScreenshotContentSelectionOptions.fromArgs(List<String> args) {
    var options = MvpScreenshotContentSelectionOptions.defaults();
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
  dart tool/export_mvp_screenshot_content_selection.dart [--input <path>] [--output <path>] [--max-rows <n>] [--per-world <n>] [--force]

Defaults:
  --input     docs/word-review/mvp_content_first_review_overlay.csv
  --output    docs/word-review/mvp_screenshot_content_selection.csv
  --max-rows  60
  --per-world 20

This tool only reads a local MVP review overlay and writes a small screenshot
content selection from approved_for_mvp rows. It does not connect to Supabase
or SQLite, import data, correct words, call AI, approve product data, or set
release_ready. Existing output files require --force.
''';

  final String inputPath;
  final String outputPath;
  final bool force;
  final int maxRows;
  final int maxRowsPerWordWorld;
  final bool help;

  MvpScreenshotContentSelectionOptions copyWith({
    String? inputPath,
    String? outputPath,
    bool? force,
    int? maxRows,
    int? maxRowsPerWordWorld,
    bool? help,
  }) {
    return MvpScreenshotContentSelectionOptions(
      inputPath: inputPath ?? this.inputPath,
      outputPath: outputPath ?? this.outputPath,
      force: force ?? this.force,
      maxRows: maxRows ?? this.maxRows,
      maxRowsPerWordWorld: maxRowsPerWordWorld ?? this.maxRowsPerWordWorld,
      help: help ?? this.help,
    );
  }
}

class MvpScreenshotContentSelectionResult {
  const MvpScreenshotContentSelectionResult({
    required this.rowsRead,
    required this.rowsWritten,
    required this.approvedByWordWorld,
    required this.exportedByWordWorld,
  });

  final int rowsRead;
  final int rowsWritten;
  final Map<String, int> approvedByWordWorld;
  final Map<String, int> exportedByWordWorld;
}

MvpScreenshotContentSelectionResult exportMvpScreenshotContentSelection(
  MvpScreenshotContentSelectionOptions options,
) {
  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    throw FileSystemException(
      'MVP content review overlay CSV not found',
      options.inputPath,
    );
  }

  final outputFile = File(options.outputPath);
  if (outputFile.existsSync() && !options.force) {
    throw FileSystemException(
      'Output screenshot content selection already exists. Pass --force to overwrite',
      options.outputPath,
    );
  }

  final selection = buildMvpScreenshotContentSelectionCsv(
    inputFile.readAsStringSync(),
    maxRows: options.maxRows,
    maxRowsPerWordWorld: options.maxRowsPerWordWorld,
  );

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(selection.csv);

  return MvpScreenshotContentSelectionResult(
    rowsRead: selection.rowsRead,
    rowsWritten: selection.rowsWritten,
    approvedByWordWorld: selection.approvedByWordWorld,
    exportedByWordWorld: selection.exportedByWordWorld,
  );
}

class MvpScreenshotContentSelectionCsv {
  const MvpScreenshotContentSelectionCsv({
    required this.csv,
    required this.rowsRead,
    required this.rowsWritten,
    required this.approvedByWordWorld,
    required this.exportedByWordWorld,
  });

  final String csv;
  final int rowsRead;
  final int rowsWritten;
  final Map<String, int> approvedByWordWorld;
  final Map<String, int> exportedByWordWorld;
}

MvpScreenshotContentSelectionCsv buildMvpScreenshotContentSelectionCsv(
  String input, {
  int maxRows = _defaultMaxRows,
  int maxRowsPerWordWorld = _defaultMaxRowsPerWordWorld,
}) {
  final records = parseVocabularyReviewCsvRecords(input);
  if (records.isEmpty) {
    throw const FormatException('MVP content review overlay CSV is empty.');
  }

  final headers = records.first.map((header) => header.trim()).toList();
  _validateOverlayHeaders(headers);

  final approvedByWorld = {for (final world in _targetWorlds) world: 0};
  final candidatesByWorld = {
    for (final world in _targetWorlds) world: <_ScreenshotCandidate>[],
  };

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final row = _rowValues(headers, records[rowIndex]);
    if ((row['review_decision']?.trim() ?? '') != _approvedDecision) {
      continue;
    }

    final world = _assignedWordWorld(row);
    if (world == null) continue;

    approvedByWorld[world] = (approvedByWorld[world] ?? 0) + 1;
    final candidate = _ScreenshotCandidate.fromRow(row, world);
    if (!_isScreenshotFriendly(candidate)) continue;

    candidatesByWorld[world]!.add(candidate);
  }

  final selected = <_SelectedScreenshotCandidate>[];
  final exportedByWorld = {for (final world in _targetWorlds) world: 0};
  final usedWordKeys = <String>{};

  for (final world in _targetWorlds) {
    final candidates = candidatesByWorld[world]!..sort(_compareCandidates);
    for (final candidate in candidates) {
      if (selected.length >= maxRows) break;
      if ((exportedByWorld[world] ?? 0) >= maxRowsPerWordWorld) break;
      if (!usedWordKeys.add(candidate.wordKey)) continue;

      final count = exportedByWorld[world]! + 1;
      selected.add(
        _SelectedScreenshotCandidate(
          priority:
              '${_worldPriorityPrefix(world)}-${count.toString().padLeft(2, '0')}',
          candidate: candidate,
          suggestedUse: _suggestedUse(candidate, count),
        ),
      );
      exportedByWorld[world] = count;
    }
  }

  final outputRecords = <List<String>>[mvpScreenshotContentSelectionHeader];
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
      item.suggestedUse,
      _selectionNote(candidate),
    ]);
  }

  return MvpScreenshotContentSelectionCsv(
    csv: writeVocabularyReviewCsv(outputRecords),
    rowsRead: records.length - 1,
    rowsWritten: selected.length,
    approvedByWordWorld: approvedByWorld,
    exportedByWordWorld: exportedByWorld,
  );
}

class _ScreenshotCandidate {
  const _ScreenshotCandidate({
    required this.wordKey,
    required this.baseTerm,
    required this.deTranslation,
    required this.level,
    required this.category,
    required this.wordWorld,
    required this.riskType,
    required this.assignedWorld,
  });

  factory _ScreenshotCandidate.fromRow(
    Map<String, String> row,
    String assignedWorld,
  ) {
    return _ScreenshotCandidate(
      wordKey: row['word_key']?.trim() ?? '',
      baseTerm: row['base_term']?.trim() ?? '',
      deTranslation: row['de_translation']?.trim() ?? '',
      level: row['level']?.trim() ?? '',
      category: row['category']?.trim() ?? '',
      wordWorld: row['word_world']?.trim() ?? '',
      riskType: row['risk_type']?.trim() ?? '',
      assignedWorld: assignedWorld,
    );
  }

  final String wordKey;
  final String baseTerm;
  final String deTranslation;
  final String level;
  final String category;
  final String wordWorld;
  final String riskType;
  final String assignedWorld;
}

class _SelectedScreenshotCandidate {
  const _SelectedScreenshotCandidate({
    required this.priority,
    required this.candidate,
    required this.suggestedUse,
  });

  final String priority;
  final _ScreenshotCandidate candidate;
  final String suggestedUse;
}

bool _isScreenshotFriendly(_ScreenshotCandidate candidate) {
  if (candidate.wordKey.isEmpty ||
      candidate.baseTerm.isEmpty ||
      candidate.deTranslation.isEmpty) {
    return false;
  }

  final base = candidate.baseTerm.trim();
  final translation = candidate.deTranslation.trim();
  if (base.length > 28 || translation.length > 34) return false;
  if (RegExp(r'[?!]').hasMatch(base) || RegExp(r'[?!]').hasMatch(translation)) {
    return false;
  }
  if (translation.contains('(') || translation.contains(')')) return false;
  if (base.toLowerCase().startsWith('could you')) return false;
  if (base.toLowerCase().startsWith('is it possible')) return false;
  if (_containsSpecializedTravelPhrase(candidate)) return false;

  return true;
}

int _compareCandidates(_ScreenshotCandidate a, _ScreenshotCandidate b) {
  final levelCompare = (_levelOrder[a.level] ?? 99).compareTo(
    _levelOrder[b.level] ?? 99,
  );
  if (levelCompare != 0) return levelCompare;

  final scoreCompare = _screenshotScore(a).compareTo(_screenshotScore(b));
  if (scoreCompare != 0) return scoreCompare;

  final termCompare = normalizeReviewBaseTerm(
    a.baseTerm,
  ).compareTo(normalizeReviewBaseTerm(b.baseTerm));
  if (termCompare != 0) return termCompare;

  return a.wordKey.compareTo(b.wordKey);
}

bool _containsSpecializedTravelPhrase(_ScreenshotCandidate candidate) {
  if (candidate.assignedWorld != 'Travel') return false;

  final base = candidate.baseTerm.toLowerCase();
  return const [
    'boarding pass',
    'transfer',
    'rebook',
    'change a seat',
    'confirm a seat',
  ].any(base.contains);
}

int _screenshotScore(_ScreenshotCandidate candidate) {
  var score = 0;
  final base = candidate.baseTerm;
  final translation = candidate.deTranslation;

  if (candidate.riskType == 'standard_review') {
    score -= 4;
  } else if (candidate.riskType == 'structure_issue') {
    score -= 1;
  } else if (candidate.riskType == 'same_base_and_translation') {
    score += 3;
  }

  if (base.length <= 14 && translation.length <= 18) score -= 2;
  if (!base.contains(' ')) score -= 1;
  if (base.startsWith('to ')) score += 1;
  if (base.contains('boarding pass') || base.contains('transfer')) score += 3;

  return score;
}

String _suggestedUse(_ScreenshotCandidate candidate, int worldIndex) {
  if (worldIndex <= 3) return 'onboarding';
  if (worldIndex <= 8) return 'home_word_world';
  if (candidate.baseTerm.startsWith('to ')) return 'learn_mode';
  if (!candidate.baseTerm.contains(' ') && candidate.baseTerm.length <= 12) {
    return 'word_game';
  }
  return 'store_screenshot';
}

String _selectionNote(_ScreenshotCandidate candidate) {
  final notes = <String>['approved_for_mvp'];
  if (candidate.riskType == 'structure_issue') {
    notes.add('structure metadata still needs later cleanup');
  } else if (candidate.riskType == 'same_base_and_translation') {
    notes.add('internationalism; avoid as sole translation example');
  } else {
    notes.add('short everyday term');
  }
  return notes.join('; ');
}

String? _assignedWordWorld(Map<String, String> row) {
  final reason = row['mvp_reason']?.trim() ?? '';
  const prefix = 'mvp_start_word_world:';
  if (reason.startsWith(prefix)) {
    final world = reason.substring(prefix.length).trim();
    if (_targetWorlds.contains(world)) return world;
  }

  final wordWorld = row['word_world']?.trim() ?? '';
  for (final world in _targetWorlds) {
    if (_splitListValue(wordWorld).contains(world)) return world;
  }
  return null;
}

String _worldPriorityPrefix(String world) {
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

List<String> _splitListValue(String value) {
  return value
      .split(';')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

void _validateOverlayHeaders(List<String> headers) {
  final headerSet = headers.toSet();
  final missing = <String>[
    for (final header in mvpContentReviewOverlayHeader)
      if (!headerSet.contains(header)) header,
  ];
  if (missing.isNotEmpty) {
    throw FormatException(
      'MVP review overlay is missing required column(s): '
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
