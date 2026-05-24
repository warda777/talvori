import 'dart:convert';
import 'dart:io';

const defaultUrlContaminationReviewCsvPath =
    'docs/word-review/url_contaminated_words_review.csv';
const maxUrlCleanCandidates = 3;

const _requiredUrlIssues = {
  'term_contains_https',
  'translation_contains_https',
  'term_url_like',
  'translation_url_like',
};

Future<void> main(List<String> args) async {
  final options = CleanUrlContaminationOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(CleanUrlContaminationOptions.usage);
    return;
  }

  final reviewFile = File(options.reviewCsvPath);
  if (!reviewFile.existsSync()) {
    stderr.writeln('Review CSV not found: ${options.reviewCsvPath}');
    exitCode = 2;
    return;
  }

  final parsed = parseUrlContaminationReviewCsv(reviewFile.readAsStringSync());
  if (parsed.warnings.isNotEmpty) {
    for (final warning in parsed.warnings) {
      stderr.writeln('Warning: $warning');
    }
  }

  try {
    validateUrlCleanCandidates(parsed.candidates);
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
    return;
  }

  final cleaner = SupabaseUrlContaminatedWordsCleaner(
    client: options.apply ? _createSupabaseClient() : null,
  );

  try {
    final result = await cleaner.run(
      candidates: parsed.candidates,
      apply: options.apply,
    );
    stdout.write(result.render());
  } on Object catch (error) {
    stderr.writeln('URL contamination cleanup failed: $error');
    exitCode = 1;
  }
}

class CleanUrlContaminationOptions {
  const CleanUrlContaminationOptions({
    required this.apply,
    required this.reviewCsvPath,
    this.help = false,
  });

  factory CleanUrlContaminationOptions.fromArgs(List<String> args) {
    var apply = false;
    var reviewCsvPath = defaultUrlContaminationReviewCsvPath;
    var help = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--apply') {
        apply = true;
      } else if (arg == '--help' || arg == '-h') {
        help = true;
      } else if (arg == '--csv') {
        if (index + 1 >= args.length) {
          throw const FormatException('Missing value after --csv.');
        }
        reviewCsvPath = args[++index];
      } else {
        throw FormatException('Unknown argument: $arg');
      }
    }

    return CleanUrlContaminationOptions(
      apply: apply,
      reviewCsvPath: reviewCsvPath,
      help: help,
    );
  }

  static const usage = '''
Usage:
  dart tool/clean_url_contaminated_words.dart [--csv <path>] [--apply]

Default mode is dry-run. No Supabase data is changed unless --apply is passed.
Only words.text and words.translation are updated, and only for validated
URL-contaminated candidates with safe proposed_term/proposed_translation values.
''';

  final bool apply;
  final String reviewCsvPath;
  final bool help;
}

class UrlContaminationParseResult {
  const UrlContaminationParseResult({
    required this.candidates,
    required this.warnings,
  });

  final List<UrlCleanCandidate> candidates;
  final List<String> warnings;
}

class UrlCleanCandidate {
  const UrlCleanCandidate({
    required this.wordId,
    required this.oldTerm,
    required this.oldTranslation,
    required this.proposedTerm,
    required this.proposedTranslation,
    required this.issueType,
  });

  final String wordId;
  final String oldTerm;
  final String oldTranslation;
  final String proposedTerm;
  final String proposedTranslation;
  final String issueType;
}

