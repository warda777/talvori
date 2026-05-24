import 'dart:convert';
import 'dart:io';

const _sourceCsvPath =
    'docs/word-review/language_code_conflicts_remaining_review.csv';
const _outputCsvPath = 'docs/word-review/language_code_conflict_context.csv';
const _outputSummaryPath =
    'docs/word-review/language_code_conflict_context_summary.md';
const _envPathCandidates = ['.env.local', '.env'];

Future<void> main() async {
  final sourceFile = File(_sourceCsvPath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source CSV: $_sourceCsvPath');
    exitCode = 2;
    return;
  }

  final conflicts = _readConflictRows(sourceFile);
  final wordIds = <String>{
    for (final conflict in conflicts) conflict.candidateId,
    for (final conflict in conflicts) conflict.conflictingId,
  }..remove('');

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
  final words = await client.fetchWords(wordIds);
  final categories = await client.fetchCategoriesForWords(wordIds);
  final tableNotes = <String>[];
  final userWordsCounts = await client.fetchCountsByWordId(
    table: 'user_words',
    wordIds: wordIds,
    tableNotes: tableNotes,
  );
  final wordProgressCounts = await client.fetchCountsByWordId(
    table: 'word_progress',
    wordIds: wordIds,
    tableNotes: tableNotes,
  );
  final userWordSrsCounts = await client.fetchCountsByWordId(
    table: 'user_word_srs',
    wordIds: wordIds,
    tableNotes: tableNotes,
  );

  final contextRows = <_ContextRow>[];
  for (final conflict in conflicts) {
    final group =
        '${conflict.candidateText} | '
        '${conflict.candidateId} -> ${conflict.conflictingId}';
    final candidate = words[conflict.candidateId];
    if (candidate != null) {
      contextRows.add(
        _ContextRow(
          conflictGroup: group,
          role: 'candidate',
          word: candidate,
          categories: categories[candidate.id] ?? const [],
          userWordsCount: userWordsCounts[candidate.id] ?? 0,
          wordProgressCount: wordProgressCounts[candidate.id] ?? 0,
          userWordSrsCount: userWordSrsCounts[candidate.id] ?? 0,
        ),
      );
    }
    final conflicting = words[conflict.conflictingId];
    if (conflicting != null) {
      contextRows.add(
        _ContextRow(
          conflictGroup: group,
          role: 'conflict',
          word: conflicting,
          categories: categories[conflicting.id] ?? const [],
          userWordsCount: userWordsCounts[conflicting.id] ?? 0,
          wordProgressCount: wordProgressCounts[conflicting.id] ?? 0,
          userWordSrsCount: userWordSrsCounts[conflicting.id] ?? 0,
        ),
      );
    }
  }

  await _writeContextCsv(contextRows);
  await _writeSummary(
    conflicts: conflicts,
    contextRows: contextRows,
    tableNotes: tableNotes,
  );

  stdout
    ..writeln('Conflict groups: ${conflicts.length}')
    ..writeln('Word IDs: ${wordIds.length}')
    ..writeln('Context rows: ${contextRows.length}')
    ..writeln('CSV: $_outputCsvPath')
    ..writeln('Summary: $_outputSummaryPath')
    ..writeln('No Supabase data changed.');
}

List<_ConflictReviewRow> _readConflictRows(File file) {
  final records = _parseCsv(file.readAsStringSync());
  if (records.isEmpty) return const [];
  final headers = records.first;
  final rows = <_ConflictReviewRow>[];
  for (final record in records.skip(1)) {
    final values = <String, String>{};
    for (var index = 0; index < headers.length; index++) {
      values[headers[index]] = index < record.length ? record[index] : '';
    }
    final candidateId = values['candidate_id']?.trim() ?? '';
    final conflictingId = values['conflicting_id']?.trim() ?? '';
    if (candidateId.isEmpty || conflictingId.isEmpty) continue;
    rows.add(_ConflictReviewRow(values));
  }
  return rows;
}

class _ConflictReviewRow {
  const _ConflictReviewRow(this.values);

  final Map<String, String> values;

