import 'dart:convert';
import 'dart:io';

const defaultReviewCsvPath =
    'docs/word-review/language_code_normalization_review.csv';
const maxLanguageNormalizationCandidates = 25;

Future<void> main(List<String> args) async {
  final options = NormalizeLanguageCodeOptions.fromArgs(args);
  if (options.help) {
    stdout.writeln(NormalizeLanguageCodeOptions.usage);
    return;
  }

  final reviewFile = File(options.reviewCsvPath);
  if (!reviewFile.existsSync()) {
    stderr.writeln('Review CSV not found: ${options.reviewCsvPath}');
    exitCode = 2;
    return;
  }

  final parsed = parseLanguageCodeNormalizationCsv(
    reviewFile.readAsStringSync(),
  );
  if (parsed.warnings.isNotEmpty) {
    for (final warning in parsed.warnings) {
      stderr.writeln('Warning: $warning');
    }
  }

  try {
    validateLanguageNormalizationCandidates(parsed.candidates);
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
    return;
  }

  final normalizer = SupabaseLanguageCodeNormalizer(
    client: options.apply ? _createSupabaseClient() : null,
  );

  try {
    final result = await normalizer.run(
      candidates: parsed.candidates,
      apply: options.apply,
    );
    stdout.write(result.render());
  } on Object catch (error) {
    stderr.writeln('Language code normalization failed: $error');
    exitCode = 1;
  }
}

class NormalizeLanguageCodeOptions {
  const NormalizeLanguageCodeOptions({
    required this.apply,
    required this.reviewCsvPath,
    this.help = false,
  });

  factory NormalizeLanguageCodeOptions.fromArgs(List<String> args) {
    var apply = false;
    var reviewCsvPath = defaultReviewCsvPath;
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

    return NormalizeLanguageCodeOptions(
      apply: apply,
      reviewCsvPath: reviewCsvPath,
      help: help,
    );
  }

  static const usage = '''
Usage:
  dart tool/normalize_supabase_language_codes.dart [--csv <path>] [--apply]

Default mode is dry-run. No Supabase data is changed unless --apply is passed.
Only words.from_lang and words.to_lang are updated, and only for validated
EN->DE to en->de candidates from the review CSV.
''';

  final bool apply;
  final String reviewCsvPath;
  final bool help;
}

class LanguageNormalizationParseResult {
  const LanguageNormalizationParseResult({
    required this.candidates,
    required this.warnings,
  });

  final List<LanguageNormalizationCandidate> candidates;
  final List<String> warnings;
}

class LanguageNormalizationCandidate {
  const LanguageNormalizationCandidate({
    required this.wordId,
    required this.term,
    required this.translation,
    required this.fromLang,
    required this.toLang,
    required this.proposedFromLang,
    required this.proposedToLang,
  });

  final String wordId;
  final String term;
  final String translation;
  final String fromLang;
  final String toLang;
  final String proposedFromLang;
  final String proposedToLang;

  String get currentPair => '$fromLang->$toLang';
  String get proposedPair => '$proposedFromLang->$proposedToLang';
}

LanguageNormalizationParseResult parseLanguageCodeNormalizationCsv(
  String input,
) {
  final records = parseCsvRecords(input);
  if (records.isEmpty) {
    return const LanguageNormalizationParseResult(
      candidates: [],
      warnings: ['CSV is empty.'],
    );
  }

  final headers = records.first;
  final candidates = <LanguageNormalizationCandidate>[];
  final warnings = <String>[];

  for (var rowIndex = 1; rowIndex < records.length; rowIndex++) {
    final record = records[rowIndex];
    final values = <String, String>{};
    for (var index = 0; index < headers.length; index++) {
      values[headers[index]] = index < record.length ? record[index] : '';
    }

    final wordId = values['word_id']?.trim() ?? '';
    final fromLang = values['from_lang']?.trim() ?? '';
    final toLang = values['to_lang']?.trim() ?? '';
    final proposedFromLang = values['proposed_from_lang']?.trim() ?? '';
    final proposedToLang = values['proposed_to_lang']?.trim() ?? '';

    if (wordId.isEmpty) {
      warnings.add('row ${rowIndex + 1}: missing word_id, skipped.');
      continue;
    }
    if (proposedFromLang.isEmpty || proposedToLang.isEmpty) {
      warnings.add('row ${rowIndex + 1}: missing proposed language, skipped.');
      continue;
    }
    if (fromLang != 'EN' ||
        toLang != 'DE' ||
        proposedFromLang != 'en' ||
        proposedToLang != 'de') {
      warnings.add(
        'row ${rowIndex + 1}: not an exact EN/DE -> en/de candidate, skipped.',
      );
      continue;
    }

    candidates.add(
      LanguageNormalizationCandidate(
        wordId: wordId,
        term: values['term'] ?? '',
        translation: values['translation'] ?? '',
        fromLang: fromLang,
        toLang: toLang,
        proposedFromLang: proposedFromLang,
        proposedToLang: proposedToLang,
      ),
    );
  }

  return LanguageNormalizationParseResult(
    candidates: candidates,
    warnings: warnings,
  );
}

