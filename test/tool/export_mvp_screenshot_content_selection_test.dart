import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_mvp_content_review_overlay.dart';
import '../../tool/export_mvp_screenshot_content_selection.dart';
import '../../tool/export_vocabulary_review_seed.dart';

void main() {
  String overlayCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([mvpContentReviewOverlayHeader, ...rows]);
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
      'Andreas',
      '2026-05-31',
    ];
  }

  test('exports only approved_for_mvp rows', () {
    final selection = buildMvpScreenshotContentSelectionCsv(
      overlayCsv([
        row(wordKey: 'approved-1'),
        row(wordKey: 'fix-1', reviewDecision: 'fix_translation_later'),
        row(wordKey: 'context-1', reviewDecision: 'needs_context'),
        row(wordKey: 'reject-1', reviewDecision: 'reject_for_mvp'),
        row(wordKey: 'move-1', reviewDecision: 'move_out_of_mvp'),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(selection.csv);
    expect(records.first, mvpScreenshotContentSelectionHeader);
    expect(selection.rowsRead, 5);
    expect(selection.rowsWritten, 1);
    expect(records[1][1], 'approved-1');
  });

  test('limits output to max rows and per-word-world cap', () {
    final rows = <List<String>>[];
    for (var index = 0; index < 12; index++) {
      rows.add(
        row(
          wordKey: 'travel-$index',
          baseTerm: 'travel$index',
          mvpReason: 'mvp_start_word_world:Travel',
          wordWorld: 'Travel',
        ),
      );
      rows.add(
        row(
          wordKey: 'food-$index',
          baseTerm: 'food$index',
          category: 'Food & Cooking',
          wordWorld: 'Food & Cooking',
          mvpReason: 'mvp_start_word_world:Food & Cooking',
        ),
      );
    }

    final selection = buildMvpScreenshotContentSelectionCsv(
      overlayCsv(rows),
      maxRows: 10,
      maxRowsPerWordWorld: 6,
    );

    final records = parseVocabularyReviewCsvRecords(selection.csv);
    expect(selection.rowsWritten, 10);
    expect(
      records.where((record) => record.first.startsWith('travel')),
      hasLength(6),
    );
    expect(
      records.where((record) => record.first.startsWith('food')),
      hasLength(4),
    );
  });

  test('does not export review or product approval fields', () {
    final selection = buildMvpScreenshotContentSelectionCsv(
      overlayCsv([row()]),
    );

    final records = parseVocabularyReviewCsvRecords(selection.csv);
    expect(records.first, isNot(contains('review_decision')));
    expect(records.first, isNot(contains('release_ready')));
    expect(records.first, isNot(contains('approved')));
  });

  test('filters screenshot-unfriendly long phrases and question marks', () {
    final selection = buildMvpScreenshotContentSelectionCsv(
      overlayCsv([
        row(wordKey: 'short-1', baseTerm: 'bag', deTranslation: 'Tasche'),
        row(
          wordKey: 'question-1',
          baseTerm: 'Could you check the opening hours?',
          deTranslation: 'Könnten Sie die Öffnungszeiten überprüfen?',
        ),
        row(
          wordKey: 'long-1',
          baseTerm: 'very long screenshot phrase here',
          deTranslation: 'kurzer Text',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(selection.csv);
    expect(selection.rowsWritten, 1);
    expect(records[1][1], 'short-1');
  });

  test('filters specialized travel operations from screenshot selection', () {
    final selection = buildMvpScreenshotContentSelectionCsv(
      overlayCsv([
        row(wordKey: 'airport-1', baseTerm: 'airport'),
        row(
          wordKey: 'boarding-1',
          baseTerm: 'digital boarding pass',
          deTranslation: 'digitale Bordkarte',
        ),
        row(
          wordKey: 'transfer-1',
          baseTerm: 'international transfer',
          deTranslation: 'internationaler Transfer',
        ),
      ]),
    );

    final records = parseVocabularyReviewCsvRecords(selection.csv);
    expect(selection.rowsWritten, 1);
    expect(records[1][1], 'airport-1');
  });

  test('does not overwrite existing output without force', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_screenshot_selection_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/overlay.csv')
      ..writeAsStringSync(overlayCsv([row()]));
    final output = File('${tempDir.path}/selection.csv')
      ..writeAsStringSync('existing');

    expect(
      () => exportMvpScreenshotContentSelection(
        MvpScreenshotContentSelectionOptions(
          inputPath: input.path,
          outputPath: output.path,
          force: false,
          maxRows: 60,
          maxRowsPerWordWorld: 20,
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(output.readAsStringSync(), 'existing');
  });
}