UrlContaminationParseResult parseUrlContaminationReviewCsv(String input) {
  final records = parseCsvRecords(input);
  if (records.isEmpty) {
    return const UrlContaminationParseResult(
      candidates: [],
      warnings: ['CSV is empty.'],
    );
  }

  final headers = records.first;
  final candidates = <UrlCleanCandidate>[];
  final warnings = <String>[];

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final record = records[rowIndex];
    final values = <String, String>{};
    for (var index = 0; index < headers.length; index++) {
      values[headers[index]] = index < record.length ? record[index] : '';
    }

    final wordId = values['word_id']?.trim() ?? '';
    final oldTerm = values['term'] ?? '';
    final oldTranslation = values['translation'] ?? '';
    final proposedTerm = values['proposed_term']?.trim() ?? '';
    final proposedTranslation = values['proposed_translation']?.trim() ?? '';
    final issueType = values['issue_type'] ?? '';

    if (wordId.isEmpty) {
      warnings.add('row ${rowIndex + 1}: missing word_id, skipped.');
      continue;
    }
    if (!_hasRequiredUrlIssue(issueType)) {
      warnings.add('row ${rowIndex + 1}: no URL issue, skipped.');
      continue;
    }
    if (proposedTerm.isEmpty || proposedTranslation.isEmpty) {
      warnings.add('row ${rowIndex + 1}: missing proposed value, skipped.');
      continue;
    }
    if (_looksUrlContaminated(proposedTerm) ||
        _looksUrlContaminated(proposedTranslation)) {
      warnings.add('row ${rowIndex + 1}: proposed value still URL-like.');
      continue;
    }
    if (!_looksUrlContaminated(oldTerm) &&
        !_looksUrlContaminated(oldTranslation)) {
      throw StateError(
        'Refusing to continue: row ${rowIndex + 1} has URL issue flags '
        'but neither term nor translation looks URL-contaminated.',
      );
    }

    candidates.add(
      UrlCleanCandidate(
        wordId: wordId,
        oldTerm: oldTerm,
        oldTranslation: oldTranslation,
        proposedTerm: proposedTerm,
        proposedTranslation: proposedTranslation,
        issueType: issueType,
      ),
    );
  }

  return UrlContaminationParseResult(
    candidates: candidates,
    warnings: warnings,
  );
}

void validateUrlCleanCandidates(List<UrlCleanCandidate> candidates) {
  if (candidates.length > maxUrlCleanCandidates) {
    throw StateError(
      'Refusing to continue: found ${candidates.length} candidates, '
      'expected at most $maxUrlCleanCandidates.',
    );
  }

  final seenIds = <String>{};
  for (final candidate in candidates) {
    if (!seenIds.add(candidate.wordId)) {
      throw StateError(
        'Refusing to continue: duplicate word_id in review CSV: '
        '${candidate.wordId}.',
      );
    }
  }
}

bool _hasRequiredUrlIssue(String issueType) {
  final issues = issueType.split(';').map((issue) => issue.trim()).toSet();
  return _requiredUrlIssues.any(issues.contains);
}

bool _looksUrlContaminated(String value) {
  final lower = value.toLowerCase();
  return lower.contains('http://') ||
      lower.contains('https://') ||
      lower.contains('www.') ||
      lower.contains('#:') ||
      lower.contains(':~:text=');
}

class SupabaseUrlContaminatedWordsCleaner {
  const SupabaseUrlContaminatedWordsCleaner({this.client});

  final SupabaseWordsTextClient? client;

  Future<UrlCleanRunResult> run({
    required List<UrlCleanCandidate> candidates,
    required bool apply,
  }) async {
    if (!apply) return UrlCleanRunResult.dryRun(candidates);

    final activeClient = client;
    if (activeClient == null) {
      throw StateError('Apply mode requires a Supabase client.');
    }

    var updated = 0;
    var skipped = 0;
    var verified = 0;
    final warnings = <String>[];

    for (final candidate in candidates) {
      final current = await activeClient.fetchWordText(candidate.wordId);
      if (current == null) {
        skipped++;
        warnings.add('${candidate.wordId}: not found, skipped.');
        continue;
      }
      if (current.text != candidate.oldTerm ||
          current.translation != candidate.oldTranslation) {
        skipped++;
        warnings.add(
          '${candidate.wordId}: current text/translation no longer match '
          'the review CSV, skipped.',
        );
        continue;
      }

      await activeClient.updateWordText(
        wordId: candidate.wordId,
        text: candidate.proposedTerm,
        translation: candidate.proposedTranslation,
      );
      updated++;

      final verifiedWord = await activeClient.fetchWordText(candidate.wordId);
      if (verifiedWord?.text == candidate.proposedTerm &&
          verifiedWord?.translation == candidate.proposedTranslation) {
        verified++;
      } else {
        warnings.add('${candidate.wordId}: verification failed.');
      }
    }

    return UrlCleanRunResult.apply(
      updated: updated,
      skipped: skipped,
      verified: verified,
      warnings: warnings,
    );
  }
}

abstract class SupabaseWordsTextClient {
  Future<WordText?> fetchWordText(String wordId);

  Future<void> updateWordText({
    required String wordId,
    required String text,
    required String translation,
  });
}

class WordText {
  const WordText({required this.text, required this.translation});

  final String text;
  final String translation;
}

class UrlCleanRunResult {
  const UrlCleanRunResult._({
    required this.dryRun,
    required this.candidates,
    required this.updated,
    required this.skipped,
    required this.verified,
    required this.warnings,
  });

