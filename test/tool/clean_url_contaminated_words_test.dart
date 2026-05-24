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

  test(
    'dry-run does not require a Supabase client and does not write',
    () async {
      final parsed = parseUrlContaminationReviewCsv(
        '${csvHeader}word-1,"""move"" https://example.com",'
        '"""umziehen"" https://example.com",EN,DE,,,"term_contains_https; '
        'translation_contains_https; term_url_like; translation_url_like",'
        'move,umziehen,,\n',
      );
      final cleaner = SupabaseUrlContaminatedWordsCleaner();

      final result = await cleaner.run(
        candidates: parsed.candidates,
        apply: false,
      );

      expect(result.dryRun, isTrue);
      expect(result.updated, 0);
      expect(result.verified, 0);
      expect(result.render(), contains('No data changed'));
    },
  );

  test('apply mode must be requested explicitly', () {
    expect(CleanUrlContaminationOptions.fromArgs([]).apply, isFalse);
    expect(CleanUrlContaminationOptions.fromArgs(['--apply']).apply, isTrue);
  });
}
