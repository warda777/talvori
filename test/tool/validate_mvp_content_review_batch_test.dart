import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_mvp_content_review_batch.dart';
import '../../tool/export_vocabulary_review_seed.dart';
import '../../tool/validate_mvp_content_review_batch.dart';

void main() {
  String batchCsv(List<List<String>> rows) {
    return writeVocabularyReviewCsv([mvpContentReviewBatchHeader, ...rows]);
  }

  List<String> row({
    String priority = 'travel-1',
    String wordKey = 'word-1',
    String baseTerm = 'airport',
    String deTranslation = 'Flughafen',
    String level = 'A1',
    String category = 'Travel',
    String wordWorld = 'Travel',
    String mvpReason = 'mvp_start_word_world:Travel',
    String riskType = 'standard_review',
    String reviewDecision = '',
    String reviewNote = '',
  }) {
    return [
      priority,
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

  test('allows valid rows with empty review decisions', () {
    final validation = validateMvpContentReviewBatchCsv(batchCsv([row()]));

    expect(validation.totalRows, 1);
    expect(validation.emptyDecisionCount, 1);
    expect(validation.filledDecisionCount, 0);
    expect(validation.issues, isEmpty);
  });

  test('counts filled decisions word worlds and risk types', () {
    final validation = validateMvpContentReviewBatchCsv(
      batchCsv([
        row(reviewDecision: 'approved_for_mvp'),
        row(
          priority: 'food-1',
          wordKey: 'word-2',
          wordWorld: 'Food & Cooking',
          mvpReason: 'mvp_start_word_world:Food & Cooking',
          riskType: 'same_base_and_translation',
          reviewDecision: 'add_note',
          reviewNote: 'Internationalismus spaeter erklaeren.',
        ),
      ]),
    );

    expect(validation.totalRows, 2);
    expect(validation.filledDecisionCount, 2);
    expect(validation.rowsByWordWorld['Travel'], 1);
    expect(validation.rowsByWordWorld['Food & Cooking'], 1);
    expect(validation.rowsByRiskType['same_base_and_translation'], 1);
    expect(validation.decisionsByType['approved_for_mvp'], 1);
    expect(validation.decisionsByType['add_note'], 1);
    expect(validation.issues, isEmpty);
  });

  test('reports missing required fields', () {
    final validation = validateMvpContentReviewBatchCsv(
      batchCsv([
        row(
          priority: '',
          wordKey: '',
          baseTerm: '',
          wordWorld: '',
          riskType: '',
        ),
      ]),
    );

    expect(validation.issues, hasLength(5));
    expect(validation.issues.map((issue) => issue.issueType).toSet(), {
      'missing_required_field',
    });
  });

  test('reports unknown review decisions', () {
    final validation = validateMvpContentReviewBatchCsv(
      batchCsv([row(reviewDecision: 'approve_now')]),
    );

    expect(validation.issues, hasLength(1));
    expect(validation.issues.single.issueType, 'unknown_review_decision');
  });

  test('requires notes for note-backed decisions', () {
    final validation = validateMvpContentReviewBatchCsv(
      batchCsv([
        row(wordKey: 'word-1', reviewDecision: 'fix_translation_later'),
        row(wordKey: 'word-2', reviewDecision: 'needs_context'),
        row(wordKey: 'word-3', reviewDecision: 'reject_for_mvp'),
        row(wordKey: 'word-4', reviewDecision: 'move_out_of_mvp'),
        row(wordKey: 'word-5', reviewDecision: 'add_note'),
      ]),
    );

    expect(validation.issues, hasLength(5));
    expect(validation.issues.map((issue) => issue.issueType).toSet(), {
      'missing_review_note',
    });
  });

  test('accepts note-backed decisions with notes', () {
    final validation = validateMvpContentReviewBatchCsv(
      batchCsv([
        row(
          reviewDecision: 'fix_translation_later',
          reviewNote: 'Grossschreibung pruefen.',
        ),
        row(
          wordKey: 'word-2',
          reviewDecision: 'needs_context',
          reviewNote: 'Bedeutung ohne Beispielsatz unklar.',
        ),
        row(
          wordKey: 'word-3',
          reviewDecision: 'reject_for_mvp',
          reviewNote: 'Nicht screenshot-tauglich.',
        ),
        row(
          wordKey: 'word-4',
          reviewDecision: 'move_out_of_mvp',
          reviewNote: 'Passt eher zu Animals.',
        ),
        row(
          wordKey: 'word-5',
          reviewDecision: 'add_note',
          reviewNote: 'Als Internationalismus markieren.',
        ),
      ]),
    );

    expect(validation.issues, isEmpty);
    expect(validation.filledDecisionCount, 5);
  });

  test('throws for missing schema columns', () {
    expect(
      () => validateMvpContentReviewBatchCsv('priority,word_key\n1,word-1\n'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('base_term'),
        ),
      ),
    );
  });

  test('writes a report without Supabase or SQLite dependencies', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'talvori_mvp_content_validation_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/batch.csv')
      ..writeAsStringSync(batchCsv([row()]));
    final reportPath = '${tempDir.path}/report.md';

    final result = validateMvpContentReviewBatch(
      MvpContentReviewBatchValidationOptions(
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