  String get candidateId => values['candidate_id'] ?? '';
  String get candidateText => values['candidate_text'] ?? '';
  String get candidateTranslation => values['candidate_translation'] ?? '';
  String get conflictingId => values['conflicting_id'] ?? '';
  String get conflictType => values['conflict_type'] ?? '';
  String get proposedAction => values['proposed_action'] ?? '';
}

class _WordContext {
  const _WordContext({
    required this.id,
    required this.text,
    required this.translation,
    required this.fromLang,
    required this.toLang,
    required this.level,
    required this.tags,
    required this.domain,
    required this.pos,
    required this.createdAt,
    required this.translatedBy,
    required this.translatedAt,
    required this.qaScore,
    required this.qaNote,
  });

  factory _WordContext.fromJson(Map<String, dynamic> json) {
    final tagsValue = json['tags'];
    final tags = tagsValue is List
        ? tagsValue.map((value) => value.toString()).join(';')
        : tagsValue?.toString() ?? '';
    return _WordContext(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
      fromLang: json['from_lang']?.toString() ?? '',
      toLang: json['to_lang']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      tags: tags,
      domain: json['domain']?.toString() ?? '',
      pos: json['pos']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      translatedBy: json['translated_by']?.toString() ?? '',
      translatedAt: json['translated_at']?.toString() ?? '',
      qaScore: json['qa_score']?.toString() ?? '',
      qaNote: json['qa_note']?.toString() ?? '',
    );
  }

  final String id;
  final String text;
  final String translation;
  final String fromLang;
  final String toLang;
  final String level;
  final String tags;
  final String domain;
  final String pos;
  final String createdAt;
  final String translatedBy;
  final String translatedAt;
  final String qaScore;
  final String qaNote;
}

class _CategoryContext {
  const _CategoryContext({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.groupSlug,
    required this.groupName,
  });

