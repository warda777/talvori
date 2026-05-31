import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_mvp_content_review_batch.dart';
import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  String sourceCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([
      [
        'word_id',
        'term/text',
        'translation',
        'from_lang',
        'to_lang',
        'current_category_names',
        'current_level',
        'proposed_word_worlds',
      ],
      ...rows,
    ]);
  }

  List<String> row({
    required String wordId,
    required String term,
    required String translation,
    String fromLang = 'en',
    String toLang = 'de',
    String category = 'Travel',
    String level = 'A1',
    String wordWorld = 'Travel',
  }) {
    return [
      wordId,
      term,
      translation,
      fromLang,
      toLang,
      category,
      level,
      wordWorld,
    ];
  }

  test('filters only MVP target word worlds and EN to DE rows', () {
    final batch = buildMvpContentReviewBatchCsv(
      sourceCsv([
        row(wordId: 'travel-1', term: 'airport', translation: 'Flughafen'),
        row(
          wordId: 'food-1',
          term: 'apple',
          translation: 'Apfel',
          category: 'Food & Cooking',
          wordWorld: 'Food & Cooking',
        ),
        row(
          wordId: 'home-1',
          term: 'bed',
          translation: 'Bett',
          category: 'Home & Living',
          wordWorld: 'Home & Living',
        ),
        row(
          wordId: 'work-1',
          term: 'office',
          translation: 'Büro',
          category: 'Work & Careers',
          wordWorld: 'Work & Careers',
        ),
        row(
          wordId: 'travel-es-1',
          term: 'ticket',
          translation: 'billete',
          toLang: 'es',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(batch.csv);
    final wordKeys = records.skip(1).map((record) => record[1]).toSet();

    expect(records.first, mvpContentReviewBatchHeader);
    expect(batch.rowsWritten, 3);
    expect(wordKeys, {'travel-1', 'food-1', 'home-1'});
    expect(batch.availableByWordWorld['Travel'], 1);
    expect(batch.availableByWordWorld['Food & Cooking'], 1);
    expect(batch.availableByWordWorld['Home & Living'], 1);
  });

  test('limits to max rows and distributes by target word world', () {
    final rows = <List<String>>[
      for (var index = 0; index < 3; index++)
        row(
          wordId: 'travel-$index',
          term: 'travel $index',
          translation: 'Reise $index',
        ),
      for (var index = 0; index < 3; index++)
        row(
          wordId: 'food-$index',
          term: 'food $index',
          translation: 'Essen $index',
          category: 'Food & Cooking',
          wordWorld: 'Food & Cooking',
        ),
      for (var index = 0; index < 3; index++)
        row(
          wordId: 'home-$index',
          term: 'home $index',
          translation: 'Zuhause $index',
          category: 'Home & Living',
          wordWorld: 'Home & Living',
        ),
    ];

    final batch = buildMvpContentReviewBatchCsv(
      sourceCsv(rows),
      maxRows: 6,
      maxRowsPerWordWorld: 2,
    );

    expect(batch.rowsWritten, 6);
    expect(batch.exportedByWordWorld['Travel'], 2);
    expect(batch.exportedByWordWorld['Food & Cooking'], 2);
    expect(batch.exportedByWordWorld['Home & Living'], 2);
  });

  test('leaves review fields empty and sets MVP reason', () {
    final batch = buildMvpContentReviewBatchCsv(
      sourceCsv([
        row(wordId: 'travel-1', term: 'airport', translation: 'Flughafen'),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(batch.csv);
    expect(records[1][7], 'mvp_start_word_world:Travel');
    expect(records[1][9], isEmpty);
    expect(records[1][10], isEmpty);
  });

  test('detects same base and translation risk', () {
    final batch = buildMvpContentReviewBatchCsv(
      sourceCsv([
        row(
          wordId: 'food-1',
          term: 'vegan',
          translation: 'vegan',
          category: 'Food & Cooking',
          wordWorld: 'Food & Cooking',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(batch.csv);
    expect(records[1][8], 'same_base_and_translation');
  });

  test('detects structure risk for level or Top 500 mixed with topic', () {
    final batch = buildMvpContentReviewBatchCsv(
      sourceCsv([
        row(
          wordId: 'home-1',
          term: 'bed',
          translation: 'Bett',
          category: 'A1; Home & Living; Top 500 Words',
          wordWorld: 'Home & Living',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(batch.csv);
    expect(records[1][8], 'structure_issue');
  });

  test('does not overwrite existing output without force', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_mvp_content_batch_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/source.csv')
      ..writeAsStringSync(
        sourceCsv([
          row(wordId: 'travel-1', term: 'airport', translation: 'Flughafen'),
        ]),
      );
    final output = File('${tempDir.path}/batch.csv')
      ..writeAsStringSync('existing');

    expect(
      () => exportMvpContentReviewBatch(
        MvpContentReviewBatchOptions(
          inputPath: input.path,
          outputPath: output.path,
          force: false,
          maxRows: 150,
          maxRowsPerWordWorld: 50,
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(output.readAsStringSync(), 'existing');
  });
}
