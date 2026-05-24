import 'package:flutter_test/flutter_test.dart';

import '../../tool/normalize_supabase_language_codes.dart';

void main() {
  const csvHeader =
      'word_id,term,translation,from_lang,to_lang,proposed_from_lang,proposed_to_lang,decision,notes\n';

  test('recognizes an EN to DE normalization candidate', () {
    final parsed = parseLanguageCodeNormalizationCsv(
      '${csvHeader}word-1,move,umziehen,EN,DE,en,de,,\n',
    );

    expect(parsed.warnings, isEmpty);
    expect(parsed.candidates, hasLength(1));
    expect(parsed.candidates.single.wordId, 'word-1');
    expect(parsed.candidates.single.currentPair, 'EN->DE');
    expect(parsed.candidates.single.proposedPair, 'en->de');
  });

  test('skips rows that are not exact EN to DE normalization candidates', () {
    final parsed = parseLanguageCodeNormalizationCsv(
      '${csvHeader}word-1,move,umziehen,en,de,en,de,,\n',
    );

    expect(parsed.candidates, isEmpty);
    expect(parsed.warnings.single, contains('skipped'));
  });

  test('aborts when more than 25 candidates are present', () {
    final rows = List.generate(
      26,
      (index) => 'word-$index,term-$index,translation-$index,EN,DE,en,de,,',
    ).join('\n');
    final parsed = parseLanguageCodeNormalizationCsv('$csvHeader$rows\n');

    expect(
      () => validateLanguageNormalizationCandidates(parsed.candidates),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'dry-run does not require a Supabase client and does not write',
    () async {
      final parsed = parseLanguageCodeNormalizationCsv(
        '${csvHeader}word-1,move,umziehen,EN,DE,en,de,,\n',
      );
      final normalizer = SupabaseLanguageCodeNormalizer();

      final result = await normalizer.run(
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
    expect(NormalizeLanguageCodeOptions.fromArgs([]).apply, isFalse);
    expect(NormalizeLanguageCodeOptions.fromArgs(['--apply']).apply, isTrue);
  });
}
