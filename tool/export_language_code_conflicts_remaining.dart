import 'dart:convert';
import 'dart:io';

const _sourceCsvPath =
    'docs/word-review/language_code_normalization_review.csv';
const _outputCsvPath =
    'docs/word-review/language_code_conflicts_remaining_review.csv';
const _outputSummaryPath =
    'docs/word-review/language_code_conflicts_remaining_summary.md';
const _envPathCandidates = ['.env.local', '.env'];

Future<void> main() async {
  final sourceFile = File(_sourceCsvPath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source CSV: $_sourceCsvPath');
    exitCode = 2;
    return;
  }

  final candidates = _readCandidates(sourceFile);
  final env = _loadEnv();
  final url = env['SUPABASE_URL'];
  final anonKey = env['SUPABASE_ANON_KEY'];
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    stderr.writeln(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env.local/.env.',
    );
    exitCode = 2;
    return;
  }

  final client = _SupabaseReadOnlyClient(url: url, anonKey: anonKey);
  final words = await client.fetchWords();
  final wordsById = {
    for (final word in words)
      if (word.id.isNotEmpty) word.id: word,
  };

  final remainingCandidates = <_WordRow>[];
  for (final candidate in candidates) {
    final remote = wordsById[candidate.wordId];
    if (remote == null) continue;
    if (remote.fromLang == 'EN' && remote.toLang == 'DE') {
      remainingCandidates.add(remote);
    }
  }

  final conflicts = <_ConflictRow>[];
  for (final candidate in remainingCandidates) {
    final candidateConflicts = words.where((word) {
      return word.id != candidate.id &&
          word.text == candidate.text &&
          word.fromLang == 'en' &&
          word.toLang == 'de';
    });
    for (final conflict in candidateConflicts) {
      conflicts.add(
        _ConflictRow(
          candidate: candidate,
          conflict: conflict,
          conflictType: conflict.translation == candidate.translation
              ? 'same_text_translation_lang'
              : 'same_text_lang',
        ),
      );
    }
  }

  conflicts.sort((a, b) {
    final textOrder = a.candidate.text.compareTo(b.candidate.text);
    if (textOrder != 0) return textOrder;
    return a.conflict.id.compareTo(b.conflict.id);
  });

  await _writeReviewCsv(conflicts);
  await _writeSummary(
    remainingCandidateCount: remainingCandidates.length,
    conflicts: conflicts,
  );

  stdout
    ..writeln('Remaining EN/DE candidates: ${remainingCandidates.length}')
    ..writeln('Conflicts: ${conflicts.length}')
    ..writeln('CSV: $_outputCsvPath')
    ..writeln('Summary: $_outputSummaryPath')
    ..writeln('No Supabase data changed.');
}

List<_CandidateRow> _readCandidates(File file) {
  final records = _parseCsv(file.readAsStringSync());
  if (records.isEmpty) return const [];
  final headers = records.first;
  final rows = <_CandidateRow>[];
  for (final record in records.skip(1)) {
    final values = <String, String>{};
    for (var index = 0; index < headers.length; index++) {
      values[headers[index]] = index < record.length ? record[index] : '';
    }
    final wordId = values['word_id']?.trim() ?? '';
    if (wordId.isEmpty) continue;
    rows.add(_CandidateRow(wordId: wordId));
  }
  return rows;
}

class _CandidateRow {
  const _CandidateRow({required this.wordId});

  final String wordId;
}

class _WordRow {
  const _WordRow({
    required this.id,
    required this.text,
    required this.translation,
    required this.fromLang,
    required this.toLang,
  });

  factory _WordRow.fromJson(Map<String, dynamic> json) {
    return _WordRow(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
      fromLang: json['from_lang']?.toString() ?? '',
      toLang: json['to_lang']?.toString() ?? '',
    );
  }

  final String id;
  final String text;
  final String translation;
  final String fromLang;
  final String toLang;
}

class _ConflictRow {
  const _ConflictRow({
    required this.candidate,
    required this.conflict,
    required this.conflictType,
  });

  final _WordRow candidate;
  final _WordRow conflict;
  final String conflictType;
}

class _SupabaseReadOnlyClient {
  _SupabaseReadOnlyClient({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  Future<List<_WordRow>> fetchWords() async {
    final allRows = <_WordRow>[];
    const pageSize = 1000;
    var offset = 0;
    while (true) {
      final uri = Uri.parse('$url/rest/v1/words').replace(
        queryParameters: {
          'select': 'id,text,translation,from_lang,to_lang',
          'order': 'text.asc',
          'limit': '$pageSize',
          'offset': '$offset',
        },
      );
      final request = await HttpClient().getUrl(uri);
      request.headers
        ..set('apikey', anonKey)
        ..set('Authorization', 'Bearer $anonKey')
        ..set('Accept', 'application/json');
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Supabase read failed for words: HTTP ${response.statusCode}: $body',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! List) {
        throw StateError('Unexpected Supabase response for words.');
      }
      final rows = decoded
          .cast<Map<String, dynamic>>()
          .map(_WordRow.fromJson)
          .toList();
      allRows.addAll(rows);
      if (rows.length < pageSize) break;
      offset += pageSize;
    }
    return allRows;
  }
}

Future<void> _writeReviewCsv(List<_ConflictRow> conflicts) async {
  await _writeCsv(
    _outputCsvPath,
    [
      'candidate_id',
      'candidate_text',
      'candidate_translation',
      'conflicting_id',
      'conflicting_text',
      'conflicting_translation',
      'conflict_type',
      'proposed_action',
      'keep_word_id',
      'notes',
    ],
    [
      for (final row in conflicts)
        [
          row.candidate.id,
          row.candidate.text,
          row.candidate.translation,
          row.conflict.id,
          row.conflict.text,
          row.conflict.translation,
          row.conflictType,
          '',
          '',
          '',
        ],
    ],
  );
}

Future<void> _writeSummary({
  required int remainingCandidateCount,
  required List<_ConflictRow> conflicts,
}) async {
  final exactDuplicates = conflicts
      .where((row) => row.conflictType == 'same_text_translation_lang')
      .length;
  final sameTextDifferentTranslation = conflicts
      .where((row) => row.conflictType == 'same_text_lang')
      .length;

  final file = File(_outputSummaryPath);
  await file.parent.create(recursive: true);
  await file.writeAsString('''
# Remaining Language-Code Conflicts Summary

Stand: ${DateTime.now().toIso8601String()}

Dieser Schritt ist read-only. Es wurden keine Supabase-Daten, Woerter,
Kategorien oder SRS-Fortschritte veraendert.

## Ergebnis

- Verbleibende EN/DE-Kandidaten: $remainingCandidateCount
- Konflikte: ${conflicts.length}
- Exakte Dubletten: $exactDuplicates
- Gleicher Text, andere Uebersetzung: $sameTextDifferentTranslation

## Hinweis

Die Datei `language_code_conflicts_remaining_review.csv` dient als Grundlage
fuer manuelle Entscheidungen. `proposed_action`, `keep_word_id` und `notes`
bleiben bewusst leer.
''');
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

Map<String, String> _loadEnv() {
  final env = <String, String>{};
  for (final path in _envPathCandidates) {
    final file = File(path);
    if (!file.existsSync()) continue;
    for (final rawLine in file.readAsLinesSync()) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final separator = line.indexOf('=');
      if (separator <= 0) continue;
      final key = line.substring(0, separator).trim();
      var value = line.substring(separator + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      env[key] = value;
    }
  }
  return env;
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
