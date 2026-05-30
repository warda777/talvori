import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_level_package_structure_batch.dart';
import '../../tool/export_level_package_structure_overlay.dart';
import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  String batchCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([
      levelPackageStructureBatchHeader,
      ...rows,
    ]);
  }

  List<String> row({
    String structureCase = 'level_topic',
    String priority = '4',
    String wordKey = 'word-1',
    String baseTerm = 'travel',
    String deTranslation = 'reisen',
    String level = 'A1',
    String category = 'A1; Travel',
    String wordWorld = 'Travel',
    String detectedLevel = 'A1',
    String detectedPackage = '',
    String detectedTopic = 'Travel',
    String suggestedMapping = 'level=A1 | word_world=Travel',
    String reviewDecision = '',
    String reviewNote = '',
  }) {
    return [
      structureCase,
      priority,
      wordKey,
      baseTerm,
      deTranslation,
      level,
      category,
      wordWorld,
      detectedLevel,
      detectedPackage,
      detectedTopic,
      suggestedMapping,
      reviewDecision,
      reviewNote,
    ];
  }

  test('exports only rows with filled review decisions', () {
    final overlay = buildLevelPackageStructureOverlayCsv(
      batchCsv([
        row(
          wordKey: 'word-1',
          reviewDecision: 'map_word_world',
          reviewNote: 'level=A1; word_world=Travel',
        ),
        row(wordKey: 'word-2'),
        row(
          wordKey: 'word-3',
          reviewDecision: 'map_package',
          reviewNote:
              'level=A1; package=Top 500 Words; word_world=needs_context',
          detectedPackage: 'Top 500 Words',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(overlay.csv);

    expect(overlay.rowsRead, 3);
    expect(overlay.rowsWritten, 2);
    expect(records.first, levelPackageStructureOverlayHeader);
    expect(records[1][0], 'word-1');
    expect(records[2][0], 'word-3');
    expect(overlay.csv, isNot(contains('word-2')));
  });

  test('blocks unknown review decisions', () {
    expect(
      () => buildLevelPackageStructureOverlayCsv(
        batchCsv([row(reviewDecision: 'approve_now')]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('unknown `review_decision`'),
        ),
      ),
    );
  });

  test('blocks needs_context without note', () {
    expect(
      () => buildLevelPackageStructureOverlayCsv(
        batchCsv([row(reviewDecision: 'needs_context')]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('needs_context'),
        ),
      ),
    );
  });

  test('blocks reject without note', () {
    expect(
      () => buildLevelPackageStructureOverlayCsv(
        batchCsv([row(reviewDecision: 'reject')]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('reject'),
        ),
      ),
    );
  });

  test('blocks map decisions without target mapping note', () {
    expect(
      () => buildLevelPackageStructureOverlayCsv(
        batchCsv([
          row(reviewDecision: 'map_level', reviewNote: 'Bitte prüfen.'),
        ]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('target structure'),
        ),
      ),
    );
  });

  test('blocks missing required columns', () {
    expect(
      () => buildLevelPackageStructureOverlayCsv(
        'word_key,review_decision\nword-1,map_level\n',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('structure_case'),
        ),
      ),
    );
  });

  test('adds reviewer and reviewed_at to exported rows', () {
    final overlay = buildLevelPackageStructureOverlayCsv(
      batchCsv([
        row(
          reviewDecision: 'map_level',
          reviewNote: 'level=A1; word_world=needs_context',
        ),
      ]),
      reviewer: 'Andreas',
      reviewedAt: '2026-05-30',
    );

    final records = parseVocabularyReviewCsvRecords(overlay.csv);

    expect(records[1][9], 'Andreas');
    expect(records[1][10], '2026-05-30');
  });

  test('does not overwrite existing output without force', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_structure_overlay_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/working.csv')
      ..writeAsStringSync(
        batchCsv([
          row(
            reviewDecision: 'map_level',
            reviewNote: 'level=A1; word_world=needs_context',
          ),
        ]),
      );
    final output = File('${tempDir.path}/overlay.csv')
      ..writeAsStringSync('existing');

    expect(
      () => exportLevelPackageStructureOverlay(
        LevelPackageStructureOverlayExportOptions(
          inputPath: input.path,
          outputPath: output.path,
          force: false,
          allowEmpty: false,
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(output.readAsStringSync(), 'existing');
  });

  test('does not create empty overlay unless allowEmpty is true', () {
    expect(
      () => buildLevelPackageStructureOverlayCsv(batchCsv([row()])),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('No filled review_decision values found'),
        ),
      ),
    );

    final overlay = buildLevelPackageStructureOverlayCsv(
      batchCsv([row()]),
      allowEmpty: true,
    );

    expect(overlay.rowsWritten, 0);
    expect(parseVocabularyReviewCsvRecords(overlay.csv), [
      levelPackageStructureOverlayHeader,
    ]);
  });

  test('writes overlay without Supabase or SQLite dependencies', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_structure_overlay_write_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/working.csv')
      ..writeAsStringSync(
        batchCsv([
          row(
            reviewDecision: 'map_word_world',
            reviewNote: 'level=A1; word_world=Travel',
          ),
        ]),
      );
    final outputPath = '${tempDir.path}/overlay.csv';

    final result = exportLevelPackageStructureOverlay(
      LevelPackageStructureOverlayExportOptions(
        inputPath: input.path,
        outputPath: outputPath,
        force: false,
        allowEmpty: false,
      ),
    );

    expect(result.rowsRead, 1);
    expect(result.rowsWritten, 1);
    expect(File(outputPath).readAsStringSync(), contains('word-1'));
  });
}
