import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_manual_review_overlay.dart';
import '../../tool/export_vocabulary_review_seed.dart';
import '../../tool/validate_manual_review_batch.dart';

void main() {
  String batchCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([manualReviewBatchHeader, ...rows]);
  }

  List<String> row({
    String reviewBlock = 'exakte_dubletten',
    String priority = '1',
    String wordKey = 'word-1',
    String baseTerm = 'move',
    String deTranslation = 'bewegen',
    String level = 'A1',
    String category = 'Basics',
    String wordWorld = 'Basics',
    String conflictType = 'exact_duplicate',
    String suggestedAction = 'keep / merge_later',
    String reviewDecision = '',
    String reviewNote = '',
  }) {
    return [
      reviewBlock,
      priority,
      wordKey,
      baseTerm,
      deTranslation,
      level,
      category,
      wordWorld,
      conflictType,
      suggestedAction,
      reviewDecision,
      reviewNote,
    ];
  }

  test('exports only rows with filled review decisions', () {
    final overlay = buildManualReviewOverlayCsv(
      batchCsv([
        row(wordKey: 'word-1', reviewDecision: 'keep'),
        row(wordKey: 'word-2'),
        row(
          wordKey: 'word-3',
          reviewDecision: 'add_note',
          reviewNote: 'Internationalismus prüfen.',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(overlay.csv);

    expect(overlay.rowsRead, 3);
    expect(overlay.rowsWritten, 2);
    expect(records.first, manualReviewOverlayHeader);
    expect(records[1][0], 'word-1');
    expect(records[2][0], 'word-3');
    expect(overlay.csv, isNot(contains('word-2')));
  });

  test('blocks unknown review decisions', () {
    expect(
      () => buildManualReviewOverlayCsv(
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
      () => buildManualReviewOverlayCsv(
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
      () => buildManualReviewOverlayCsv(
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

  test('blocks split_meaning without note', () {
    expect(
      () => buildManualReviewOverlayCsv(
        batchCsv([row(reviewDecision: 'split_meaning')]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('split_meaning'),
        ),
      ),
    );
  });

  test('blocks missing required columns', () {
    expect(
      () => buildManualReviewOverlayCsv(
        'word_key,review_decision\nword-1,keep\n',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('review_block'),
        ),
      ),
    );
  });

  test('adds reviewer and reviewed_at to exported rows', () {
    final overlay = buildManualReviewOverlayCsv(
      batchCsv([row(reviewDecision: 'keep')]),
      reviewer: 'Andreas',
      reviewedAt: '2026-05-30',
    );

    final records = parseVocabularyReviewCsvRecords(overlay.csv);

    expect(records[1][7], 'Andreas');
    expect(records[1][8], '2026-05-30');
  });

  test('does not overwrite existing output without force', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_manual_review_overlay_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/working.csv')
      ..writeAsStringSync(batchCsv([row(reviewDecision: 'keep')]));
    final output = File('${tempDir.path}/overlay.csv')
      ..writeAsStringSync('existing');

    expect(
      () => exportManualReviewOverlay(
        ManualReviewOverlayExportOptions(
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
      () => buildManualReviewOverlayCsv(batchCsv([row()])),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('No filled review_decision values found'),
        ),
      ),
    );

    final overlay = buildManualReviewOverlayCsv(
      batchCsv([row()]),
      allowEmpty: true,
    );

    expect(overlay.rowsWritten, 0);
    expect(parseVocabularyReviewCsvRecords(overlay.csv), [
      manualReviewOverlayHeader,
    ]);
  });

  test('writes overlay without Supabase or SQLite dependencies', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_manual_review_overlay_write_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/working.csv')
      ..writeAsStringSync(batchCsv([row(reviewDecision: 'keep')]));
    final outputPath = '${tempDir.path}/overlay.csv';

    final result = exportManualReviewOverlay(
      ManualReviewOverlayExportOptions(
        inputPath: input.path,
        outputPath: outputPath,
        force: false,
        allowEmpty: false,
        reviewer: 'Andreas',
        reviewedAt: '2026-05-30',
      ),
    );

    expect(result.rowsRead, 1);
    expect(result.rowsWritten, 1);
    final records = parseVocabularyReviewCsvRecords(
      File(outputPath).readAsStringSync(),
    );
    expect(records.first, manualReviewOverlayHeader);
    expect(records[1][7], 'Andreas');
  });
}
