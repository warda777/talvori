import 'package:flutter_test/flutter_test.dart';

import '../../tool/clean_url_contaminated_words.dart';

void main() {
  const csvHeader =
      'word_id,term,translation,from_lang,to_lang,current_category_names,'
      'current_level,issue_type,proposed_term,proposed_translation,decision,notes\n';

  test('recognizes a safe URL-contaminated row', () {
    final parsed = parseUrlContaminationReviewCsv(
      '${csvHeader}word-1,"""move"" https://example.com",'
      '"""umziehen"" https://example.com",EN,DE,,,"term_contains_https; '
      'translation_contains_https; term_url_like; translation_url_like",'
      'move,umziehen,,\n',
    );

    expect(parsed.warnings, isEmpty);
    expect(parsed.candidates, hasLength(1));
    expect(parsed.candidates.single.wordId, 'word-1');
    expect(parsed.candidates.single.proposedTerm, 'move');
    expect(parsed.candidates.single.proposedTranslation, 'umziehen');
  });

  test('ignores long sentence rows without URL issues', () {
    final parsed = parseUrlContaminationReviewCsv(
      '${csvHeader}word-1,"Do you mind if I move the meeting?",'
      '"Haben Sie etwas dagegen, wenn ich die Sitzung verschiebe?",'
      'en,de,Phrases & Idioms,A2,translation_longer_than_80,,,,\n',
    );

    expect(parsed.candidates, isEmpty);
    expect(parsed.warnings.single, contains('no URL issue'));
  });

  test('aborts when more than 3 candidates are present', () {
    final rows = List.generate(
      4,
      (index) =>
          'word-$index,"term https://example.com",'
          '"translation https://example.com",EN,DE,,,"term_contains_https; '
          'translation_contains_https; term_url_like; translation_url_like",'
          'term-$index,translation-$index,,',
    ).join('\n');
    final parsed = parseUrlContaminationReviewCsv('$csvHeader$rows\n');

    expect(
      () => validateUrlCleanCandidates(parsed.candidates),
      throwsA(isA<StateError>()),
    );
  });

  test('safety compare treats display quotes and edge whitespace as equal', () {
    expect(
      normalizeForSafetyCompare('  "move"\\n https://example.com  '),
      normalizeForSafetyCompare('move\n https://example.com'),
    );
    expect(
      normalizeForSafetyCompare('  ""superstar"" https://example.com  '),
      normalizeForSafetyCompare('superstar https://example.com'),
    );
  });

  test('dry-run does not write and reports matching remote rows', () async {
    final parsed = parseUrlContaminationReviewCsv(
      '${csvHeader}word-1,"""move"" https://example.com",'
      '"""umziehen"" https://example.com",EN,DE,,,"term_contains_https; '
      'translation_contains_https; term_url_like; translation_url_like",'
      'move,umziehen,,\n',
    );
    final client = _FakeSupabaseWordsTextClient({
      'word-1': const WordText(
        text: '"move" https://example.com',
        translation: '"umziehen" https://example.com',
      ),
    });
    final cleaner = SupabaseUrlContaminatedWordsCleaner(client: client);

    final result = await cleaner.run(
      candidates: parsed.candidates,
      apply: false,
    );

    expect(result.dryRun, isTrue);
    expect(result.updatable, 1);
    expect(result.updated, 0);
    expect(result.verified, 0);
    expect(client.updateCalls, isEmpty);
    expect(result.render(), contains('Candidates from review: 1'));
    expect(result.render(), contains('Updatable: 1'));
    expect(result.render(), contains('No data changed'));
  });

  test('dry-run accepts remote rows after safety normalization', () async {
    final parsed = parseUrlContaminationReviewCsv(
      '${csvHeader}word-1,"""move""\\n https://example.com",'
      '"""umziehen""\\n https://example.com",EN,DE,,,"term_contains_https; '
      'translation_contains_https; term_url_like; translation_url_like",'
      'move,umziehen,,\n',
    );
    final client = _FakeSupabaseWordsTextClient({
      'word-1': const WordText(
        text: '  move\n https://example.com  ',
        translation: 'umziehen\n https://example.com',
      ),
    });
    final cleaner = SupabaseUrlContaminatedWordsCleaner(client: client);

    final result = await cleaner.run(
      candidates: parsed.candidates,
      apply: false,
    );

    expect(result.updatable, 1);
    expect(result.skipped, 0);
    expect(client.updateCalls, isEmpty);
    expect(result.render(), contains('Updatable: 1'));
  });

  test('dry-run skips remote values that differ from the review CSV', () async {
    final parsed = parseUrlContaminationReviewCsv(
      '${csvHeader}word-1,"""move"" https://example.com",'
      '"""umziehen"" https://example.com",EN,DE,,,"term_contains_https; '
      'translation_contains_https; term_url_like; translation_url_like",'
      'move,umziehen,,\n',
    );
    final client = _FakeSupabaseWordsTextClient({
      'word-1': const WordText(text: 'move', translation: 'umziehen'),
    });
    final cleaner = SupabaseUrlContaminatedWordsCleaner(client: client);

    final result = await cleaner.run(
      candidates: parsed.candidates,
      apply: false,
    );
    final rendered = result.render();

    expect(result.updatable, 0);
    expect(result.skipped, 1);
    expect(client.updateCalls, isEmpty);
    expect(rendered, isNot(contains('Will update')));
    expect(rendered, contains('Remote value differs from review CSV'));
    expect(rendered, contains('term lengths: review='));
    expect(rendered, contains('normalizedEqual=false'));
    expect(rendered, contains('No matching remote rows to update'));
  });

  test('apply skips remote values that differ from the review CSV', () async {
    final parsed = parseUrlContaminationReviewCsv(
      '${csvHeader}word-1,"""move"" https://example.com",'
      '"""umziehen"" https://example.com",EN,DE,,,"term_contains_https; '
      'translation_contains_https; term_url_like; translation_url_like",'
      'move,umziehen,,\n',
    );
    final client = _FakeSupabaseWordsTextClient({
      'word-1': const WordText(text: 'move', translation: 'umziehen'),
    });
    final cleaner = SupabaseUrlContaminatedWordsCleaner(client: client);

    final result = await cleaner.run(
      candidates: parsed.candidates,
      apply: true,
    );

    expect(result.updatable, 0);
    expect(result.skipped, 1);
    expect(result.updated, 0);
    expect(client.updateCalls, isEmpty);
    expect(result.render(), contains('Remote value differs from review CSV'));
  });

  test('apply mode must be requested explicitly', () {
    expect(CleanUrlContaminationOptions.fromArgs([]).apply, isFalse);
    expect(CleanUrlContaminationOptions.fromArgs(['--apply']).apply, isTrue);
  });
}

class _FakeSupabaseWordsTextClient implements SupabaseWordsTextClient {
  _FakeSupabaseWordsTextClient(this.words);

  final Map<String, WordText> words;
  final updateCalls = <String>[];

  @override
  Future<WordText?> fetchWordText(String wordId) async => words[wordId];

  @override
  Future<void> updateWordText({
    required String wordId,
    required String text,
    required String translation,
  }) async {
    updateCalls.add(wordId);
    words[wordId] = WordText(text: text, translation: translation);
  }
}
