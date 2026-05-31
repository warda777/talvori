import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_mvp_content_review_batch.dart';
import '../../tool/export_mvp_content_review_overlay.dart';
import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  String workingCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([mvpContentReviewBatchHeader, ...rows]);
  }

  List<String> row({
    String wordKey = 'word-1',
    String baseTerm = 'airport',
    String deTranslation = 'Flughafen',
    String level = 'A1',
    String category = 'Travel',
    String wordWorld = 'Travel',
    String mvpReason = 'mvp_start_word_world:Travel',
    String riskType = 'standard_review',
    String reviewDecision = 'approved_for_mvp',
    String reviewNote = '',
  }) {
    return [
      'travel-1',
      wordKey,
      baseTerm,
      deTranslation,
      level,
      category,
      wordWorld,
      mvpReason,
      riskType,
      reviewDecision,
      reviewNote,
    ];
  }

  test('exports only rows with filled decisions', () {
    final overlay = buildMvpContentReviewOverlayCsv(
      workingCsv([
        row(wordKey: 'word-1', reviewDecision: 'approved_for_mvp'),
        row(wordKey: 'word-2', reviewDecision: ''),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(overlay.csv);
    expect(records.first, mvpContentReviewOverlayHeader);
    expect(overlay.rowsRead, 2);
    expect(overlay.rowsWritten, 1);
    expect(records[1][0], 'word-1');
  });

  test('blocks unknown decisions', () {
    expect(
      () => buildMvpContentReviewOverlayCsv(
        workingCsv([row(reviewDecision: 'approve_now')]),
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

  test('blocks note-required decisions without note', () {
    for (final decision in const [
      'fix_translation_later',
      'needs_context',
      'reject_for_mvp',
      'move_out_of_mvp',
      'add_note',
    ]) {
      expect(
        () => buildMvpContentReviewOverlayCsv(
          workingCsv([row(reviewDecision: decision)]),
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('requires `review_note`'),
          ),
        ),
      );
    }
  });

  test('copies reviewer and reviewed date to exported rows', () {
    final overlay = buildMvpContentReviewOverlayCsv(
      workingCsv([
        row(
          reviewDecision: 'fix_translation_later',
          reviewNote: 'Grossschreibung pruefen.',
        ),
      ]),
      reviewer: 'Andreas',
      reviewedAt: '2026-05-31',
    );

    final records = parseVocabularyReviewCsvRecords(overlay.csv);
    expect(records[1][8], 'fix_translation_later');
    expect(records[1][9], 'Grossschreibung pruefen.');
    expect(records[1][10], 'Andreas');
    expect(records[1][11], '2026-05-31');
  });

  test('does not overwrite existing output without force', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_mvp_overlay_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/working.csv')
      ..writeAsStringSync(workingCsv([row()]));
    final output = File('${tempDir.path}/overlay.csv')
      ..writeAsStringSync('existing');

    expect(
      () => exportMvpContentReviewOverlay(
        MvpContentReviewOverlayExportOptions(
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

  test('empty overlay requires allow-empty', () {
    expect(
      () => buildMvpContentReviewOverlayCsv(
        workingCsv([row(reviewDecision: '')]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('--allow-empty'),
        ),
      ),
    );

    final overlay = buildMvpContentReviewOverlayCsv(
      workingCsv([row(reviewDecision: '')]),
      allowEmpty: true,
    );
    expect(overlay.rowsWritten, 0);
  });
}
