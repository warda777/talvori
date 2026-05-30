import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  const sourceHeader =
      'word_id,term/text,translation,from_lang,to_lang,current_category_names,'
      'current_level,pos,proposed_word_worlds,proposed_level,qa_note,notes\n';

  test('writes the master schema header', () {
    final seed = buildVocabularyReviewSeedCsv(
      '${sourceHeader}word-1,move,bewegen,en,de,Basics,A1,verb,,,,\n',
    );
    final records = parseVocabularyReviewCsvRecords(seed.csv);

    expect(records.first, vocabularyReviewSeedHeader);
    expect(seed.rowsRead, 1);
    expect(seed.rowsWritten, 1);
  });

  test('maps word id, language, term and German translation', () {
    final seed = buildVocabularyReviewSeedCsv(
      '${sourceHeader}word-1,Move,bewegen,EN,DE,Basics,A1,verb,Travel,A2,qa,note\n',
    );
    final row = _singleDataRow(seed.csv);
    final values = _valuesByMasterHeader(row);

    expect(values['word_key'], 'word-1');
    expect(values['base_language'], 'en');
    expect(values['base_term'], 'Move');
    expect(values['normalized_base_term'], 'move');
    expect(values['part_of_speech'], 'verb');
    expect(values['level'], 'A2');
    expect(values['category'], 'Basics');
    expect(values['word_world'], 'Travel');
    expect(values['de_translation'], 'bewegen');
    expect(values['translation_note'], 'qa | note');
  });

  test('falls back to current level and category when proposals are empty', () {
    final seed = buildVocabularyReviewSeedCsv(
      '${sourceHeader}word-1,move,bewegen,en,de,Basics,A1,verb,,,,\n',
    );
    final values = _valuesByMasterHeader(_singleDataRow(seed.csv));

    expect(values['level'], 'A1');
    expect(values['word_world'], 'Basics');
  });

  test('sets safe review defaults and leaves Spanish/French empty', () {
    final seed = buildVocabularyReviewSeedCsv(
      '${sourceHeader}word-1,move,bewegen,en,de,Basics,A1,verb,,,,\n',
    );
    final values = _valuesByMasterHeader(_singleDataRow(seed.csv));

    expect(values['review_status'], 'needs_review');
    expect(values['release_ready'], 'false');
    expect(values['es_translation'], isEmpty);
    expect(values['fr_translation'], isEmpty);
    expect(values['reviewer'], isEmpty);
    expect(values['last_reviewed_at'], isEmpty);
  });

  test('does not map non-German target language into de_translation', () {
    final seed = buildVocabularyReviewSeedCsv(
      '${sourceHeader}word-1,move,mover,en,es,Basics,A1,verb,,,,\n',
    );
    final values = _valuesByMasterHeader(_singleDataRow(seed.csv));

    expect(values['de_translation'], isEmpty);
  });

  test('accepts term and text as alternative term columns', () {
    final termSeed = buildVocabularyReviewSeedCsv(
      'word_id,term,translation,from_lang,to_lang\n'
      'word-1,move,bewegen,en,de\n',
    );
    final textSeed = buildVocabularyReviewSeedCsv(
      'word_id,text,translation,from_lang,to_lang\n'
      'word-2,walk,gehen,en,de\n',
    );

    expect(
      _valuesByMasterHeader(_singleDataRow(termSeed.csv))['base_term'],
      'move',
    );
    expect(
      _valuesByMasterHeader(_singleDataRow(textSeed.csv))['base_term'],
      'walk',
    );
  });

  test('throws a clear error when required source columns are missing', () {
    expect(
      () => buildVocabularyReviewSeedCsv(
        'word_id,term,translation,from_lang\nword-1,move,bewegen,en\n',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('to_lang'),
        ),
      ),
    );
  });

  test('requires force before overwriting an existing output file', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_vocabulary_review_seed_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/source.csv')
      ..writeAsStringSync(
        '${sourceHeader}word-1,move,bewegen,en,de,Basics,A1,verb,,,,\n',
      );
    final output = File('${tempDir.path}/seed.csv')
      ..writeAsStringSync('existing\n');

    expect(
      () => exportVocabularyReviewSeed(
        VocabularyReviewSeedOptions(
          inputPath: input.path,
          outputPath: output.path,
          force: false,
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );

    final result = exportVocabularyReviewSeed(
      VocabularyReviewSeedOptions(
        inputPath: input.path,
        outputPath: output.path,
        force: true,
      ),
    );

    expect(result.rowsRead, 1);
    expect(result.rowsWritten, 1);
    expect(output.readAsStringSync(), contains('needs_review'));
  });
}

List<String> _singleDataRow(String csv) {
  final records = parseVocabularyReviewCsvRecords(csv);
  expect(records, hasLength(2));
  return records.last;
}

Map<String, String> _valuesByMasterHeader(List<String> row) {
  return {
    for (var index = 0; index < vocabularyReviewSeedHeader.length; index++)
      vocabularyReviewSeedHeader[index]: index < row.length ? row[index] : '',
  };
}
