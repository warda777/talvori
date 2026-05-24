import 'dart:io';

const _sourceCsvPath = 'docs/word-review/supabase_words_review.csv';
const _languageCsvPath =
    'docs/word-review/language_code_normalization_review.csv';
const _duplicatesCsvPath = 'docs/word-review/duplicate_candidates_review.csv';
const _uncategorizedCsvPath = 'docs/word-review/uncategorized_words_review.csv';
const _packageLevelCsvPath =
    'docs/word-review/package_and_level_candidates_review.csv';
const _summaryPath = 'docs/word-review/cleanup_candidates_summary.md';

const _levels = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

const _packageMarkers = {
  'Top 500 Words',
  'Basics',
  'Exam Practice',
  'Phrases & Idioms',
  'Irregular Verbs',
  'Grammar & Syntax',
};

Future<void> main() async {
  final sourceFile = File(_sourceCsvPath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source CSV: $_sourceCsvPath');
    exitCode = 2;
    return;
  }

  final rows = _readReviewRows(sourceFile);
  final languageRows = rows.where((row) {
    return row.fromLang != row.fromLang.toLowerCase() ||
        row.toLang != row.toLang.toLowerCase();
  }).toList();
  final uncategorizedRows = rows.where((row) {
    return row.currentCategoryNames.trim().isEmpty;
  }).toList();
  final packageLevelRows = rows.where((row) {
    return row.hasPackageCandidate ||
        row.hasLevelCategory ||
        _levels.contains(row.currentLevel.toUpperCase());
  }).toList();

  final duplicateGroups = _buildDuplicateGroups(rows);
  final duplicateRows = duplicateGroups.expand((group) => group.rows).toList();

  await _writeLanguageReview(languageRows);
  await _writeDuplicateReview(duplicateGroups);
  await _writeUncategorizedReview(uncategorizedRows);
  await _writePackageLevelReview(packageLevelRows);
  await _writeSummary(
    languageRows: languageRows,
    duplicateGroups: duplicateGroups,
    duplicateRows: duplicateRows,
    uncategorizedRows: uncategorizedRows,
    packageLevelRows: packageLevelRows,
    allRows: rows,
  );

  stdout
    ..writeln('Language normalization candidates: ${languageRows.length}')
    ..writeln('Duplicate groups: ${duplicateGroups.length}')
    ..writeln('Duplicate rows: ${duplicateRows.length}')
    ..writeln('Uncategorized words: ${uncategorizedRows.length}')
    ..writeln('Package/level candidate rows: ${packageLevelRows.length}');
}

List<_ReviewRow> _readReviewRows(File file) {
  final records = _parseCsv(file.readAsStringSync());
  if (records.isEmpty) return const [];
  final headers = records.first;
  final rows = <_ReviewRow>[];
  for (final record in records.skip(1)) {
    final values = <String, String>{};
    for (var index = 0; index < headers.length; index++) {
      values[headers[index]] = index < record.length ? record[index] : '';
    }
    rows.add(_ReviewRow(values));
  }
  return rows;
}

