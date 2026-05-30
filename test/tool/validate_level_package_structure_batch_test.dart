import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_level_package_structure_batch.dart';
import '../../tool/export_vocabulary_review_seed.dart';
import '../../tool/validate_level_package_structure_batch.dart';

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

  test('allows valid rows with empty review decisions', () {
    final validation = validateLevelPackageStructureBatchCsv(batchCsv([row()]));

    expect(validation.totalRows, 1);
    expect(validation.emptyDecisionCount, 1);
    expect(validation.filledDecisionCount, 0);
    expect(validation.issues, isEmpty);
  });

  test('counts filled decisions by type', () {
    final validation = validateLevelPackageStructureBatchCsv(
      batchCsv([
        row(
          reviewDecision: 'map_word_world',
          reviewNote: 'level=A1; word_world=Travel',
        ),
        row(
          wordKey: 'word-2',
          reviewDecision: 'map_level',
          reviewNote: 'level=B2; word_world=needs_context',
        ),
      ]),
    );

    expect(validation.filledDecisionCount, 2);
    expect(validation.decisionsByType['map_word_world'], 1);
    expect(validation.decisionsByType['map_level'], 1);
    expect(validation.issues, isEmpty);
  });

  test('reports missing required fields', () {
    final validation = validateLevelPackageStructureBatchCsv(
      batchCsv([
        row(structureCase: '', priority: '', wordKey: '', baseTerm: ''),
      ]),
    );

    expect(validation.issues, hasLength(4));
    expect(validation.issues.map((issue) => issue.issueType).toSet(), {
      'missing_required_field',
    });
  });

  test('reports unknown review decisions', () {
    final validation = validateLevelPackageStructureBatchCsv(
      batchCsv([row(reviewDecision: 'approve_now')]),
    );

    expect(validation.issues, hasLength(1));
    expect(validation.issues.single.issueType, 'unknown_review_decision');
  });

  test('requires notes for needs_context and reject', () {
    final validation = validateLevelPackageStructureBatchCsv(
      batchCsv([
        row(wordKey: 'word-1', reviewDecision: 'needs_context'),
        row(wordKey: 'word-2', reviewDecision: 'reject'),
      ]),
    );

    expect(validation.issues, hasLength(2));
    expect(validation.issues.map((issue) => issue.issueType).toSet(), {
      'missing_review_note',
    });
  });

  test('reports map decisions without target mapping note', () {
    final validation = validateLevelPackageStructureBatchCsv(
      batchCsv([row(reviewDecision: 'map_level', reviewNote: 'Bitte prüfen.')]),
    );

    expect(validation.issues, hasLength(1));
    expect(validation.issues.single.issueType, 'missing_target_mapping');
  });

  test('throws for missing schema columns', () {
    expect(
      () => validateLevelPackageStructureBatchCsv(
        'structure_case,word_key\nlevel_topic,word-1\n',
      ),
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
      'talvori_structure_validation_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final input = File('${tempDir.path}/batch.csv')
      ..writeAsStringSync(batchCsv([row()]));
    final reportPath = '${tempDir.path}/report.md';

    final result = validateLevelPackageStructureBatch(
      LevelPackageStructureValidationOptions(
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