  factory UrlCleanRunResult.dryRun(List<UrlCleanCandidate> candidates) {
    return UrlCleanRunResult._(
      dryRun: true,
      candidates: candidates,
      updated: 0,
      skipped: 0,
      verified: 0,
      warnings: const [],
    );
  }

  factory UrlCleanRunResult.apply({
    required int updated,
    required int skipped,
    required int verified,
    required List<String> warnings,
  }) {
    return UrlCleanRunResult._(
      dryRun: false,
      candidates: const [],
      updated: updated,
      skipped: skipped,
      verified: verified,
      warnings: warnings,
    );
  }

  final bool dryRun;
  final List<UrlCleanCandidate> candidates;
  final int updated;
  final int skipped;
  final int verified;
  final List<String> warnings;

  String render() {
    final buffer = StringBuffer();
    if (dryRun) {
      buffer
        ..writeln('URL contamination cleanup dry-run')
        ..writeln('Candidates: ${candidates.length}')
        ..writeln('Will update:');
      for (final candidate in candidates) {
        buffer
          ..writeln('- ${candidate.wordId}')
          ..writeln('  term: ${_oneLine(candidate.oldTerm)}')
          ..writeln('    => ${candidate.proposedTerm}')
          ..writeln('  translation: ${_oneLine(candidate.oldTranslation)}')
          ..writeln('    => ${candidate.proposedTranslation}');
      }
      buffer.writeln('No data changed. Run with --apply to write.');
    } else {
      buffer
        ..writeln('Applying URL contamination cleanup...')
        ..writeln('Updated: $updated')
        ..writeln('Skipped: $skipped')
        ..writeln('Verified: $verified');
      if (warnings.isNotEmpty) {
        buffer.writeln('Warnings:');
        for (final warning in warnings) {
          buffer.writeln('- $warning');
        }
      }
      buffer.writeln('Done.');
    }
    return buffer.toString();
  }
}

class SupabaseRestWordsTextClient implements SupabaseWordsTextClient {
  const SupabaseRestWordsTextClient({
    required this.supabaseUrl,
    required this.anonKey,
  });

  final String supabaseUrl;
  final String anonKey;

  @override
  Future<WordText?> fetchWordText(String wordId) async {
    final rows = await _request(
      method: 'GET',
      path: 'words',
      queryParameters: {
        'select': 'text,translation',
        'id': 'eq.$wordId',
        'limit': '1',
      },
    );
    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;
    return WordText(
      text: row['text']?.toString() ?? '',
      translation: row['translation']?.toString() ?? '',
    );
  }

  @override
  Future<void> updateWordText({
    required String wordId,
    required String text,
    required String translation,
  }) async {
    await _request(
      method: 'PATCH',
      path: 'words',
      queryParameters: {'id': 'eq.$wordId'},
      body: {'text': text, 'translation': translation},
    );
  }

  Future<Object?> _request({
    required String method,
    required String path,
    required Map<String, String> queryParameters,
    Map<String, Object?>? body,
  }) async {
    final uri = Uri.parse(
      '$supabaseUrl/rest/v1/$path',
    ).replace(queryParameters: queryParameters);
    final request = await HttpClient().openUrl(method, uri);
    request.headers
      ..set('apikey', anonKey)
      ..set('Authorization', 'Bearer $anonKey')
      ..set('Accept', 'application/json');
    if (body != null) {
      request.headers
        ..set('Content-Type', 'application/json')
        ..set('Prefer', 'return=representation');
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Supabase request failed: HTTP ${response.statusCode}: $responseBody',
      );
    }
    if (responseBody.trim().isEmpty) return null;
    return jsonDecode(responseBody);
  }
}

SupabaseWordsTextClient _createSupabaseClient() {
  final env = loadEnv();
  final url = env['SUPABASE_URL'];
  final anonKey = env['SUPABASE_ANON_KEY'];
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env.local/.env.',
    );
  }
  return SupabaseRestWordsTextClient(supabaseUrl: url, anonKey: anonKey);
}

Map<String, String> loadEnv({
  List<String> paths = const ['.env.local', '.env'],
}) {
  final env = <String, String>{};
  for (final path in paths) {
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

List<List<String>> parseCsvRecords(String input) {
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

String _oneLine(String value) {
  return value
      .replaceAll(r'\n', ' ')
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