List<List<String>> _parseCsv(String input) {
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

class _ReviewRow {
  _ReviewRow(this.values);

  final Map<String, String> values;

  String get wordId => values['word_id'] ?? '';
  String get term => values['term/text'] ?? '';
  String get translation => values['translation'] ?? '';
  String get fromLang => values['from_lang'] ?? '';
  String get toLang => values['to_lang'] ?? '';
  String get currentCategoryNames => values['current_category_names'] ?? '';
  String get currentLevel => values['current_level'] ?? '';
  String get currentTags => values['current_tags'] ?? '';
  String get proposedWordWorlds => values['proposed_word_worlds'] ?? '';
  String get proposedLevel => values['proposed_level'] ?? currentLevel;
  String get proposedPackage => values['proposed_package'] ?? '';

  List<String> get categories => currentCategoryNames
      .split(';')
      .map((category) => category.trim())
      .where((category) => category.isNotEmpty)
      .toList();

  bool get hasLevelCategory => categories.any(_levels.contains);

  bool get hasPackageCandidate {
    return categories.any(_packageMarkers.contains) ||
        proposedPackage.trim().isNotEmpty;
  }
}

class _DuplicateGroup {
  _DuplicateGroup({required this.key, required this.type, required this.rows});

  final String key;
  final String type;
  final List<_ReviewRow> rows;
}

List<_DuplicateGroup> _buildDuplicateGroups(List<_ReviewRow> rows) {
  final groups = <_DuplicateGroup>[];
  groups.addAll(
    _groupDuplicates(
      rows,
      type: 'term/from_lang/to_lang',
      keyOf: (row) => [
        _normalize(row.term),
        _normalize(row.fromLang),
        _normalize(row.toLang),
      ].join('|'),
    ),
  );
  groups.addAll(
    _groupDuplicates(
      rows,
      type: 'term/translation/from_lang/to_lang',
      keyOf: (row) => [
        _normalize(row.term),
        _normalize(row.translation),
        _normalize(row.fromLang),
        _normalize(row.toLang),
      ].join('|'),
    ),
  );
  groups.sort((a, b) {
    final typeOrder = a.type.compareTo(b.type);
    return typeOrder == 0 ? a.key.compareTo(b.key) : typeOrder;
  });
  return groups;
}

List<_DuplicateGroup> _groupDuplicates(
  List<_ReviewRow> rows, {
  required String type,
  required String Function(_ReviewRow row) keyOf,
}) {
  final grouped = <String, List<_ReviewRow>>{};
  for (final row in rows) {
    final key = keyOf(row);
    if (key.replaceAll('|', '').isEmpty) continue;
    grouped.putIfAbsent(key, () => []).add(row);
  }
  final groups = <_DuplicateGroup>[];
  for (final entry in grouped.entries) {
    if (entry.value.length < 2) continue;
    groups.add(_DuplicateGroup(key: entry.key, type: type, rows: entry.value));
  }
  return groups;
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

Future<void> _writeLanguageReview(List<_ReviewRow> rows) async {
  await _writeCsv(
    _languageCsvPath,
    [
      'word_id',
      'term',
      'translation',
      'from_lang',
      'to_lang',
      'proposed_from_lang',
      'proposed_to_lang',
      'decision',
      'notes',
    ],
    [
      for (final row in rows)
        [
          row.wordId,
          row.term,
          row.translation,
          row.fromLang,
          row.toLang,
          row.fromLang.toLowerCase(),
          row.toLang.toLowerCase(),
          '',
          '',
        ],
    ],
  );
}

Future<void> _writeDuplicateReview(List<_DuplicateGroup> groups) async {
  await _writeCsv(
    _duplicatesCsvPath,
    [
      'duplicate_group_key',
      'duplicate_type',
      'word_id',
      'term',
      'translation',
      'from_lang',
      'to_lang',
      'current_category_names',
      'current_level',
      'current_tags',
      'proposed_action',
      'keep_word_id',
      'notes',
    ],
    [
      for (final group in groups)
        for (final row in group.rows)
          [
            group.key,
            group.type,
            row.wordId,
            row.term,
            row.translation,
            row.fromLang,
            row.toLang,
            row.currentCategoryNames,
            row.currentLevel,
            row.currentTags,
            '',
            '',
            '',
          ],
    ],
  );
}

Future<void> _writeUncategorizedReview(List<_ReviewRow> rows) async {
  await _writeCsv(
    _uncategorizedCsvPath,
    [
      'word_id',
      'term',
      'translation',
      'from_lang',
      'to_lang',
      'current_level',
      'current_tags',
      'proposed_word_worlds',
      'proposed_level',
      'decision',
      'notes',
    ],
    [
      for (final row in rows)
        [
          row.wordId,
          row.term,
          row.translation,
          row.fromLang,
          row.toLang,
          row.currentLevel,
          row.currentTags,
          '',
          row.proposedLevel,
          '',
          '',
        ],
    ],
  );
}

Future<void> _writePackageLevelReview(List<_ReviewRow> rows) async {
  await _writeCsv(
    _packageLevelCsvPath,
    [
      'word_id',
      'term',
      'translation',
      'from_lang',
      'to_lang',
      'current_category_names',
      'current_level',
      'proposed_package',
      'proposed_level',
      'notes',
    ],
    [
      for (final row in rows)
        [
          row.wordId,
          row.term,
          row.translation,
          row.fromLang,
          row.toLang,
          row.currentCategoryNames,
          row.currentLevel,
          row.proposedPackage,
          row.proposedLevel,
          '',
        ],
    ],
  );
}

Future<void> _writeSummary({
  required List<_ReviewRow> languageRows,
  required List<_DuplicateGroup> duplicateGroups,
  required List<_ReviewRow> duplicateRows,
  required List<_ReviewRow> uncategorizedRows,
  required List<_ReviewRow> packageLevelRows,
  required List<_ReviewRow> allRows,
}) async {
  final top500Count = allRows.where((row) {
    return row.categories.contains('Top 500 Words') ||
        row.proposedPackage
            .split(';')
            .map((value) => value.trim())
            .contains('Top 500 Words');
  }).length;
  final levelCandidateCount = allRows.where((row) {
    return row.hasLevelCategory || _levels.contains(row.currentLevel);
  }).length;

  final duplicateWordIds = duplicateRows.map((row) => row.wordId).toSet();
  final buffer = StringBuffer()
    ..writeln('# Cleanup Candidates Summary')
    ..writeln()
    ..writeln('Stand: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Dieser Schritt erzeugt nur Review-Dateien. Es wurden keine')
    ..writeln('Supabase-Daten, Woerter, Kategorien oder SRS-Fortschritte')
    ..writeln('veraendert.')
    ..writeln()
    ..writeln('## Dateien')
    ..writeln()
    ..writeln('- `language_code_normalization_review.csv`')
    ..writeln('- `duplicate_candidates_review.csv`')
    ..writeln('- `uncategorized_words_review.csv`')
    ..writeln('- `package_and_level_candidates_review.csv`')
    ..writeln()
    ..writeln('## Kandidaten')
    ..writeln()
    ..writeln(
      '- EN->DE-/Sprachcode-Normalisierungskandidaten: '
      '${languageRows.length}',
    )
    ..writeln('- Dubletten-Gruppen: ${duplicateGroups.length}')
    ..writeln('- Dubletten-Zeilen in Review-Datei: ${duplicateRows.length}')
    ..writeln('- Eindeutige Dubletten-Woerter: ${duplicateWordIds.length}')
    ..writeln('- Woerter ohne Kategorie: ${uncategorizedRows.length}')
    ..writeln('- Top-500-Kandidaten: $top500Count')
    ..writeln('- A1-C2-Level-Kandidaten: $levelCandidateCount')
    ..writeln('- Paket-/Level-Review-Zeilen gesamt: ${packageLevelRows.length}')
    ..writeln()
    ..writeln('## Empfohlene Pruefreihenfolge')
    ..writeln()
    ..writeln('1. Sprachcodes normalisieren')
    ..writeln('2. Exakte Dubletten pruefen')
    ..writeln('3. Woerter ohne Kategorie pruefen')
    ..writeln('4. Top 500 als Paket markieren')
    ..writeln('5. A1-C2 als Levelstruktur vorbereiten')
    ..writeln()
    ..writeln('## Hinweis')
    ..writeln()
    ..writeln('Die Dateien enthalten bewusst keine automatischen Loesch- oder')
    ..writeln('Migrationsentscheidungen. Spalten wie `decision`,')
    ..writeln('`proposed_action`, `keep_word_id` und `notes` sind fuer die')
    ..writeln('manuelle Pruefung vorgesehen.');

  final file = File(_summaryPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

Future<void> _writeCsv(
  String path,
  List<String> headers,
  List<List<String>> rows,
) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  final buffer = StringBuffer()..writeln(_csvLine(headers));
  for (final row in rows) {
    buffer.writeln(_csvLine(row));
  }
  await file.writeAsString(buffer.toString());
}

String _csvLine(List<String> values) => values.map(_csvEscape).join(',');

String _csvEscape(String value) {
  final normalized = value
      .replaceAll('\r\n', r'\n')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\n');
  return '"${normalized.replaceAll('"', '""')}"';
}