  factory _CategoryContext.fromJson(Map<String, dynamic> json) {
    return _CategoryContext(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      groupSlug: json['group_slug']?.toString() ?? '',
      groupName: json['group_name']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String slug;
  final String type;
  final String groupSlug;
  final String groupName;
}

class _ContextRow {
  const _ContextRow({
    required this.conflictGroup,
    required this.role,
    required this.word,
    required this.categories,
    required this.userWordsCount,
    required this.wordProgressCount,
    required this.userWordSrsCount,
  });

  final String conflictGroup;
  final String role;
  final _WordContext word;
  final List<_CategoryContext> categories;
  final int userWordsCount;
  final int wordProgressCount;
  final int userWordSrsCount;

  bool get hasProgressReferences =>
      userWordsCount > 0 || wordProgressCount > 0 || userWordSrsCount > 0;

  bool get hasCategoriesOrTags => categories.isNotEmpty || word.tags.isNotEmpty;

  List<String> toCsvRow() {
    return [
      conflictGroup,
      role,
      word.id,
      word.text,
      word.translation,
      word.fromLang,
      word.toLang,
      word.level,
      word.tags,
      word.domain,
      word.pos,
      _joinUnique(categories.map((category) => category.name)),
      _joinUnique(categories.map((category) => category.type)),
      _joinUnique(categories.map((category) => category.groupName)),
      '$userWordsCount',
      '$wordProgressCount',
      '$userWordSrsCount',
      word.createdAt,
      word.translatedBy,
      word.translatedAt,
      word.qaScore,
      word.qaNote,
      '',
      '',
    ];
  }
}

class _SupabaseReadOnlyClient {
  _SupabaseReadOnlyClient({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  Future<Map<String, _WordContext>> fetchWords(Set<String> wordIds) async {
    final rows = await _fetchTable(
      'words',
      select:
          'id,text,translation,from_lang,to_lang,level,tags,domain,pos,'
          'created_at,translated_by,translated_at,qa_score,qa_note',
      wordIds: wordIds,
    );
    return {
      for (final row in rows)
        _WordContext.fromJson(row).id: _WordContext.fromJson(row),
    };
  }

  Future<Map<String, List<_CategoryContext>>> fetchCategoriesForWords(
    Set<String> wordIds,
  ) async {
    final categories = await _fetchAllTable(
      'categories',
      select: 'id,name,slug,type,group_slug,group_name',
    );
    final categoryById = {
      for (final category in categories)
        (category['id']?.toString() ?? ''): _CategoryContext.fromJson(category),
    };
    final links = await _fetchTable(
      'word_categories',
      select: 'word_id,category_id',
      wordIds: wordIds,
    );
    final result = <String, List<_CategoryContext>>{};
    for (final link in links) {
      final wordId = link['word_id']?.toString() ?? '';
      final categoryId = link['category_id']?.toString() ?? '';
      final category = categoryById[categoryId];
      if (wordId.isEmpty || category == null) continue;
      result.putIfAbsent(wordId, () => []).add(category);
    }
    for (final list in result.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }

  Future<Map<String, int>> fetchCountsByWordId({
    required String table,
    required Set<String> wordIds,
    required List<String> tableNotes,
  }) async {
    try {
      final rows = await _fetchTable(
        table,
        select: 'word_id',
        wordIds: wordIds,
      );
      final counts = <String, int>{};
      for (final row in rows) {
        final wordId = row['word_id']?.toString() ?? '';
        if (wordId.isEmpty) continue;
        counts[wordId] = (counts[wordId] ?? 0) + 1;
      }
      tableNotes.add('$table: read ok (${rows.length} rows visible).');
      return counts;
    } on Object catch (error) {
      tableNotes.add('$table: not readable or unavailable ($error).');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTable(
    String table, {
    required String select,
    required Set<String> wordIds,
  }) async {
    if (wordIds.isEmpty) return const [];
    final idList = wordIds.map((id) => '"$id"').join(',');
    return _fetchAllTable(
      table,
      select: select,
      extraQuery: {'word_id': 'in.($idList)'},
      idFallbackQuery: {'id': 'in.($idList)'},
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllTable(
    String table, {
    required String select,
    Map<String, String>? extraQuery,
    Map<String, String>? idFallbackQuery,
  }) async {
    Future<List<Map<String, dynamic>>> fetchWith(
      Map<String, String>? query,
    ) async {
      final allRows = <Map<String, dynamic>>[];
      const pageSize = 1000;
      var offset = 0;
      while (true) {
        final uri = Uri.parse('$url/rest/v1/$table').replace(
          queryParameters: {
            'select': select,
            'limit': '$pageSize',
            'offset': '$offset',
            if (query != null) ...query,
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
            'Supabase read failed for $table: '
            'HTTP ${response.statusCode}: $body',
          );
        }
        final decoded = jsonDecode(body);
        if (decoded is! List) {
          throw StateError('Unexpected Supabase response for $table.');
        }
        final rows = decoded.cast<Map<String, dynamic>>();
        allRows.addAll(rows);
        if (rows.length < pageSize) break;
        offset += pageSize;
      }
      return allRows;
    }

    try {
      return await fetchWith(extraQuery);
    } on Object {
      if (idFallbackQuery == null) rethrow;
      return fetchWith(idFallbackQuery);
    }
  }
}

Future<void> _writeContextCsv(List<_ContextRow> rows) async {
  await _writeCsv(
    _outputCsvPath,
    [
      'conflict_group',
      'role',
      'word_id',
      'text',
      'translation',
      'from_lang',
      'to_lang',
      'level',
      'tags',
      'domain',
      'pos',
      'category_names',
      'category_types',
      'group_names',
      'user_words_count',
      'word_progress_count',
      'user_word_srs_count',
      'created_at',
      'translated_by',
      'translated_at',
      'qa_score',
      'qa_note',
      'suggested_decision',
      'notes',
    ],
    [for (final row in rows) row.toCsvRow()],
  );
}

Future<void> _writeSummary({
  required List<_ConflictReviewRow> conflicts,
  required List<_ContextRow> contextRows,
  required List<String> tableNotes,
}) async {
  final idsWithProgress = contextRows
      .where((row) => row.hasProgressReferences)
      .map((row) => row.word.id)
      .toSet();
  final groupsWithProgress = conflicts.where((conflict) {
    return idsWithProgress.contains(conflict.candidateId) ||
        idsWithProgress.contains(conflict.conflictingId);
  }).toList();
  final groupsWithCategoriesBothSides = conflicts.where((conflict) {
    final candidate = contextRows.any(
      (row) =>
          row.role == 'candidate' &&
          row.word.id == conflict.candidateId &&
          row.hasCategoriesOrTags,
    );
    final conflictRow = contextRows.any(
      (row) =>
          row.role == 'conflict' &&
          row.word.id == conflict.conflictingId &&
          row.hasCategoriesOrTags,
    );
    return candidate && conflictRow;
  }).toList();
  final exactDuplicates = conflicts
      .where(
        (conflict) => conflict.conflictType == 'same_text_translation_lang',
      )
      .toList();
  final meaningVariants = conflicts
      .where(
        (conflict) =>
            conflict.proposedAction == 'keep_separate_or_merge_meanings',
      )
      .toList();

  final file = File(_outputSummaryPath);
  await file.parent.create(recursive: true);
  final buffer = StringBuffer()
    ..writeln('# Language-Code Conflict Context Summary')
    ..writeln()
    ..writeln('Stand: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Dieser Schritt ist read-only. Es wurden keine Supabase-Daten,')
    ..writeln('Woerter, Kategorien, `user_words`, `word_progress` oder')
    ..writeln('`user_word_srs` veraendert.')
    ..writeln()
    ..writeln('## Ergebnis')
    ..writeln()
    ..writeln('- Konfliktgruppen: ${conflicts.length}')
    ..writeln(
      '- Beteiligte Wort-IDs: ${contextRows.map((row) => row.word.id).toSet().length}',
    )
    ..writeln('- Kontext-Zeilen: ${contextRows.length}')
    ..writeln()
    ..writeln('## Konfliktgruppen')
    ..writeln();

  for (final conflict in conflicts) {
    buffer.writeln(
      '- `${conflict.candidateText}`: `${conflict.candidateId}` vs '
      '`${conflict.conflictingId}` (${conflict.conflictType})',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Progress-/SRS-/User-Bezuege')
    ..writeln();
  if (groupsWithProgress.isEmpty) {
    buffer.writeln('- Keine sichtbaren Progress-/SRS-/User-Bezuege gefunden.');
  } else {
    for (final conflict in groupsWithProgress) {
      buffer.writeln('- `${conflict.candidateText}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Kategorien/Tags auf beiden Seiten')
    ..writeln();
  if (groupsWithCategoriesBothSides.isEmpty) {
    buffer.writeln(
      '- Keine Gruppe mit Kategorien/Tags auf beiden Seiten gefunden.',
    );
  } else {
    for (final conflict in groupsWithCategoriesBothSides) {
      buffer.writeln('- `${conflict.candidateText}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Einordnung')
    ..writeln()
    ..writeln(
      '- Wirken wie exakte Dubletten: '
      '${_joinUnique(exactDuplicates.map((row) => row.candidateText))}',
    )
    ..writeln(
      '- Wirken wie Bedeutungsvarianten: '
      '${_joinUnique(meaningVariants.map((row) => row.candidateText))}',
    )
    ..writeln()
    ..writeln('## Tabellenzugriff')
    ..writeln();
  for (final note in tableNotes) {
    buffer.writeln('- $note');
  }

  buffer
    ..writeln()
    ..writeln('## Entscheidungskriterien')
    ..writeln()
    ..writeln(
      '- Wenn candidate und conflict exakt gleiche Uebersetzung und keine',
    )
    ..writeln('  separaten Progress-Verweise haben: merge/archive pruefen.')
    ..writeln('- Wenn unterschiedliche Uebersetzung, aber gleiche Bedeutung:')
    ..writeln('  Uebersetzung zusammenfuehren pruefen.')
    ..writeln('- Wenn unterschiedliche Bedeutung: getrennt behalten pruefen.')
    ..writeln(
      '- Wenn SRS/user_words an beiden haengen: keine automatische Loeschung.',
    )
    ..writeln()
    ..writeln('Keine produktive Entscheidung wurde getroffen.');

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

String _joinUnique(Iterable<String> values) {
  final unique =
      values
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return unique.join('; ');
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
