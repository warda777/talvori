import 'dart:io';

const _sourceCsvPath = 'docs/word-review/supabase_words_review.csv';
const _reviewCsvPath = 'docs/word-review/url_contaminated_words_review.csv';
const _summaryPath = 'docs/word-review/url_contamination_summary.md';

final _urlLikePattern = RegExp(
  r'(https?://|www\.|:~:text=|#:[^\s]*)',
  caseSensitive: false,
);

Future<void> main() async {
  final sourceFile = File(_sourceCsvPath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source CSV: $_sourceCsvPath');
    exitCode = 2;
    return;
  }

  final rows = _readReviewRows(sourceFile);
  final contaminatedRows = rows
      .map(_UrlContaminationCandidate.fromReviewRow)
      .where((candidate) => candidate.issueType.isNotEmpty)
      .toList();

  await _writeReview(contaminatedRows);
  await _writeSummary(contaminatedRows);

  stdout
    ..writeln('URL contamination candidates: ${contaminatedRows.length}')
    ..writeln('Review: $_reviewCsvPath')
    ..writeln('Summary: $_summaryPath')
    ..writeln('No Supabase data changed.');
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
}

class _UrlContaminationCandidate {
  _UrlContaminationCandidate({
    required this.row,
    required this.issueType,
    required this.proposedTerm,
    required this.proposedTranslation,
  });

  factory _UrlContaminationCandidate.fromReviewRow(_ReviewRow row) {
    final termIssues = _issuesFor('term', row.term);
    final translationIssues = _issuesFor('translation', row.translation);
    return _UrlContaminationCandidate(
      row: row,
      issueType: [...termIssues, ...translationIssues].join('; '),
      proposedTerm: _proposeCleanValue(row.term),
      proposedTranslation: _proposeCleanValue(row.translation),
    );
  }

  final _ReviewRow row;
  final String issueType;
  final String proposedTerm;
  final String proposedTranslation;
}

List<String> _issuesFor(String fieldName, String value) {
  final issues = <String>[];
  final lower = value.toLowerCase();
  if (lower.contains('http://')) issues.add('${fieldName}_contains_http');
  if (lower.contains('https://')) issues.add('${fieldName}_contains_https');
  if (lower.contains('www.')) issues.add('${fieldName}_contains_www');
  if (lower.contains('#:')) issues.add('${fieldName}_contains_text_fragment');
  if (lower.contains(':~:text=')) {
    issues.add('${fieldName}_contains_text_quote_fragment');
  }
  if (value.trim().length > 80) issues.add('${fieldName}_longer_than_80');
  if (_urlLikePattern.hasMatch(value)) issues.add('${fieldName}_url_like');
  return issues.toSet().toList();
}

String _proposeCleanValue(String value) {
  if (!_urlLikePattern.hasMatch(value) && value.trim().length <= 80) {
    return '';
  }

  final firstUrlMatch = _urlLikePattern.firstMatch(value);
  if (firstUrlMatch == null) return '';

  final prefix = value.substring(0, firstUrlMatch.start);
  final cleaned = prefix
      .replaceAll(RegExp(r'\\n|\r|\n'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'^["“”]+|["“”]+$'), '')
      .trim();

  if (cleaned.isEmpty ||
      cleaned.length > 80 ||
      _urlLikePattern.hasMatch(cleaned)) {
    return '';
  }
  return cleaned;
}

Future<void> _writeReview(List<_UrlContaminationCandidate> candidates) async {
  await _writeCsv(
    _reviewCsvPath,
    [
      'word_id',
      'term',
      'translation',
      'from_lang',
      'to_lang',
      'current_category_names',
      'current_level',
      'issue_type',
      'proposed_term',
      'proposed_translation',
      'decision',
      'notes',
    ],
    [
      for (final candidate in candidates)
        [
          candidate.row.wordId,
          candidate.row.term,
          candidate.row.translation,
          candidate.row.fromLang,
          candidate.row.toLang,
          candidate.row.currentCategoryNames,
          candidate.row.currentLevel,
          candidate.issueType,
          candidate.proposedTerm,
          candidate.proposedTranslation,
          '',
          '',
        ],
    ],
  );
}

Future<void> _writeSummary(List<_UrlContaminationCandidate> candidates) async {
  final issueCounts = <String, int>{};
  for (final candidate in candidates) {
    for (final issue in candidate.issueType.split('; ')) {
      if (issue.isEmpty) continue;
      issueCounts[issue] = (issueCounts[issue] ?? 0) + 1;
    }
  }
  final sortedIssues = issueCounts.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final buffer = StringBuffer()
    ..writeln('# URL Contamination Summary')
    ..writeln()
    ..writeln('Stand: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Dieser Schritt ist read-only. Es wurden keine Supabase-Daten,')
    ..writeln('Woerter, Kategorien oder SRS-Fortschritte veraendert.')
    ..writeln()
    ..writeln('## Ergebnis')
    ..writeln()
    ..writeln('- Betroffene Woerter: ${candidates.length}')
    ..writeln()
    ..writeln('## Issue-Typen')
    ..writeln();

  if (sortedIssues.isEmpty) {
    buffer.writeln('- Keine Auffaelligkeiten gefunden.');
  } else {
    for (final issue in sortedIssues) {
      buffer.writeln('- `${issue.key}`: ${issue.value}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Beispiele')
    ..writeln();

  for (final candidate in candidates.take(10)) {
    buffer
      ..writeln(
        '- `${candidate.row.wordId}`: '
        '${_summaryValue(candidate.row.term)} / '
        '${_summaryValue(candidate.row.translation)}',
      )
      ..writeln('  - Issues: ${candidate.issueType}');
    if (candidate.proposedTerm.isNotEmpty ||
        candidate.proposedTranslation.isNotEmpty) {
      buffer.writeln(
        '  - Vorschlag: ${candidate.proposedTerm} / '
        '${candidate.proposedTranslation}',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Empfehlung')
    ..writeln()
    ..writeln('1. Die Review-Datei `url_contaminated_words_review.csv` manuell')
    ..writeln('   pruefen.')
    ..writeln('2. Bei sicheren Faellen `decision` und `notes` ausfuellen.')
    ..writeln('3. Erst danach ein separates, dry-run-first Update-Skript')
    ..writeln('   vorbereiten.')
    ..writeln(
      '4. Sprachcode-Normalisierung erst nach dieser Pruefung produktiv',
    )
    ..writeln('   ausfuehren, damit verunreinigte Begriffe nicht still')
    ..writeln('   normalisiert werden.');

  final file = File(_summaryPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

String _summaryValue(String value) {
  final compact = value
      .replaceAll(RegExp(r'\\n|\r|\n'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (compact.length <= 90) return compact;
  return '${compact.substring(0, 87)}...';
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
