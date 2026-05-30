import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_level_package_structure_batch.dart';
import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  String sourceCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([
      [
        'issue_type',
        'word_key',
        'base_language',
        'base_term',
        'de_translation',
        'level',
        'category',
        'word_world',
        'detail',
      ],
      ...rows,
    ]);
  }

  List<String> row({
    String issueType = 'level_as_category_or_word_world',
    String wordKey = 'word-1',
    String baseTerm = 'travel',
    String deTranslation = 'reisen',
    String level = 'A1',
    String category = 'A1',
    String wordWorld = 'A1',
  }) {
    return [
      issueType,
      wordKey,
      'en',
      baseTerm,
      deTranslation,
      level,
      category,
      wordWorld,
      '',
    ];
  }

  test('classifies representative level package and topic cases', () {
    final batch = buildLevelPackageStructureBatchCsv(
      sourceCsv([
        row(wordKey: 'level-only', level: 'A1', category: 'A1'),
        row(
          wordKey: 'level-top500',
          baseTerm: 'about',
          level: 'A1',
          category: 'A1; Top 500 Words',
          wordWorld: 'A1; Top 500 Words',
        ),
        row(
          wordKey: 'level-topic',
          baseTerm: 'accelerate',
          level: 'C1',
          category: 'C1; Productivity',
          wordWorld: 'Productivity',
        ),
        row(
          wordKey: 'multi-topic',
          baseTerm: 'account',
          level: 'B2',
          category: 'B1; B2; Money & Shopping; Work & Careers',
          wordWorld: 'Money & Shopping; Work & Careers',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(batch.csv);
    final cases = records.skip(1).map((record) => record[0]).toSet();

    expect(batch.rowsRead, 4);
    expect(batch.rowsWritten, 4);
    expect(records.first, levelPackageStructureBatchHeader);
    expect(cases, containsAll(['level_only', 'level_top_500', 'level_topic']));
    expect(
      records.any(
        (record) =>
            record[0] == 'multi_topic' &&
            record[11].contains('word_world=Money & Shopping; Work & Careers'),
      ),
      isTrue,
    );
  });

  test('combines duplicate issue rows by word key', () {
    final batch = buildLevelPackageStructureBatchCsv(
      sourceCsv([
        row(
          issueType: 'level_as_category_or_word_world',
          wordKey: 'same-word',
          level: 'A1',
          category: 'A1; Top 500 Words',
          wordWorld: 'A1; Top 500 Words',
        ),
        row(
          issueType: 'top_500_as_category_or_word_world',
          wordKey: 'same-word',
          level: 'A1',
          category: 'A1; Top 500 Words',
          wordWorld: 'A1; Top 500 Words',
        ),
      ]),
    );

    expect(batch.rowsRead, 2);
    expect(batch.rowsWritten, 1);
    final records = parseVocabularyReviewCsvRecords(batch.csv);
    expect(records[1][0], 'level_top_500');
    expect(records[1][8], 'A1');
    expect(records[1][9], 'Top 500 Words');
  });

  test('respects maxRows and leaves review fields empty', () {
    final batch = buildLevelPackageStructureBatchCsv(
      sourceCsv([
        row(wordKey: 'word-1'),
        row(wordKey: 'word-2', level: 'A2', category: 'A2'),
        row(wordKey: 'word-3', level: 'B1', category: 'B1'),
      ]),
      maxRows: 2,
    );

    final records = parseVocabularyReviewCsvRecords(batch.csv);

    expect(batch.rowsWritten, 2);
    for (final record in records.skip(1)) {
      expect(record[12], isEmpty);
      expect(record[13], isEmpty);
    }
  });

  test('throws for missing required columns', () {
    expect(
      () => buildLevelPackageStructureBatchCsv('word_key,base_term\nw,a\n'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('issue_type'),
        ),
      ),
    );
  });

  test('does not overwrite existing output without force', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_level_package_batch_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/source.csv')
      ..writeAsStringSync(sourceCsv([row()]));
    final output = File('${tempDir.path}/batch.csv')
      ..writeAsStringSync('existing');

    expect(
      () => exportLevelPackageStructureBatch(
        LevelPackageStructureBatchOptions(
          inputPath: input.path,
          outputPath: output.path,
          force: false,
          maxRows: 200,
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(output.readAsStringSync(), 'existing');
  });
}
