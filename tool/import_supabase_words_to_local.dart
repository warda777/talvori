import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/services/supabase_words_local_import_service.dart';

const _envPathCandidates = ['.env.local', '.env'];
const _defaultReportPath = 'docs/word-review/local_import_report.md';
const _defaultConflictsPath = 'docs/word-review/local_import_conflicts.csv';

Future<void> main(List<String> args) async {
  final options = _ImportToolOptions.parse(args);
  if (options.showHelp) {
    stdout.writeln(_usage);
    return;
  }

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

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = options.databasePath ?? await _defaultDatabasePath();
  final client = _SupabaseRestClient(url: url, anonKey: anonKey);
  Database? database;
  try {
    stdout.writeln(
      options.apply
          ? 'Supabase local word import apply'
          : 'Supabase local word import dry-run',
    );
    stdout.writeln('Reading Supabase words, categories and word_categories...');
    final bundle = await _readRemoteBundle(client);
    stdout.writeln('Remote words read: ${bundle.words.length}');
    if (bundle.words.length > SupabaseWordsLocalImportService.maxRemoteWords) {
      throw StateError(
        'Remote import aborted: ${bundle.words.length} words exceeds '
        '${SupabaseWordsLocalImportService.maxRemoteWords}.',
      );
    }

    stdout.writeln('Opening local SQLite database: $dbPath');
    await Directory(p.dirname(dbPath)).create(recursive: true);
    database = await databaseFactoryFfi.openDatabase(dbPath);
    await database.execute('PRAGMA foreign_keys = ON');
    await _ensureImportSchema(database);

    final service = SupabaseWordsLocalImportService();
    final now = DateTime.now().toUtc();
    final report = options.apply
        ? await service.apply(database: database, bundle: bundle, now: now)
        : await service.preview(database: database, bundle: bundle, now: now);

    await _writeReport(options.reportPath, report);
    await _writeConflicts(options.conflictsPath, report.translationConflicts);

    stdout
      ..writeln('Local words created: ${report.localWordsCreated}')
      ..writeln('Local words reused: ${report.localWordsReused}')
      ..writeln('Local words updated: ${report.localWordsUpdated}')
      ..writeln('Memberships created: ${report.membershipsCreated}')
      ..writeln('Levels set: ${report.levelsSet}')
      ..writeln('Translation conflicts: ${report.translationConflicts.length}')
      ..writeln(
        'word_progress rows before/after: '
        '${report.wordProgressRowsBefore}/${report.wordProgressRowsAfter}',
      )
      ..writeln('Report: ${options.reportPath}')
      ..writeln('Conflicts CSV: ${options.conflictsPath}');

    if (!options.apply) {
      stdout.writeln('No local data changed. Run with --apply to write.');
    }
    if (report.wordProgressRowsBefore != report.wordProgressRowsAfter) {
      stderr.writeln('Unexpected word_progress row count change.');
      exitCode = 3;
    }
  } catch (error, stackTrace) {
    stderr.writeln('Import failed: $error');
    if (options.verbose) stderr.writeln(stackTrace);
    exitCode = 1;
  } finally {
    await database?.close();
  }
}

