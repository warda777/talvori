import 'dart:convert';
import 'dart:io';

const _envPathCandidates = ['.env.local', '.env'];
const _outputCsvPath = 'docs/word-review/supabase_words_review.csv';
const _outputSummaryPath = 'docs/word-review/supabase_words_summary.md';

const _levelLabels = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

const _packageNameMatchers = [
  'top 500',
  'top-500',
  'top_500',
  'basics',
  'starter',
  'exam practice',
  'phrases',
  'idioms',
  'irregular verbs',
  'grammar',
  'syntax',
];

Future<void> main() async {
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

  final client = _SupabaseRestClient(url: url, anonKey: anonKey);
  final words = await client.fetchTable('words', order: 'text.asc');
  final categories = await client.fetchTable('categories', order: 'name.asc');
  final wordCategories = await client.fetchTable(
    'word_categories',
    order: 'word_id.asc',
  );

  final categoryById = <String, Map<String, dynamic>>{};
  for (final category in categories) {
    final id = category['id']?.toString();
    if (id != null && id.isNotEmpty) categoryById[id] = category;
  }

  final categoriesByWordId = <String, List<Map<String, dynamic>>>{};
  for (final link in wordCategories) {
    final wordId = link['word_id']?.toString();
    final categoryId = link['category_id']?.toString();
    if (wordId == null || categoryId == null) continue;
    final category = categoryById[categoryId];
    if (category == null) continue;
    categoriesByWordId.putIfAbsent(wordId, () => []).add(category);
  }

  final rows = <_ReviewRow>[];
  for (final word in words) {
    final id = word['id']?.toString() ?? '';
    final linkedCategories = categoriesByWordId[id] ?? const [];
    rows.add(_ReviewRow.fromWord(word, linkedCategories));
  }

  await _writeCsv(rows);
  await _writeSummary(rows, categories, wordCategories);

  stdout.writeln('Exported ${rows.length} words.');
  stdout.writeln('CSV: $_outputCsvPath');
  stdout.writeln('Summary: $_outputSummaryPath');
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

class _SupabaseRestClient {
  _SupabaseRestClient({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  Future<List<Map<String, dynamic>>> fetchTable(
    String table, {
    String? order,
  }) async {
    final allRows = <Map<String, dynamic>>[];
    const pageSize = 1000;
    var offset = 0;
    while (true) {
      final query = {
        'select': '*',
        if (order != null) 'order': order,
        'limit': '$pageSize',
        'offset': '$offset',
      };
      final uri = Uri.parse(
        '$url/rest/v1/$table',
      ).replace(queryParameters: query);
      final request = await HttpClient().getUrl(uri);
      request.headers
        ..set('apikey', anonKey)
        ..set('Authorization', 'Bearer $anonKey')
        ..set('Accept', 'application/json');
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Supabase read failed for $table: HTTP ${response.statusCode}: $body',
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
}

class _ReviewRow {
  _ReviewRow({
    required this.wordId,
    required this.term,
    required this.translation,
    required this.fromLang,
    required this.toLang,
    required this.currentCategoryNames,
    required this.currentCategoryTypes,
    required this.currentLevel,
    required this.currentTags,
    required this.domain,
    required this.pos,
    required this.sourceOrigin,
    required this.qaScore,
    required this.qaNote,
    required this.proposedWordWorlds,
    required this.proposedLevel,
    required this.proposedPackage,
  });

  factory _ReviewRow.fromWord(
    Map<String, dynamic> word,
    List<Map<String, dynamic>> categories,
  ) {
    final categoryNames =
        categories
            .map((category) => category['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
          ..sort();
    final categoryTypes =
        categories
            .map((category) => category['type']?.toString() ?? '')
            .where((type) => type.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final topicWorlds =
        categories
            .where(_isTopicWordWorld)
            .map((category) => category['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
          ..sort();

    final packages =
        categories
            .where(_isPackageCandidate)
            .map((category) => category['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final originCategories =
        categories
            .where((category) => category['type']?.toString() == 'origin')
            .map((category) => category['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
          ..sort();

    final rawTags = word['tags'];
    final tags = rawTags is List
        ? rawTags.map((tag) => tag.toString()).toList()
        : const <String>[];

    return _ReviewRow(
      wordId: word['id']?.toString() ?? '',
      term: word['text']?.toString() ?? '',
      translation: word['translation']?.toString() ?? '',
      fromLang: word['from_lang']?.toString() ?? '',
      toLang: word['to_lang']?.toString() ?? '',
      currentCategoryNames: categoryNames.join('; '),
      currentCategoryTypes: categoryTypes.join('; '),
      currentLevel: word['level']?.toString() ?? '',
      currentTags: tags.join('; '),
      domain: word['domain']?.toString() ?? '',
      pos: word['pos']?.toString() ?? '',
      sourceOrigin: originCategories.join('; '),
      qaScore: word['qa_score']?.toString() ?? '',
      qaNote: word['qa_note']?.toString() ?? '',
      proposedWordWorlds: topicWorlds.join('; '),
      proposedLevel: word['level']?.toString() ?? '',
      proposedPackage: packages.join('; '),
    );
  }

  final String wordId;
  final String term;
  final String translation;
  final String fromLang;
  final String toLang;
  final String currentCategoryNames;
  final String currentCategoryTypes;
  final String currentLevel;
  final String currentTags;
  final String domain;
  final String pos;
  final String sourceOrigin;
  final String qaScore;
  final String qaNote;
  final String proposedWordWorlds;
  final String proposedLevel;
  final String proposedPackage;

  List<String> toCsvRow() {
    return [
      wordId,
      term,
      translation,
      fromLang,
      toLang,
      currentCategoryNames,
      currentCategoryTypes,
      currentLevel,
      currentTags,
      domain,
      pos,
      sourceOrigin,
      qaScore,
      qaNote,
      '',
      proposedWordWorlds,
      proposedLevel,
      proposedPackage,
      '',
    ];
  }
}

bool _isTopicWordWorld(Map<String, dynamic> category) {
  final type = category['type']?.toString();
  final name = category['name']?.toString() ?? '';
  final slug = category['slug']?.toString() ?? '';
  if (type != 'topic') return false;
  if (_isLevelCandidate(name, slug)) return false;
  if (_isPackageCandidate(category)) return false;
  return true;
}

bool _isPackageCandidate(Map<String, dynamic> category) {
  final name = category['name']?.toString().toLowerCase() ?? '';
  final slug = category['slug']?.toString().toLowerCase() ?? '';
  if (_isTop500Candidate(name, slug)) return true;
  return _packageNameMatchers.any(
    (candidate) => name.contains(candidate) || slug.contains(candidate),
  );
}

bool _isLevelCandidate(String name, String slug) {
  final normalizedName = name.trim().toUpperCase();
  final normalizedSlug = slug.trim().toUpperCase();
  return _levelLabels.contains(normalizedName) ||
      _levelLabels.contains(normalizedSlug);
}

bool _isTop500Candidate(String name, String slug) {
  final normalizedName = name.toLowerCase();
  final normalizedSlug = slug.toLowerCase();
  return normalizedName.contains('top 500') ||
      normalizedName.contains('top-500') ||
      normalizedName.contains('top_500') ||
      normalizedSlug.contains('top-500') ||
      normalizedSlug.contains('top_500') ||
      normalizedSlug == 'top500';
}

Future<void> _writeCsv(List<_ReviewRow> rows) async {
  final file = File(_outputCsvPath);
  await file.parent.create(recursive: true);
  const headers = [
    'word_id',
    'term/text',
    'translation',
    'from_lang',
    'to_lang',
    'current_category_names',
    'current_category_types',
    'current_level',
    'current_tags',
    'domain',
    'pos',
    'source/origin',
    'qa_score',
    'qa_note',
    'decision',
    'proposed_word_worlds',
    'proposed_level',
    'proposed_package',
    'notes',
  ];
  final buffer = StringBuffer()..writeln(_csvLine(headers));
  for (final row in rows) {
    buffer.writeln(_csvLine(row.toCsvRow()));
  }
  await file.writeAsString(buffer.toString());
}

String _csvLine(List<String> values) {
  return values.map(_csvEscape).join(',');
}

String _csvEscape(String value) {
  final normalized = value
      .replaceAll('\r\n', r'\n')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\n');
  final escaped = normalized.replaceAll('"', '""');
  return '"$escaped"';
}

Future<void> _writeSummary(
  List<_ReviewRow> rows,
  List<Map<String, dynamic>> categories,
  List<Map<String, dynamic>> wordCategories,
) async {
  final file = File(_outputSummaryPath);
  await file.parent.create(recursive: true);

  final byLanguagePair = <String, int>{};
  final byLevel = <String, int>{};
  final byCategory = <String, int>{};
  final byCategoryType = <String, int>{};
  var withoutCategory = 0;
  var withoutTranslation = 0;

  final categoryNames = <String>{};
  final levelCategoryNames = <String>{};
  final top500CategoryNames = <String>{};

  for (final row in rows) {
    _increment(byLanguagePair, '${row.fromLang}->${row.toLang}');
    _increment(
      byLevel,
      row.currentLevel.isEmpty ? '(ohne Level)' : row.currentLevel,
    );
    if (row.currentCategoryNames.isEmpty) {
      withoutCategory++;
    } else {
      for (final name in row.currentCategoryNames.split('; ')) {
        _increment(byCategory, name);
        categoryNames.add(name);
      }
    }
    if (row.translation.trim().isEmpty) withoutTranslation++;
  }

  for (final category in categories) {
    final name = category['name']?.toString() ?? '';
    final slug = category['slug']?.toString() ?? '';
    final type = category['type']?.toString() ?? '(ohne Typ)';
    _increment(byCategoryType, type);
    if (_isLevelCandidate(name, slug) || type == 'level') {
      levelCategoryNames.add(name);
    }
    if (_isTop500Candidate(name, slug)) {
      top500CategoryNames.add(name);
    }
  }

  final duplicateTermLang = _duplicates(
    rows,
    (row) => [
      row.term.toLowerCase().trim(),
      row.fromLang.toLowerCase().trim(),
      row.toLang.toLowerCase().trim(),
    ].join('|'),
  );
  final duplicateTermTranslationLang = _duplicates(
    rows,
    (row) => [
      row.term.toLowerCase().trim(),
      row.translation.toLowerCase().trim(),
      row.fromLang.toLowerCase().trim(),
      row.toLang.toLowerCase().trim(),
    ].join('|'),
  );

  final topicCategories = categories.where((category) {
    return category['type']?.toString() == 'topic';
  }).toList();
  final levelCategories = categories.where((category) {
    return category['type']?.toString() == 'level' ||
        _isLevelCandidate(
          category['name']?.toString() ?? '',
          category['slug']?.toString() ?? '',
        );
  }).toList();
  final otherCategories = categories.where((category) {
    final type = category['type']?.toString();
    return type == 'custom' || type == 'origin' || type == 'pos';
  }).toList();

  final buffer = StringBuffer()
    ..writeln('# Supabase Words Review Summary')
    ..writeln()
    ..writeln('Stand: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Dieser Export ist read-only. Es wurden keine produktiven Daten,')
    ..writeln('Kategorien oder SRS-Fortschritte veraendert.')
    ..writeln()
    ..writeln('## Dateien')
    ..writeln()
    ..writeln('- Review CSV: `supabase_words_review.csv`')
    ..writeln('- Summary: `supabase_words_summary.md`')
    ..writeln()
    ..writeln('## Gesamt')
    ..writeln()
    ..writeln('- Woerter insgesamt: ${rows.length}')
    ..writeln('- Kategorie-Zuordnungen: ${wordCategories.length}')
    ..writeln('- Kategorien insgesamt: ${categories.length}')
    ..writeln('- Woerter ohne Kategorie: $withoutCategory')
    ..writeln('- Woerter ohne Uebersetzung: $withoutTranslation')
    ..writeln()
    ..writeln('## Sprachpaare')
    ..writeln();
  _writeMapBullets(buffer, byLanguagePair);

  buffer
    ..writeln()
    ..writeln('## Current Level')
    ..writeln();
  _writeMapBullets(buffer, byLevel);

  buffer
    ..writeln()
    ..writeln('## Kategorien nach Typ')
    ..writeln();
  _writeMapBullets(buffer, byCategoryType);

  buffer
    ..writeln()
    ..writeln('## Kategorien')
    ..writeln();
  _writeMapBullets(buffer, byCategory);

  buffer
    ..writeln()
    ..writeln('## Kategorien vom Typ topic')
    ..writeln();
  _writeCategoryList(buffer, topicCategories);

  buffer
    ..writeln()
    ..writeln('## Kategorien vom Typ level')
    ..writeln();
  _writeCategoryList(buffer, levelCategories);

  buffer
    ..writeln()
    ..writeln('## Kategorien vom Typ custom/origin/pos')
    ..writeln();
  _writeCategoryList(buffer, otherCategories);

  buffer
    ..writeln()
    ..writeln('## Moegliche Dubletten')
    ..writeln()
    ..writeln('- Gleiche term/from_lang/to_lang: ${duplicateTermLang.length}')
    ..writeln(
      '- Gleiche term/translation/from_lang/to_lang: '
      '${duplicateTermTranslationLang.length}',
    )
    ..writeln();

  _writeDuplicateSection(
    buffer,
    'Gleiche term/from_lang/to_lang',
    duplicateTermLang,
  );
  _writeDuplicateSection(
    buffer,
    'Gleiche term/translation/from_lang/to_lang',
    duplicateTermTranslationLang,
  );

  buffer
    ..writeln()
    ..writeln('## Top 500 und Level-Hinweise')
    ..writeln()
    ..writeln(
      '- Top 500 ist Paketkandidat und keine Wortwelt. Gefundene Kategorien: '
      '${top500CategoryNames.isEmpty ? 'keine' : top500CategoryNames.join(', ')}',
    )
    ..writeln(
      '- A1-C2 sind Levelkandidaten und keine Wortwelten. Gefundene Kategorien: '
      '${levelCategoryNames.isEmpty ? 'keine' : levelCategoryNames.join(', ')}',
    )
    ..writeln()
    ..writeln('## Naechster Schritt')
    ..writeln()
    ..writeln(
      'Die CSV manuell Wort fuer Wort pruefen. `decision`, '
      '`proposed_word_worlds`, `proposed_level`, `proposed_package` und '
      '`notes` sind die Review-Spalten fuer die spaetere Bereinigung. '
      'Erst nach Review und Backup sollte eine Migration geplant werden.',
    );

  await file.writeAsString(buffer.toString());
}

void _increment(Map<String, int> map, String key) {
  map[key] = (map[key] ?? 0) + 1;
}

Map<String, List<_ReviewRow>> _duplicates(
  List<_ReviewRow> rows,
  String Function(_ReviewRow row) keyOf,
) {
  final grouped = <String, List<_ReviewRow>>{};
  for (final row in rows) {
    final key = keyOf(row);
    if (key.replaceAll('|', '').isEmpty) continue;
    grouped.putIfAbsent(key, () => []).add(row);
  }
  grouped.removeWhere((_, value) => value.length < 2);
  return grouped;
}

void _writeMapBullets(StringBuffer buffer, Map<String, int> values) {
  final entries = values.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount == 0 ? a.key.compareTo(b.key) : byCount;
    });
  if (entries.isEmpty) {
    buffer.writeln('- keine');
    return;
  }
  for (final entry in entries) {
    buffer.writeln('- ${entry.key}: ${entry.value}');
  }
}

void _writeCategoryList(
  StringBuffer buffer,
  List<Map<String, dynamic>> categories,
) {
  final sorted = categories.toList()
    ..sort((a, b) {
      final aName = a['name']?.toString() ?? '';
      final bName = b['name']?.toString() ?? '';
      return aName.compareTo(bName);
    });
  if (sorted.isEmpty) {
    buffer.writeln('- keine');
    return;
  }
  for (final category in sorted) {
    final name = category['name']?.toString() ?? '';
    final slug = category['slug']?.toString() ?? '';
    final type = category['type']?.toString() ?? '';
    buffer.writeln('- $name (`$slug`, $type)');
  }
}

void _writeDuplicateSection(
  StringBuffer buffer,
  String title,
  Map<String, List<_ReviewRow>> duplicates,
) {
  buffer
    ..writeln('### $title')
    ..writeln();
  if (duplicates.isEmpty) {
    buffer.writeln('- keine');
    return;
  }
  final entries = duplicates.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  for (final entry in entries.take(50)) {
    final preview = entry.value
        .map((row) => '${row.term} / ${row.translation} (${row.wordId})')
        .join('; ');
    buffer.writeln('- `${entry.key}`: $preview');
  }
  if (entries.length > 50) {
    buffer.writeln('- ... ${entries.length - 50} weitere Gruppen');
  }
}
