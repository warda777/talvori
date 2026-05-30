import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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

  test('allows valid rows with empty review decisions', () {
    final validation = validateManualReviewBatchCsv(batchCsv([row()]));

    expect(validation.totalRows, 1);
    expect(validation.emptyDecisionCount, 1);
    expect(validation.filledDecisionCount, 0);
    expect(validation.issues, isEmpty);
  });

  test('reports missing required fields', () {
    final validation = validateManualReviewBatchCsv(
      batchCsv([
        row(
          reviewBlock: '',
          priority: '',
          wordKey: '',
          baseTerm: '',
          conflictType: '',
        ),
      ]),
    );

    expect(validation.issues, hasLength(5));
    expect(validation.issues.map((issue) => issue.issueType).toSet(), {
      'missing_required_field',
    });
  });

  test('reports unknown review decisions', () {
    final validation = validateManualReviewBatchCsv(
      batchCsv([row(reviewDecision: 'approve_now')]),
    );

    expect(validation.issues, hasLength(1));
    expect(validation.issues.single.issueType, 'unknown_review_decision');
  });

  test('requires notes for needs_context reject and split_meaning', () {
    final validation = validateManualReviewBatchCsv(
      batchCsv([
        row(wordKey: 'word-1', reviewDecision: 'needs_context'),
        row(wordKey: 'word-2', reviewDecision: 'reject'),
        row(wordKey: 'word-3', reviewDecision: 'split_meaning'),
      ]),
    );

    expect(validation.issues, hasLength(3));
    expect(validation.issues.map((issue) => issue.issueType).toSet(), {
      'missing_review_note',
    });
  });

  test('accepts note-backed decisions', () {
    final validation = validateManualReviewBatchCsv(
      batchCsv([
        row(reviewDecision: 'needs_context', reviewNote: 'Kontext prüfen.'),
        row(
          wordKey: 'word-2',
          reviewDecision: 'reject',
          reviewNote: 'Kein sinnvolles Lernwort.',
        ),
        row(
          wordKey: 'word-3',
          reviewDecision: 'split_meaning',
          reviewNote: 'move: bewegen vs. umziehen.',
        ),
      ]),
    );

    expect(validation.issues, isEmpty);
    expect(validation.filledDecisionCount, 3);
  });

  test('throws for missing schema columns', () {
    expect(
      () => validateManualReviewBatchCsv('review_block,word_key\nx,word-1\n'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('priority'),
        ),
      ),
    );
  });

  test('writes a report without Supabase or SQLite dependencies', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_manual_review_validation_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/batch.csv')
      ..writeAsStringSync(batchCsv([row()]));
    final reportPath = '${tempDir.path}/report.md';

    final result = validateManualReviewBatch(
      ManualReviewBatchValidationOptions(
        inputPath: input.path,
        reportPath: reportPath,
      ),
    );

    expect(result.validation.totalRows, 1);
    final report = File(reportPath).readAsStringSync();
    expect(report, contains('Gesamtzeilen: 1'));
    expect(report, contains('Keine Validierungsprobleme'));
  });
}