Future<void> _ensureImportSchema(Database database) async {
  await database.execute('''
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
  await database.execute('''
CREATE TABLE IF NOT EXISTS words (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  term TEXT NOT NULL,
  translation TEXT NOT NULL,
  translation_status TEXT NOT NULL DEFAULT 'translated',
  source_language TEXT,
  target_language TEXT,
  translation_error TEXT,
  level TEXT,
  example_sentence TEXT,
  notes TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
  await database.execute(
    'CREATE INDEX IF NOT EXISTS idx_words_category_id ON words (category_id)',
  );
  final wordColumns = await database.rawQuery('PRAGMA table_info(words)');
  if (!wordColumns.any((row) => row['name'] == 'level')) {
    await database.execute('ALTER TABLE words ADD COLUMN level TEXT');
  }
  await database.execute('''
CREATE TABLE IF NOT EXISTS word_progress (
  id TEXT PRIMARY KEY,
  word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  mode_id TEXT NOT NULL,
  stage TEXT NOT NULL,
  pass_count INTEGER NOT NULL DEFAULT 0,
  wrong_count INTEGER NOT NULL DEFAULT 0,
  next_due_at TEXT,
  last_reviewed_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (word_id, category_id, mode_id)
)
''');
  await database.execute('''
CREATE TABLE IF NOT EXISTS word_world_memberships (
  word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (word_id, category_id)
)
''');
  await database.execute(
    'CREATE INDEX IF NOT EXISTS idx_word_world_memberships_word_id '
    'ON word_world_memberships (word_id)',
  );
  await database.execute(
    'CREATE INDEX IF NOT EXISTS idx_word_world_memberships_category_id '
    'ON word_world_memberships (category_id)',
  );
}

Future<SupabaseWordsLocalImportBundle> _readRemoteBundle(
  _SupabaseRestClient client,
) async {
  final words = await client.fetchTable('words', order: 'text.asc');
  final categories = await client.fetchTable('categories', order: 'name.asc');
  final wordCategories = await client.fetchTable(
    'word_categories',
    order: 'word_id.asc',
  );
  return SupabaseWordsLocalImportBundle(
    words: words.map(SupabaseRemoteWord.fromJson).toList(growable: false),
    categories: categories
        .map(SupabaseRemoteCategory.fromJson)
        .toList(growable: false),
    wordCategories: wordCategories
        .map(SupabaseRemoteWordCategory.fromJson)
        .where((link) => link.wordId.isNotEmpty && link.categoryId.isNotEmpty)
        .toList(growable: false),
  );
}

Future<String> _defaultDatabasePath() async {
  final databasesPath = await getDatabasesPath();
  return LocalAppDatabasePath.buildPath(databasesPath);
}

Future<void> _writeReport(
  String path,
  SupabaseWordsLocalImportReport report,
) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(report.toMarkdown());
}

Future<void> _writeConflicts(
  String path,
  List<SupabaseLocalImportConflict> conflicts,
) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  final buffer = StringBuffer()
    ..writeln(
      [
        'remote_word_id',
        'remote_text',
        'remote_translation',
        'local_word_id',
        'local_term',
        'local_translation',
        'issue_type',
        'notes',
      ].join(','),
    );
  for (final conflict in conflicts) {
    buffer.writeln(
      [
        conflict.remoteWordId,
        conflict.remoteText,
        conflict.remoteTranslation,
        conflict.localWordId,
        conflict.localTerm,
        conflict.localTranslation,
        conflict.issueType,
        conflict.notes,
      ].map(_csvEscape).join(','),
    );
  }
  await file.writeAsString(buffer.toString());
}

String _csvEscape(String value) {
  final needsQuotes =
      value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
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

class _ImportToolOptions {
  const _ImportToolOptions({
    required this.apply,
    required this.showHelp,
    required this.verbose,
    required this.reportPath,
    required this.conflictsPath,
    this.databasePath,
  });

  factory _ImportToolOptions.parse(List<String> args) {
    var apply = false;
    var showHelp = false;
    var verbose = false;
    var reportPath = _defaultReportPath;
    var conflictsPath = _defaultConflictsPath;
    String? databasePath;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      switch (arg) {
        case '--apply':
          apply = true;
        case '--help':
        case '-h':
          showHelp = true;
        case '--verbose':
          verbose = true;
        case '--db-path':
          index++;
          if (index >= args.length) {
            throw ArgumentError('--db-path requires a value.');
          }
          databasePath = args[index];
        case '--report-path':
          index++;
          if (index >= args.length) {
            throw ArgumentError('--report-path requires a value.');
          }
          reportPath = args[index];
        case '--conflicts-path':
          index++;
          if (index >= args.length) {
            throw ArgumentError('--conflicts-path requires a value.');
          }
          conflictsPath = args[index];
        default:
          throw ArgumentError('Unknown argument: $arg');
      }
    }

    return _ImportToolOptions(
      apply: apply,
      showHelp: showHelp,
      verbose: verbose,
      databasePath: databasePath,
      reportPath: reportPath,
      conflictsPath: conflictsPath,
    );
  }

  final bool apply;
  final bool showHelp;
  final bool verbose;
  final String? databasePath;
  final String reportPath;
  final String conflictsPath;
}

const _usage = '''
Usage: dart run tool/import_supabase_words_to_local.dart [options]

Options:
  --apply                    Write to the local SQLite database.
  --db-path <path>           Local SQLite path. Defaults to the app DB path.
  --report-path <path>       Markdown report output path.
  --conflicts-path <path>    CSV conflict output path.
  --verbose                  Print stack traces on errors.
  --help                     Show this help.

Default mode is a dry-run. No local data is changed without --apply.
''';