void validateLanguageNormalizationCandidates(
  List<LanguageNormalizationCandidate> candidates,
) {
  if (candidates.length > maxLanguageNormalizationCandidates) {
    throw StateError(
      'Refusing to continue: found ${candidates.length} candidates, '
      'expected at most $maxLanguageNormalizationCandidates.',
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

class SupabaseLanguageCodeNormalizer {
  const SupabaseLanguageCodeNormalizer({this.client});

  final SupabaseWordsLanguageClient? client;

  Future<LanguageNormalizationRunResult> run({
    required List<LanguageNormalizationCandidate> candidates,
    required bool apply,
  }) async {
    if (!apply) {
      return LanguageNormalizationRunResult.dryRun(candidates);
    }

    final activeClient = client;
    if (activeClient == null) {
      throw StateError('Apply mode requires a Supabase client.');
    }

    var updated = 0;
    var skipped = 0;
    var verified = 0;
    final warnings = <String>[];

    for (final candidate in candidates) {
      final current = await activeClient.fetchWordLanguage(candidate.wordId);
      if (current == null) {
        skipped++;
        warnings.add('${candidate.wordId}: not found, skipped.');
        continue;
      }
      if (current.fromLang != 'EN' || current.toLang != 'DE') {
        skipped++;
        warnings.add(
          '${candidate.wordId}: current value is '
          '${current.fromLang}->${current.toLang}, skipped.',
        );
        continue;
      }

      await activeClient.updateWordLanguage(
        wordId: candidate.wordId,
        fromLang: candidate.proposedFromLang,
        toLang: candidate.proposedToLang,
      );
      updated++;

      final verifiedLanguage = await activeClient.fetchWordLanguage(
        candidate.wordId,
      );
      if (verifiedLanguage?.fromLang == candidate.proposedFromLang &&
          verifiedLanguage?.toLang == candidate.proposedToLang) {
        verified++;
      } else {
        warnings.add('${candidate.wordId}: verification failed.');
      }
    }

    return LanguageNormalizationRunResult.apply(
      updated: updated,
      skipped: skipped,
      verified: verified,
      warnings: warnings,
    );
  }
}

abstract class SupabaseWordsLanguageClient {
  Future<WordLanguage?> fetchWordLanguage(String wordId);

  Future<void> updateWordLanguage({
    required String wordId,
    required String fromLang,
    required String toLang,
  });
}

class WordLanguage {
  const WordLanguage({required this.fromLang, required this.toLang});

  final String fromLang;
  final String toLang;
}

class LanguageNormalizationRunResult {
  const LanguageNormalizationRunResult._({
    required this.dryRun,
    required this.candidates,
    required this.updated,
    required this.skipped,
    required this.verified,
    required this.warnings,
  });

  factory LanguageNormalizationRunResult.dryRun(
    List<LanguageNormalizationCandidate> candidates,
  ) {
    return LanguageNormalizationRunResult._(
      dryRun: true,
      candidates: candidates,
      updated: 0,
      skipped: 0,
      verified: 0,
      warnings: const [],
    );
  }

  factory LanguageNormalizationRunResult.apply({
    required int updated,
    required int skipped,
    required int verified,
    required List<String> warnings,
  }) {
    return LanguageNormalizationRunResult._(
      dryRun: false,
      candidates: const [],
      updated: updated,
      skipped: skipped,
      verified: verified,
      warnings: warnings,
    );
  }

  final bool dryRun;
  final List<LanguageNormalizationCandidate> candidates;
  final int updated;
  final int skipped;
  final int verified;
  final List<String> warnings;

  String render() {
    final buffer = StringBuffer();
    if (dryRun) {
      buffer
        ..writeln('Language code normalization dry-run')
        ..writeln('Candidates: ${candidates.length}')
        ..writeln('Will update:');
      for (final candidate in candidates) {
        buffer.writeln(
          '- ${candidate.wordId}: ${candidate.currentPair} => '
          '${candidate.proposedPair} | '
          '${_oneLine(candidate.term)} / ${_oneLine(candidate.translation)}',
        );
      }
      buffer.writeln('No data changed. Run with --apply to write.');
    } else {
      buffer
        ..writeln('Applying language code normalization...')
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

class SupabaseRestWordsLanguageClient implements SupabaseWordsLanguageClient {
  const SupabaseRestWordsLanguageClient({
    required this.supabaseUrl,
    required this.anonKey,
  });

  final String supabaseUrl;
  final String anonKey;

  @override
  Future<WordLanguage?> fetchWordLanguage(String wordId) async {
    final rows = await _request(
      method: 'GET',
      path: 'words',
      queryParameters: {
        'select': 'from_lang,to_lang',
        'id': 'eq.$wordId',
        'limit': '1',
      },
    );
    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;
    return WordLanguage(
      fromLang: row['from_lang']?.toString() ?? '',
      toLang: row['to_lang']?.toString() ?? '',
    );
  }

  @override
  Future<void> updateWordLanguage({
    required String wordId,
    required String fromLang,
    required String toLang,
  }) async {
    await _request(
      method: 'PATCH',
      path: 'words',
      queryParameters: {'id': 'eq.$wordId'},
      body: {'from_lang': fromLang, 'to_lang': toLang},
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

SupabaseWordsLanguageClient _createSupabaseClient() {
  final env = loadEnv();
  final url = env['SUPABASE_URL'];
  final anonKey = env['SUPABASE_ANON_KEY'];
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env.local/.env.',
    );
  }
  return SupabaseRestWordsLanguageClient(supabaseUrl: url, anonKey: anonKey);
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
